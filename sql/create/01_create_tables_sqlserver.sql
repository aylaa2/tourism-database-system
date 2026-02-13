-- ============================================
-- SISTEM DISTRIBUIT PENTRU CULTURA SI TURISM - SIRIA
-- Script creare tabele - SQL SERVER
-- ============================================

-- Stergere tabele existente
IF OBJECT_ID('Recenzii', 'U') IS NOT NULL DROP TABLE Recenzii;
IF OBJECT_ID('Participari', 'U') IS NOT NULL DROP TABLE Participari;
IF OBJECT_ID('Evenimente', 'U') IS NOT NULL DROP TABLE Evenimente;
IF OBJECT_ID('Vizite', 'U') IS NOT NULL DROP TABLE Vizite;
IF OBJECT_ID('Rezervari', 'U') IS NOT NULL DROP TABLE Rezervari;
IF OBJECT_ID('Tururi', 'U') IS NOT NULL DROP TABLE Tururi;
IF OBJECT_ID('Ghizi', 'U') IS NOT NULL DROP TABLE Ghizi;
IF OBJECT_ID('Locatii', 'U') IS NOT NULL DROP TABLE Locatii;
IF OBJECT_ID('Categorii', 'U') IS NOT NULL DROP TABLE Categorii;
IF OBJECT_ID('Regiuni', 'U') IS NOT NULL DROP TABLE Regiuni;
IF OBJECT_ID('Turisti', 'U') IS NOT NULL DROP TABLE Turisti;
GO

-- ============================================
-- 1. REGIUNI
-- ============================================
CREATE TABLE Regiuni (
    id_regiune      INT IDENTITY(1,1) PRIMARY KEY,
    nume_regiune    NVARCHAR(100) NOT NULL UNIQUE,
    descriere       NVARCHAR(500),
    populatie       INT,
    suprafata_km2   DECIMAL(10,2),
    capitala        NVARCHAR(100),
    data_adaugare   DATE DEFAULT GETDATE()
);
GO

-- ============================================
-- 2. CATEGORII
-- ============================================
CREATE TABLE Categorii (
    id_categorie    INT IDENTITY(1,1) PRIMARY KEY,
    nume_categorie  NVARCHAR(100) NOT NULL UNIQUE,
    descriere       NVARCHAR(500),
    icon_path       NVARCHAR(255)
);
GO

-- ============================================
-- 3. LOCATII
-- ============================================
CREATE TABLE Locatii (
    id_locatie      INT IDENTITY(1,1) PRIMARY KEY,
    nume_locatie    NVARCHAR(200) NOT NULL,
    id_regiune      INT NOT NULL,
    id_categorie    INT NOT NULL,
    descriere       NVARCHAR(2000),
    adresa          NVARCHAR(300),
    latitudine      DECIMAL(10,7),
    longitudine     DECIMAL(10,7),
    pret_intrare    DECIMAL(10,2) DEFAULT 0,
    program_lucru   NVARCHAR(100),
    an_construire   INT,
    patrimoniu_unesco CHAR(1) DEFAULT 'N' CHECK (patrimoniu_unesco IN ('D', 'N')),
    stare_conservare NVARCHAR(50) CHECK (stare_conservare IN ('Excelenta', 'Buna', 'Medie', 'Deteriorata', 'Distrusa')),
    data_adaugare   DATE DEFAULT GETDATE(),
    activ           CHAR(1) DEFAULT 'D' CHECK (activ IN ('D', 'N')),
    CONSTRAINT fk_locatii_regiune FOREIGN KEY (id_regiune) REFERENCES Regiuni(id_regiune),
    CONSTRAINT fk_locatii_categorie FOREIGN KEY (id_categorie) REFERENCES Categorii(id_categorie)
);
GO

-- ============================================
-- 4. TURISTI
-- ============================================
CREATE TABLE Turisti (
    id_turist       INT IDENTITY(1,1) PRIMARY KEY,
    nume            NVARCHAR(100) NOT NULL,
    prenume         NVARCHAR(100) NOT NULL,
    email           NVARCHAR(150) UNIQUE,
    telefon         NVARCHAR(20),
    tara_origine    NVARCHAR(100),
    data_nastere    DATE,
    sex             CHAR(1) CHECK (sex IN ('M', 'F')),
    limba_preferata NVARCHAR(50) DEFAULT 'Engleza',
    data_inregistrare DATE DEFAULT GETDATE(),
    nr_vizite_total INT DEFAULT 0
);
GO

