-- ============================================
-- SCRIPT POPULARE CORECT (ID-uri Explicite)
-- ============================================

-- 1. Curatenie (Stergem datele vechi in ordine inversa dependentelor)
DELETE FROM Recenzii;
DELETE FROM Participari;
DELETE FROM Evenimente;
DELETE FROM Vizite;
DELETE FROM Rezervari;
DELETE FROM Tururi;
DELETE FROM Ghizi;
DELETE FROM Turisti;
DELETE FROM Locatii;
DELETE FROM Categorii;
DELETE FROM Regiuni;

-- 2. Inserare Date cu ID-uri FIXE (Nu folosim secvente aici pentru a garanta legaturile)

-- REGIUNI (ID 1-7)
INSERT INTO Regiuni (id_regiune, nume_regiune, descriere, populatie, suprafata_km2, capitala, data_adaugare) 
VALUES (1, 'Damasc', 'Capitala Siriei', 2500000, 105, 'Damasc', SYSDATE);
INSERT INTO Regiuni VALUES (2, 'Alep', 'Centru comercial istoric', 1800000, 190, 'Alep', SYSDATE);
INSERT INTO Regiuni VALUES (3, 'Homs', 'Centru industrial', 800000, 10000, 'Homs', SYSDATE);
INSERT INTO Regiuni VALUES (4, 'Latakia', 'Port la Mediterana', 400000, 2297, 'Latakia', SYSDATE);
INSERT INTO Regiuni VALUES (5, 'Palmira', 'Regiune desertica', 50000, 8000, 'Tadmur', SYSDATE);
INSERT INTO Regiuni VALUES (6, 'Deir ez-Zor', 'Malul Eufratului', 300000, 33000, 'Deir ez-Zor', SYSDATE);
INSERT INTO Regiuni VALUES (7, 'Bosra', 'Oras antic', 30000, 1500, 'Bosra', SYSDATE);

-- CATEGORII (ID 1-8)
INSERT INTO Categorii VALUES (1, 'Sit Arheologic', 'Ruine antice', '/icon1.png');
INSERT INTO Categorii VALUES (2, 'Muzeu', 'Istorie si cultura', '/icon2.png');
INSERT INTO Categorii VALUES (3, 'Moschee', 'Religios', '/icon3.png');
INSERT INTO Categorii VALUES (4, 'Biserica', 'Crestin', '/icon4.png');
INSERT INTO Categorii VALUES (5, 'Cetate', 'Fortificatii', '/icon5.png');
INSERT INTO Categorii VALUES (6, 'Bazar', 'Piete', '/icon6.png');
INSERT INTO Categorii VALUES (7, 'Palat', 'Resedinte istorice', '/icon7.png');
INSERT INTO Categorii VALUES (8, 'Monument Natural', 'Natura', '/icon8.png');

