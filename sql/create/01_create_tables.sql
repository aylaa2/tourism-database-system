-- ============================================
-- SISTEM DISTRIBUIT PENTRU CULTURA SI TURISM - SIRIA
-- FORCE RESET & CREATE (11 Tabele)
-- ============================================

-- 1. DROP OLD TABLES (Force Clean)
-- Ignoram erorile "table does not exist" aici, vrem doar sa fim siguri ca dispar.
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Recenzii CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Participari CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Evenimente CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Vizite CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Rezervari CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Tururi CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Ghizi CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Turisti CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Locatii CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Categorii CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Regiuni CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Also drop old simple project tables just in case
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE PACHET_HOTEL CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE PACHETE_TURISTICE CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE HOTELURI CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE OBIECTIVE_TURISTICE CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE ORASE CASCADE CONSTRAINTS';
    EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- 2. DROP OLD SEQUENCES
BEGIN
    FOR s IN (SELECT sequence_name FROM user_sequences) LOOP
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
    END LOOP;
END;
/

-- 3. CREATE SEQUENCES
CREATE SEQUENCE seq_regiuni START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_categorii START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_locatii START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_turisti START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ghizi START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_tururi START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_rezervari START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_vizite START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_evenimente START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_participari START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_recenzii START WITH 1 INCREMENT BY 1;

-- 4. CREATE TABLES (Correct 11-Table Structure)

CREATE TABLE Regiuni (
    id_regiune NUMBER(5) PRIMARY KEY,
    nume_regiune VARCHAR2(100) UNIQUE,
    descriere VARCHAR2(500),
    populatie NUMBER(10),
    suprafata_km2 NUMBER(10,2),
    capitala VARCHAR2(100),
    data_adaugare DATE DEFAULT SYSDATE
);

CREATE TABLE Categorii (
    id_categorie NUMBER(5) PRIMARY KEY,
    nume_categorie VARCHAR2(100) UNIQUE,
    descriere VARCHAR2(500),
    icon_path VARCHAR2(255)
);

CREATE TABLE Locatii (
    id_locatie NUMBER(5) PRIMARY KEY,
    nume_locatie VARCHAR2(200),
    id_regiune NUMBER(5),
    id_categorie NUMBER(5),
    descriere VARCHAR2(2000),
    adresa VARCHAR2(300),
    latitudine NUMBER(10,7),
    longitudine NUMBER(10,7),
    pret_intrare NUMBER(10,2) DEFAULT 0,
    program_lucru VARCHAR2(100),
    an_construire NUMBER(5),
    patrimoniu_unesco CHAR(1) DEFAULT 'N',
    stare_conservare VARCHAR2(50),
    data_adaugare DATE DEFAULT SYSDATE,
    activ CHAR(1) DEFAULT 'D',
    CONSTRAINT fk_loc_reg FOREIGN KEY (id_regiune) REFERENCES Regiuni(id_regiune),
    CONSTRAINT fk_loc_cat FOREIGN KEY (id_categorie) REFERENCES Categorii(id_categorie)
);

CREATE TABLE Turisti (
    id_turist NUMBER(5) PRIMARY KEY,
    nume VARCHAR2(100),
    prenume VARCHAR2(100),
    email VARCHAR2(150) UNIQUE,
    telefon VARCHAR2(20),
    tara_origine VARCHAR2(100),
    data_nastere DATE,
    sex CHAR(1),
    limba_preferata VARCHAR2(50) DEFAULT 'Engleza',
    data_inregistrare DATE DEFAULT SYSDATE,
    nr_vizite_total NUMBER(5) DEFAULT 0
);

CREATE TABLE Ghizi (
    id_ghid NUMBER(5) PRIMARY KEY,
    nume VARCHAR2(100),
    prenume VARCHAR2(100),
    email VARCHAR2(150) UNIQUE,
    telefon VARCHAR2(20),
    limbi_vorbite VARCHAR2(200),
    experienta_ani NUMBER(2),
    rating_mediu NUMBER(3,2),
    pret_ora NUMBER(10,2),
    id_regiune NUMBER(5),
    specializare VARCHAR2(200),
    disponibil CHAR(1) DEFAULT 'D',
    data_angajare DATE DEFAULT SYSDATE,
    CONSTRAINT fk_ghizi_reg FOREIGN KEY (id_regiune) REFERENCES Regiuni(id_regiune)
);