-- ============================================
-- 5. GHIZI
-- ============================================
CREATE TABLE Ghizi (
    id_ghid         INT IDENTITY(1,1) PRIMARY KEY,
    nume            NVARCHAR(100) NOT NULL,
    prenume         NVARCHAR(100) NOT NULL,
    email           NVARCHAR(150) UNIQUE,
    telefon         NVARCHAR(20) NOT NULL,
    limbi_vorbite   NVARCHAR(200),
    experienta_ani  INT DEFAULT 0,
    rating_mediu    DECIMAL(3,2) DEFAULT 0 CHECK (rating_mediu >= 0 AND rating_mediu <= 5),
    pret_ora        DECIMAL(10,2),
    id_regiune      INT,
    specializare    NVARCHAR(200),
    disponibil      CHAR(1) DEFAULT 'D' CHECK (disponibil IN ('D', 'N')),
    data_angajare   DATE DEFAULT GETDATE(),
    CONSTRAINT fk_ghizi_regiune FOREIGN KEY (id_regiune) REFERENCES Regiuni(id_regiune)
);
GO

-- ============================================
-- 6. TURURI
-- ============================================
CREATE TABLE Tururi (
    id_tur          INT IDENTITY(1,1) PRIMARY KEY,
    nume_tur        NVARCHAR(200) NOT NULL,
    descriere       NVARCHAR(1000),
    id_ghid         INT,
    id_regiune      INT NOT NULL,
    durata_ore      DECIMAL(4,1),
    pret_persoana   DECIMAL(10,2) NOT NULL,
    nr_max_participanti INT DEFAULT 20,
    nivel_dificultate NVARCHAR(20) CHECK (nivel_dificultate IN ('Usor', 'Mediu', 'Dificil')),
    include_transport CHAR(1) DEFAULT 'N' CHECK (include_transport IN ('D', 'N')),
    include_masa    CHAR(1) DEFAULT 'N' CHECK (include_masa IN ('D', 'N')),
    data_creare     DATE DEFAULT GETDATE(),
    activ           CHAR(1) DEFAULT 'D' CHECK (activ IN ('D', 'N')),
    CONSTRAINT fk_tururi_ghid FOREIGN KEY (id_ghid) REFERENCES Ghizi(id_ghid),
    CONSTRAINT fk_tururi_regiune FOREIGN KEY (id_regiune) REFERENCES Regiuni(id_regiune)
);
GO

-- ============================================
-- 7. REZERVARI
-- ============================================
CREATE TABLE Rezervari (
    id_rezervare    INT IDENTITY(1,1) PRIMARY KEY,
    id_tur          INT NOT NULL,
    id_turist       INT NOT NULL,
    data_rezervare  DATE DEFAULT GETDATE(),
    data_tur        DATE NOT NULL,
    nr_persoane     INT DEFAULT 1 CHECK (nr_persoane > 0),
    pret_total      DECIMAL(10,2),
    status_rezervare NVARCHAR(20) DEFAULT 'In asteptare' 
        CHECK (status_rezervare IN ('In asteptare', 'Confirmata', 'Anulata', 'Finalizata')),
    metoda_plata    NVARCHAR(50),
    observatii      NVARCHAR(500),
    CONSTRAINT fk_rezervari_tur FOREIGN KEY (id_tur) REFERENCES Tururi(id_tur),
    CONSTRAINT fk_rezervari_turist FOREIGN KEY (id_turist) REFERENCES Turisti(id_turist)
);
GO

-- ============================================
-- 8. VIZITE
-- ============================================
CREATE TABLE Vizite (
    id_vizita       INT IDENTITY(1,1) PRIMARY KEY,
    id_turist       INT NOT NULL,
    id_locatie      INT NOT NULL,
    data_vizita     DATE NOT NULL,
    durata_minute   INT,
    cu_ghid         CHAR(1) DEFAULT 'N' CHECK (cu_ghid IN ('D', 'N')),
    id_ghid         INT,
    pret_platit     DECIMAL(10,2),
    CONSTRAINT fk_vizite_turist FOREIGN KEY (id_turist) REFERENCES Turisti(id_turist),
    CONSTRAINT fk_vizite_locatie FOREIGN KEY (id_locatie) REFERENCES Locatii(id_locatie),
    CONSTRAINT fk_vizite_ghid FOREIGN KEY (id_ghid) REFERENCES Ghizi(id_ghid)
);
GO

-- ============================================
-- 9. EVENIMENTE
-- ============================================
CREATE TABLE Evenimente (
    id_eveniment    INT IDENTITY(1,1) PRIMARY KEY,
    nume_eveniment  NVARCHAR(200) NOT NULL,
    descriere       NVARCHAR(1000),
    id_locatie      INT,
    data_start      DATE NOT NULL,
    data_end        DATE,
    pret_bilet      DECIMAL(10,2) DEFAULT 0,
    capacitate_max  INT,
    nr_participanti_actuali INT DEFAULT 0,
    tip_eveniment   NVARCHAR(100),
    organizator     NVARCHAR(200),
    status_eveniment NVARCHAR(20) DEFAULT 'Programat'
        CHECK (status_eveniment IN ('Programat', 'In desfasurare', 'Finalizat', 'Anulat')),
    CONSTRAINT fk_evenimente_locatie FOREIGN KEY (id_locatie) REFERENCES Locatii(id_locatie)
);
GO