-- LOCATII (ID 1-15)
-- Observa ca id_regiune (col 3) si id_categorie (col 4) se potrivesc cu ID-urile de mai sus
INSERT INTO Locatii VALUES (1, 'Moscheea Umayyad', 1, 3, 'Marea moschee', 'Damasc', 33.5, 36.3, 0, '09-18', 705, 'D', 'Buna', SYSDATE, 'D');
INSERT INTO Locatii VALUES (2, 'Muzeul National', 1, 2, 'Artefacte', 'Damasc', 33.5, 36.2, 15, '09-17', 1919, 'N', 'Buna', SYSDATE, 'D');
INSERT INTO Locatii VALUES (3, 'Citadela Damascului', 1, 5, 'Fortificatie', 'Damasc', 33.5, 36.3, 10, '08-17', 1076, 'D', 'Medie', SYSDATE, 'D');
INSERT INTO Locatii VALUES (4, 'Bazarul Al-Hamidiyya', 1, 6, 'Bazar vechi', 'Damasc', 33.5, 36.3, 0, '10-22', 1780, 'N', 'Buna', SYSDATE, 'D');
INSERT INTO Locatii VALUES (5, 'Palatul Azm', 1, 7, 'Palat otoman', 'Damasc', 33.5, 36.3, 8, '09-16', 1749, 'D', 'Excelenta', SYSDATE, 'D');
INSERT INTO Locatii VALUES (6, 'Citadela Alep', 2, 5, 'Cetate veche', 'Alep', 36.1, 37.1, 12, '09-18', -3000, 'D', 'Deteriorata', SYSDATE, 'D');
INSERT INTO Locatii VALUES (7, 'Moscheea Alep', 2, 3, 'Moschee istorica', 'Alep', 36.1, 37.1, 0, '06-21', 715, 'D', 'Deteriorata', SYSDATE, 'D');
INSERT INTO Locatii VALUES (8, 'Bazarul Alep', 2, 6, 'Bazar lung', 'Alep', 36.1, 37.1, 0, '09-21', 1300, 'D', 'Medie', SYSDATE, 'D');
INSERT INTO Locatii VALUES (9, 'Templul lui Bel', 5, 1, 'Ruine templu', 'Palmira', 34.5, 38.2, 20, '08-17', 32, 'D', 'Distrusa', SYSDATE, 'D');
INSERT INTO Locatii VALUES (10, 'Teatrul Roman Palmira', 5, 1, 'Amfiteatru', 'Palmira', 34.5, 38.2, 15, '08-17', 200, 'D', 'Deteriorata', SYSDATE, 'D');
INSERT INTO Locatii VALUES (11, 'Colonada Palmira', 5, 1, 'Strada antica', 'Palmira', 34.5, 38.2, 15, '08-17', 200, 'D', 'Medie', SYSDATE, 'D');
INSERT INTO Locatii VALUES (12, 'Teatrul Bosra', 7, 1, 'Teatru conservat', 'Bosra', 32.5, 36.4, 18, '09-17', 150, 'D', 'Excelenta', SYSDATE, 'D');
INSERT INTO Locatii VALUES (13, 'Castelul Saladin', 4, 5, 'Cetate munte', 'Latakia', 35.6, 36.0, 15, '09-17', 1132, 'D', 'Buna', SYSDATE, 'D');
INSERT INTO Locatii VALUES (14, 'Ugarit', 4, 1, 'Sit alfabet', 'Latakia', 35.6, 35.7, 12, '08-16', -6000, 'D', 'Medie', SYSDATE, 'D');
INSERT INTO Locatii VALUES (15, 'Krak des Chevaliers', 3, 5, 'Cetate cruciata', 'Homs', 34.7, 36.2, 20, '09-18', 1031, 'D', 'Buna', SYSDATE, 'D');

-- TURISTI (ID 1-5)
INSERT INTO Turisti VALUES (1, 'Popescu', 'Ion', 'ion@test.com', '0722111222', 'Romania', SYSDATE-10000, 'M', 'Romana', SYSDATE, 0);
INSERT INTO Turisti VALUES (2, 'Smith', 'John', 'john@test.com', '0722333444', 'UK', SYSDATE-9000, 'M', 'Engleza', SYSDATE, 0);
INSERT INTO Turisti VALUES (3, 'Ivanov', 'Dmitri', 'dmitri@test.com', '0722555666', 'Rusia', SYSDATE-8000, 'M', 'Rusa', SYSDATE, 0);
INSERT INTO Turisti VALUES (4, 'Dupont', 'Marie', 'marie@test.com', '0722777888', 'Franta', SYSDATE-8500, 'F', 'Franceza', SYSDATE, 0);
INSERT INTO Turisti VALUES (5, 'Muller', 'Hans', 'hans@test.com', '0722999000', 'Germania', SYSDATE-9500, 'M', 'Germana', SYSDATE, 0);

-- GHIZI (ID 1-3)
INSERT INTO Ghizi VALUES (1, 'Omar', 'Sharif', 'omar@guide.com', '0999111', 'Araba, Engleza', 10, 4.8, 50, 1, 'Istorie', 'D', SYSDATE);
INSERT INTO Ghizi VALUES (2, 'Fatima', 'Al-Zahra', 'fatima@guide.com', '0999222', 'Araba, Franceza', 5, 4.9, 40, 2, 'Arta', 'D', SYSDATE);
INSERT INTO Ghizi VALUES (3, 'Youssef', 'Kamil', 'youssef@guide.com', '0999333', 'Araba, Germana', 8, 4.5, 45, 5, 'Arheologie', 'D', SYSDATE);

-- TURURI (ID 1-3)
INSERT INTO Tururi VALUES (1, 'Damasc Clasic', 'Tur de o zi', 1, 1, 8, 100, 10, 'Usor', 'D', 'D', SYSDATE, 'D');
INSERT INTO Tururi VALUES (2, 'Comorile Alepului', 'Tur complet', 2, 2, 6, 80, 15, 'Mediu', 'D', 'N', SYSDATE, 'D');
INSERT INTO Tururi VALUES (3, 'Misterele Palmira', 'Tur ruine', 3, 5, 10, 150, 12, 'Dificil', 'D', 'D', SYSDATE, 'D');