CREATE TABLE Tururi (
    id_tur NUMBER(5) PRIMARY KEY,
    nume_tur VARCHAR2(200),
    descriere VARCHAR2(1000),
    id_ghid NUMBER(5),
    id_regiune NUMBER(5),
    durata_ore NUMBER(4,1),
    pret_persoana NUMBER(10,2),
    nr_max_participanti NUMBER(3),
    nivel_dificultate VARCHAR2(20),
    include_transport CHAR(1),
    include_masa CHAR(1),
    data_creare DATE DEFAULT SYSDATE,
    activ CHAR(1) DEFAULT 'D',
    CONSTRAINT fk_tur_ghid FOREIGN KEY (id_ghid) REFERENCES Ghizi(id_ghid),
    CONSTRAINT fk_tur_reg FOREIGN KEY (id_regiune) REFERENCES Regiuni(id_regiune)
);

CREATE TABLE Rezervari (
    id_rezervare NUMBER(10) PRIMARY KEY,
    id_tur NUMBER(5),
    id_turist NUMBER(5),
    data_rezervare DATE DEFAULT SYSDATE,
    data_tur DATE,
    nr_persoane NUMBER(3),
    pret_total NUMBER(10,2),
    status_rezervare VARCHAR2(20),
    metoda_plata VARCHAR2(50),
    observatii VARCHAR2(500),
    CONSTRAINT fk_rez_tur FOREIGN KEY (id_tur) REFERENCES Tururi(id_tur),
    CONSTRAINT fk_rez_turist FOREIGN KEY (id_turist) REFERENCES Turisti(id_turist)
);

CREATE TABLE Vizite (
    id_vizita NUMBER(10) PRIMARY KEY,
    id_turist NUMBER(5),
    id_locatie NUMBER(5),
    data_vizita DATE,
    durata_minute NUMBER(4),
    cu_ghid CHAR(1),
    id_ghid NUMBER(5),
    pret_platit NUMBER(10,2),
    CONSTRAINT fk_viz_turist FOREIGN KEY (id_turist) REFERENCES Turisti(id_turist),
    CONSTRAINT fk_viz_loc FOREIGN KEY (id_locatie) REFERENCES Locatii(id_locatie),
    CONSTRAINT fk_viz_ghid FOREIGN KEY (id_ghid) REFERENCES Ghizi(id_ghid)
);

CREATE TABLE Evenimente (
    id_eveniment NUMBER(5) PRIMARY KEY,
    nume_eveniment VARCHAR2(200),
    descriere VARCHAR2(1000),
    id_locatie NUMBER(5),
    data_start DATE,
    data_end DATE,
    pret_bilet NUMBER(10,2) DEFAULT 0,
    capacitate_max NUMBER(5),
    nr_participanti_actuali NUMBER(5),
    tip_eveniment VARCHAR2(100),
    organizator VARCHAR2(200),
    status_eveniment VARCHAR2(20),
    CONSTRAINT fk_ev_loc FOREIGN KEY (id_locatie) REFERENCES Locatii(id_locatie)
);

CREATE TABLE Participari (
    id_participare NUMBER(10) PRIMARY KEY,
    id_eveniment NUMBER(5),
    id_turist NUMBER(5),
    data_inscriere DATE DEFAULT SYSDATE,
    nr_bilete NUMBER(3),
    pret_total NUMBER(10,2),
    status_participare VARCHAR2(20),
    CONSTRAINT fk_part_ev FOREIGN KEY (id_eveniment) REFERENCES Evenimente(id_eveniment),
    CONSTRAINT fk_part_tur FOREIGN KEY (id_turist) REFERENCES Turisti(id_turist),
    CONSTRAINT uk_participare UNIQUE (id_eveniment, id_turist)
);

CREATE TABLE Recenzii (
    id_recenzie NUMBER(10) PRIMARY KEY,
    id_turist NUMBER(5),
    id_locatie NUMBER(5),
    id_tur NUMBER(5),
    id_ghid NUMBER(5),
    rating NUMBER(1),
    titlu VARCHAR2(200),
    comentariu VARCHAR2(2000),
    data_recenzie DATE DEFAULT SYSDATE,
    util NUMBER(5),
    verificat CHAR(1),
    CONSTRAINT fk_rec_turist FOREIGN KEY (id_turist) REFERENCES Turisti(id_turist),
    CONSTRAINT fk_rec_loc FOREIGN KEY (id_locatie) REFERENCES Locatii(id_locatie),
    CONSTRAINT fk_rec_tur FOREIGN KEY (id_tur) REFERENCES Tururi(id_tur),
    CONSTRAINT fk_rec_ghid FOREIGN KEY (id_ghid) REFERENCES Ghizi(id_ghid)
);