-- ============================================
-- 10. PARTICIPARI
-- ============================================
CREATE TABLE Participari (
    id_participare  INT IDENTITY(1,1) PRIMARY KEY,
    id_eveniment    INT NOT NULL,
    id_turist       INT NOT NULL,
    data_inscriere  DATE DEFAULT GETDATE(),
    nr_bilete       INT DEFAULT 1 CHECK (nr_bilete > 0),
    pret_total      DECIMAL(10,2),
    status_participare NVARCHAR(20) DEFAULT 'Inscrisa'
        CHECK (status_participare IN ('Inscrisa', 'Confirmata', 'Anulata', 'Participat')),
    CONSTRAINT fk_participari_eveniment FOREIGN KEY (id_eveniment) REFERENCES Evenimente(id_eveniment),
    CONSTRAINT fk_participari_turist FOREIGN KEY (id_turist) REFERENCES Turisti(id_turist),
    CONSTRAINT uk_participare UNIQUE (id_eveniment, id_turist)
);
GO

-- ============================================
-- 11. RECENZII
-- ============================================
CREATE TABLE Recenzii (
    id_recenzie     INT IDENTITY(1,1) PRIMARY KEY,
    id_turist       INT NOT NULL,
    id_locatie      INT,
    id_tur          INT,
    id_ghid         INT,
    rating          INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    titlu           NVARCHAR(200),
    comentariu      NVARCHAR(2000),
    data_recenzie   DATE DEFAULT GETDATE(),
    util            INT DEFAULT 0,
    verificat       CHAR(1) DEFAULT 'N' CHECK (verificat IN ('D', 'N')),
    CONSTRAINT fk_recenzii_turist FOREIGN KEY (id_turist) REFERENCES Turisti(id_turist),
    CONSTRAINT fk_recenzii_locatie FOREIGN KEY (id_locatie) REFERENCES Locatii(id_locatie),
    CONSTRAINT fk_recenzii_tur FOREIGN KEY (id_tur) REFERENCES Tururi(id_tur),
    CONSTRAINT fk_recenzii_ghid FOREIGN KEY (id_ghid) REFERENCES Ghizi(id_ghid)
);
GO

-- ============================================
-- INDECSI
-- ============================================
CREATE INDEX idx_locatii_regiune ON Locatii(id_regiune);
CREATE INDEX idx_locatii_categorie ON Locatii(id_categorie);
CREATE INDEX idx_tururi_regiune ON Tururi(id_regiune);
CREATE INDEX idx_rezervari_data ON Rezervari(data_tur);
CREATE INDEX idx_vizite_data ON Vizite(data_vizita);
CREATE INDEX idx_evenimente_data ON Evenimente(data_start);
CREATE INDEX idx_recenzii_rating ON Recenzii(rating);
GO

-- ============================================
-- PROCEDURI STOCATE SQL SERVER
-- ============================================

-- Raport 1: Top Locatii Rating (Complexitate 4)
CREATE PROCEDURE sp_top_locatii_rating
AS
BEGIN
    SELECT 
        l.id_locatie,
        l.nume_locatie,
        c.nume_categorie,
        COUNT(r.id_recenzie) AS numar_recenzii,
        ROUND(AVG(CAST(r.rating AS FLOAT)), 2) AS rating_mediu,
        SUM(r.util) AS total_voturi_utile
    FROM Locatii l
    JOIN Recenzii r ON l.id_locatie = r.id_locatie
    JOIN Categorii c ON l.id_categorie = c.id_categorie
    WHERE l.activ = 'D'
    GROUP BY l.id_locatie, l.nume_locatie, c.nume_categorie
    ORDER BY rating_mediu DESC, numar_recenzii DESC;
END;
GO

-- Raport 2: Statistici Tururi Regiune (Complexitate 6)
CREATE PROCEDURE sp_statistici_tururi_regiune
AS
BEGIN
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
    ORDER BY venit_total DESC;
END;
GO

-- Raport 7: Dashboard Sumar (Complexitate 4)
CREATE PROCEDURE sp_dashboard_sumar
AS
BEGIN
    SELECT 
        (SELECT COUNT(*) FROM Locatii WHERE activ = 'D') AS locatii_active,
        (SELECT COUNT(*) FROM Turisti) AS total_turisti,
        (SELECT COUNT(*) FROM Ghizi WHERE disponibil = 'D') AS ghizi_disponibili,
        (SELECT COUNT(*) FROM Tururi WHERE activ = 'D') AS tururi_active,
        (SELECT COUNT(*) FROM Rezervari WHERE status_rezervare = 'Confirmata') AS rezervari_confirmate,
        (SELECT SUM(pret_total) FROM Rezervari WHERE status_rezervare IN ('Confirmata', 'Finalizata')) AS venituri_rezervari,
        (SELECT COUNT(*) FROM Evenimente WHERE status_eveniment IN ('Programat', 'In desfasurare')) AS evenimente_curente,
        (SELECT ROUND(AVG(CAST(rating AS FLOAT)), 2) FROM Recenzii) AS rating_mediu_general;
END;
GO

PRINT 'Baza de date creata cu succes!';