-- REZERVARI (ID 1-5)
INSERT INTO Rezervari VALUES (1, 1, 1, SYSDATE, SYSDATE+5, 2, 200, 'Confirmata', 'Card', 'VIP');
INSERT INTO Rezervari VALUES (2, 2, 2, SYSDATE, SYSDATE+10, 1, 80, 'Finalizata', 'Cash', NULL);
INSERT INTO Rezervari VALUES (3, 3, 3, SYSDATE, SYSDATE+15, 2, 300, 'In asteptare', 'Card', NULL);
INSERT INTO Rezervari VALUES (4, 1, 4, SYSDATE, SYSDATE+2, 1, 100, 'Finalizata', 'Card', NULL);
INSERT INTO Rezervari VALUES (5, 2, 5, SYSDATE, SYSDATE+7, 4, 320, 'Anulata', 'Transfer', 'Anulat de client');

-- VIZITE (ID 1-5)
INSERT INTO Vizite VALUES (1, 1, 1, SYSDATE-5, 60, 'N', NULL, 0);
INSERT INTO Vizite VALUES (2, 1, 3, SYSDATE-4, 90, 'D', 1, 50);
INSERT INTO Vizite VALUES (3, 2, 6, SYSDATE-10, 120, 'D', 2, 40);
INSERT INTO Vizite VALUES (4, 4, 1, SYSDATE-2, 45, 'N', NULL, 0);
INSERT INTO Vizite VALUES (5, 5, 9, SYSDATE-20, 180, 'D', 3, 100);

-- EVENIMENTE (ID 1-2)
INSERT INTO Evenimente VALUES (1, 'Concert Umayyad', 'Muzica sacra', 1, SYSDATE+30, SYSDATE+30, 50, 200, 0, 'Concert', 'Min. Cultura', 'Programat');
INSERT INTO Evenimente VALUES (2, 'Festival Alep', 'Gastronomie', 6, SYSDATE+60, SYSDATE+65, 0, 1000, 0, 'Festival', 'Primaria', 'Programat');

-- PARTICIPARI (ID 1-2)
INSERT INTO Participari VALUES (1, 1, 1, SYSDATE, 2, 100, 'Inscrisa');
INSERT INTO Participari VALUES (2, 2, 2, SYSDATE, 1, 0, 'Confirmata');

-- RECENZII (ID 1-3)
INSERT INTO Recenzii VALUES (1, 1, 1, NULL, NULL, 5, 'Superb', 'Moscheea este incredibila', SYSDATE, 10, 'D');
INSERT INTO Recenzii VALUES (2, 2, 6, NULL, NULL, 4, 'Interesant', 'Cetatea e frumoasa dar in renovare', SYSDATE, 5, 'D');
INSERT INTO Recenzii VALUES (3, 4, NULL, NULL, 1, 5, 'Ghid bun', 'Omar stie multa istorie', SYSDATE, 8, 'D');

-- 3. Resetam secventele ca sa continue de la ultimul ID folosit (Optional, dar recomandat)
-- 3. Resetam secventele (Formatat corect: cate o comanda pe linie)
DROP SEQUENCE seq_regiuni;
CREATE SEQUENCE seq_regiuni START WITH 8;

DROP SEQUENCE seq_categorii;
CREATE SEQUENCE seq_categorii START WITH 9;

DROP SEQUENCE seq_locatii;
CREATE SEQUENCE seq_locatii START WITH 16;

DROP SEQUENCE seq_turisti;
CREATE SEQUENCE seq_turisti START WITH 6;

DROP SEQUENCE seq_ghizi;
CREATE SEQUENCE seq_ghizi START WITH 4;

DROP SEQUENCE seq_tururi;
CREATE SEQUENCE seq_tururi START WITH 4;

DROP SEQUENCE seq_rezervari;
CREATE SEQUENCE seq_rezervari START WITH 6;

DROP SEQUENCE seq_vizite;
CREATE SEQUENCE seq_vizite START WITH 6;

DROP SEQUENCE seq_evenimente;
CREATE SEQUENCE seq_evenimente START WITH 3;

DROP SEQUENCE seq_participari;
CREATE SEQUENCE seq_participari START WITH 3;

DROP SEQUENCE seq_recenzii;
CREATE SEQUENCE seq_recenzii START WITH 4;

COMMIT;

COMMIT;