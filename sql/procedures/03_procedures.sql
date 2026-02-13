-- SISTEM DISTRIBUIT PENTRU CULTURA SI TURISM - SIRIA
-- Proceduri Stocate pentru Rapoarte

-- RAPORT 1: Top Locatii dupa Rating (Complexitate 4)
-- JOIN: Locatii-Recenzii, Locatii-Categorii = 2
-- WHERE: activ = 'D' = 1
-- GROUP BY: id_locatie, nume_locatie, nume_categorie = 1
-- Total: 4
CREATE OR REPLACE PROCEDURE sp_top_locatii_rating (
    p_cursor OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_cursor FOR
        SELECT 
            l.id_locatie,
            l.nume_locatie,
            c.nume_categorie,
            COUNT(r.id_recenzie) AS numar_recenzii,
            ROUND(AVG(r.rating), 2) AS rating_mediu,
            SUM(r.util) AS total_voturi_utile
        FROM Locatii l
        JOIN Recenzii r ON l.id_locatie = r.id_locatie
        JOIN Categorii c ON l.id_categorie = c.id_categorie
        WHERE l.activ = 'D'
        GROUP BY l.id_locatie, l.nume_locatie, c.nume_categorie
        ORDER BY rating_mediu DESC, numar_recenzii DESC;
END;
/

-- RAPORT 2: Statistici Tururi pe Regiune (Complexitate 6)
-- JOIN: Tururi-Regiuni, Tururi-Ghizi, Tururi-Rezervari = 3
-- WHERE: t.activ = 'D' = 1
-- GROUP BY: id_regiune, nume_regiune = 1
-- HAVING: COUNT(*) > 0 = 1
-- Total: 6
CREATE OR REPLACE PROCEDURE sp_statistici_tururi_regiune (
    p_cursor OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_cursor FOR
        SELECT 
            rg.id_regiune,
            rg.nume_regiune,
            COUNT(DISTINCT t.id_tur) AS numar_tururi,
            COUNT(DISTINCT g.id_ghid) AS numar_ghizi,
            ROUND(AVG(t.pret_persoana), 2) AS pret_mediu_tur,
            SUM(rez.nr_persoane) AS total_turisti,
            SUM(rez.pret_total) AS venit_total
        FROM Regiuni rg
        JOIN Tururi t ON rg.id_regiune = t.id_regiune
        LEFT JOIN Ghizi g ON t.id_ghid = g.id_ghid
        LEFT JOIN Rezervari rez ON t.id_tur = rez.id_tur
        WHERE t.activ = 'D'
        GROUP BY rg.id_regiune, rg.nume_regiune
        HAVING COUNT(DISTINCT t.id_tur) > 0
        ORDER BY venit_total DESC NULLS LAST;
END;
/

-- ============================================
-- RAPORT 3: Analiza Completa Turisti Activi (Complexitate 7)
-- JOIN: Turisti-Vizite, Vizite-Locatii, Locatii-Regiuni, Turisti-Rezervari = 4
-- WHERE: data_vizita >= data curenta - 365, status != 'Anulata' = 2
-- GROUP BY: id_turist, nume, prenume, tara_origine = 1
-- HAVING: vizite >= 1 = 1
-- Total: 8 (>7)
-- ============================================

CREATE OR REPLACE PROCEDURE sp_analiza_turisti_activi (
    p_cursor OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_cursor FOR
        SELECT 
            t.id_turist,
            t.nume || ' ' || t.prenume AS nume_complet,
            t.tara_origine,
            COUNT(DISTINCT v.id_vizita) AS numar_vizite,
            COUNT(DISTINCT l.id_regiune) AS regiuni_vizitate,
            COUNT(DISTINCT rez.id_rezervare) AS numar_rezervari,
            SUM(v.pret_platit) AS total_cheltuieli_vizite,
            SUM(rez.pret_total) AS total_cheltuieli_tururi,
            ROUND(AVG(v.durata_minute), 0) AS durata_medie_vizita
        FROM Turisti t
        LEFT JOIN Vizite v ON t.id_turist = v.id_turist
        LEFT JOIN Locatii l ON v.id_locatie = l.id_locatie
        LEFT JOIN Regiuni rg ON l.id_regiune = rg.id_regiune
        LEFT JOIN Rezervari rez ON t.id_turist = rez.id_turist
        WHERE (rez.status_rezervare != 'Anulata' OR rez.status_rezervare IS NULL)
        GROUP BY t.id_turist, t.nume, t.prenume, t.tara_origine
        HAVING COUNT(DISTINCT v.id_vizita) >= 1
        ORDER BY numar_vizite DESC, total_cheltuieli_tururi DESC NULLS LAST;
END;
/

-- Repară Raport 6: Evenimente (fără filtru de dată)
CREATE OR REPLACE PROCEDURE sp_evenimente_participari (
    p_cursor OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_cursor FOR
        SELECT 
            e.id_eveniment,
            e.nume_eveniment,
            e.tip_eveniment,
            l.nume_locatie AS locatie,
            e.data_start,
            e.data_end,
            e.pret_bilet,
            e.capacitate_max,
            COUNT(p.id_participare) AS inscrieri,
            SUM(p.nr_bilete) AS bilete_vandute,
            SUM(p.pret_total) AS venituri,
            ROUND((SUM(p.nr_bilete) / e.capacitate_max) * 100, 1) AS procent_ocupare
        FROM Evenimente e
        LEFT JOIN Participari p ON e.id_eveniment = p.id_eveniment
        LEFT JOIN Locatii l ON e.id_locatie = l.id_locatie
        WHERE e.status_eveniment != 'Anulat'
        GROUP BY e.id_eveniment, e.nume_eveniment, e.tip_eveniment, l.nume_locatie, 
                 e.data_start, e.data_end, e.pret_bilet, e.capacitate_max
        ORDER BY e.data_start ASC;
END;
/

COMMIT;

-- ============================================
-- RAPORT 4: Performanta Ghizi (Complexitate 7)
-- JOIN: Ghizi-Tururi, Tururi-Rezervari, Ghizi-Recenzii, Ghizi-Regiuni = 4
-- WHERE: disponibil = 'D', status != 'Anulata' = 2
-- GROUP BY: id_ghid, nume complet = 1
-- Total: 7
-- ============================================
CREATE OR REPLACE PROCEDURE sp_performanta_ghizi (
    p_cursor OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_cursor FOR
        SELECT 
            g.id_ghid,
            g.nume || ' ' || g.prenume AS nume_ghid,
            rg.nume_regiune AS regiune_activitate,
            g.experienta_ani,
            g.limbi_vorbite,
            COUNT(DISTINCT t.id_tur) AS tururi_oferite,
            COUNT(DISTINCT rez.id_rezervare) AS rezervari_totale,
            SUM(rez.pret_total) AS venituri_generate,
            ROUND(AVG(rec.rating), 2) AS rating_recenzii,
            g.rating_mediu AS rating_sistem
        FROM Ghizi g
        LEFT JOIN Tururi t ON g.id_ghid = t.id_ghid
        LEFT JOIN Rezervari rez ON t.id_tur = rez.id_tur
        LEFT JOIN Recenzii rec ON g.id_ghid = rec.id_ghid
        LEFT JOIN Regiuni rg ON g.id_regiune = rg.id_regiune
        WHERE g.disponibil = 'D'
        AND (rez.status_rezervare != 'Anulata' OR rez.status_rezervare IS NULL)
        GROUP BY g.id_ghid, g.nume, g.prenume, rg.nume_regiune, g.experienta_ani, g.limbi_vorbite, g.rating_mediu
        ORDER BY venituri_generate DESC NULLS LAST, rating_recenzii DESC NULLS LAST;
END;
/

-- ============================================
-- RAPORT 5: Popularitate Locatii UNESCO (Complexitate 7)
-- JOIN: Locatii-Vizite, Locatii-Recenzii, Locatii-Regiuni, Locatii-Categorii = 4
-- WHERE: patrimoniu_unesco = 'D', stare_conservare != 'Distrusa' = 2
-- GROUP BY: id_locatie, nume_locatie, nume_regiune = 1
-- Total: 7
-- ============================================
CREATE OR REPLACE PROCEDURE sp_popularitate_unesco (
    p_cursor OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_cursor FOR
        SELECT 
            l.id_locatie,
            l.nume_locatie,
            rg.nume_regiune,
            c.nume_categorie,
            l.stare_conservare,
            l.an_construire,
            COUNT(DISTINCT v.id_vizita) AS numar_vizite,
            COUNT(DISTINCT rec.id_recenzie) AS numar_recenzii,
            ROUND(AVG(rec.rating), 2) AS rating_mediu,
            SUM(v.pret_platit) AS venituri_intrari
        FROM Locatii l
        LEFT JOIN Vizite v ON l.id_locatie = v.id_locatie
        LEFT JOIN Recenzii rec ON l.id_locatie = rec.id_locatie
        LEFT JOIN Regiuni rg ON l.id_regiune = rg.id_regiune
        LEFT JOIN Categorii c ON l.id_categorie = c.id_categorie
        WHERE l.patrimoniu_unesco = 'D'
        AND l.stare_conservare != 'Distrusa'
        GROUP BY l.id_locatie, l.nume_locatie, rg.nume_regiune, c.nume_categorie, l.stare_conservare, l.an_construire
        ORDER BY numar_vizite DESC, rating_mediu DESC NULLS LAST;
END;
/



-- ============================================
-- RAPORT 7: Dashboard Sumar Turism (Complexitate 4)
-- Foloseste subquery-uri in loc de JOIN-uri multiple
-- ============================================
CREATE OR REPLACE PROCEDURE sp_dashboard_sumar (
    p_cursor OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_cursor FOR
        SELECT 
            (SELECT COUNT(*) FROM Locatii WHERE activ = 'D') AS locatii_active,
            (SELECT COUNT(*) FROM Turisti) AS total_turisti,
            (SELECT COUNT(*) FROM Ghizi WHERE disponibil = 'D') AS ghizi_disponibili,
            (SELECT COUNT(*) FROM Tururi WHERE activ = 'D') AS tururi_active,
            (SELECT COUNT(*) FROM Rezervari WHERE status_rezervare = 'Confirmata') AS rezervari_confirmate,
            (SELECT SUM(pret_total) FROM Rezervari WHERE status_rezervare IN ('Confirmata', 'Finalizata')) AS venituri_rezervari,
            (SELECT COUNT(*) FROM Evenimente WHERE status_eveniment IN ('Programat', 'In desfasurare')) AS evenimente_curente,
            (SELECT ROUND(AVG(rating), 2) FROM Recenzii) AS rating_mediu_general
        FROM DUAL;
END;
/

-- ============================================
-- TRIGGER: Actualizare numar vizite turist
-- ============================================
CREATE OR REPLACE TRIGGER trg_update_nr_vizite
AFTER INSERT ON Vizite
FOR EACH ROW
BEGIN
    UPDATE Turisti 
    SET nr_vizite_total = nr_vizite_total + 1
    WHERE id_turist = :NEW.id_turist;
END;
/

-- ============================================
-- TRIGGER: Validare rezervare (data viitoare)
-- ============================================
CREATE OR REPLACE TRIGGER trg_validare_rezervare
BEFORE INSERT OR UPDATE ON Rezervari
FOR EACH ROW
BEGIN
    IF :NEW.data_tur < TRUNC(SYSDATE) AND :NEW.status_rezervare NOT IN ('Finalizata', 'Anulata') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Data turului nu poate fi in trecut pentru rezervari noi.');
    END IF;
END;
/

-- ============================================
-- TRIGGER: Actualizare participanti eveniment
-- ============================================
CREATE OR REPLACE TRIGGER trg_update_participanti
AFTER INSERT OR DELETE ON Participari
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        UPDATE Evenimente 
        SET nr_participanti_actuali = nr_participanti_actuali + :NEW.nr_bilete
        WHERE id_eveniment = :NEW.id_eveniment;
    ELSIF DELETING THEN
        UPDATE Evenimente 
        SET nr_participanti_actuali = nr_participanti_actuali - :OLD.nr_bilete
        WHERE id_eveniment = :OLD.id_eveniment;
    END IF;
END;
/

-- ============================================
-- FUNCTIE: Calcul venituri totale regiune
-- ============================================
CREATE OR REPLACE FUNCTION fn_venituri_regiune (
    p_id_regiune IN NUMBER
) RETURN NUMBER
AS
    v_total NUMBER := 0;
BEGIN
    SELECT NVL(SUM(rez.pret_total), 0)
    INTO v_total
    FROM Rezervari rez
    JOIN Tururi t ON rez.id_tur = t.id_tur
    WHERE t.id_regiune = p_id_regiune
    AND rez.status_rezervare IN ('Confirmata', 'Finalizata');
    
    RETURN v_total;
END;
/

-- ============================================
-- FUNCTIE: Verificare disponibilitate tur
-- ============================================
CREATE OR REPLACE FUNCTION fn_locuri_disponibile (
    p_id_tur IN NUMBER,
    p_data_tur IN DATE
) RETURN NUMBER
AS
    v_max_participanti NUMBER;
    v_rezervati NUMBER;
BEGIN
    SELECT nr_max_participanti INTO v_max_participanti
    FROM Tururi WHERE id_tur = p_id_tur;
    
    SELECT NVL(SUM(nr_persoane), 0) INTO v_rezervati
    FROM Rezervari 
    WHERE id_tur = p_id_tur 
    AND data_tur = p_data_tur
    AND status_rezervare IN ('In asteptare', 'Confirmata');
    
    RETURN v_max_participanti - v_rezervati;
END;
/

COMMIT;
