
SISTEM DISTRIBUIT PENTRU CULTURA SI TURISM - SIRIA

Proiect Baze de Date 2
Universitatea Politehnica Bucuresti
Anul Universitar 2025-2026


CUPRINS
-------
1. Descriere Proiect
2. Structura Fisiere
3. Cerinte Sistem
4. Instalare si Configurare
5. Rulare Aplicatie
6. Structura Baza de Date
7. Rapoarte Disponibile

1. DESCRIERE PROIECT


Acest proiect implementeaza un sistem de gestiune pentru cultura si turism
focusat pe patrimoniul cultural al Siriei. Sistemul permite:

- Gestionarea locatiilor turistice si culturale
- Administrarea tururilor organizate si rezervarilor
- Evidenta turistilor si ghizilor
- Gestionarea evenimentelor culturale
- Generarea de rapoarte si statistici

2. STRUCTURA FISIERE


proiect_bd2/
├── sql/
│   ├── create/
│   │   └── 01_create_tables.sql    # Script creare tabele
│   ├── populate/
│   │   └── 02_populate_data.sql    # Script populare date
│   └── procedures/
│       └── 03_procedures.sql       # Proceduri stocate si triggere
├── app/
│   ├── main.py                     # Aplicatia principala (consola)
│   ├── gui.py                      # Interfata grafica Tkinter
│   └── models.py                   # Modele de date
|   └── (grafice generate)
├── docs/
│   └── (documentatie PDF)
│ 
├── requirements.txt                # Dependente Python
└── README.txt                      

3. CERINTE SISTEM

Software necesar:
- Python 3.10 sau mai nou
- Oracle Database XE 21c sau SQL Server 2019+
- Oracle Instant Client (pentru Oracle)
- ODBC Driver 17 for SQL Server (pentru SQL Server)

4. INSTALARE SI CONFIGURARE

PASUL 1: Instalare dependente Python
------------------------------------
pip install -r requirements.txt

PASUL 2: Configurare Baza de Date
---------------------------------

Pentru Oracle:
1. Porniti Oracle Database
2. Conectati-va cu un utilizator cu drepturi DBA
3. Creati un utilizator nou:
   
   CREATE USER turism_siria IDENTIFIED BY parola;
   GRANT CONNECT, RESOURCE, CREATE SESSION TO turism_siria;
   GRANT UNLIMITED TABLESPACE TO turism_siria;

Pentru SQL Server:
1. Creati o baza de date noua: TurismSiria
2. Creati un login cu acces la aceasta baza

PASUL 3: Executare Scripturi SQL
--------------------------------
Executati scripturile in ordine:

1. sql/create/01_create_tables.sql
2. sql/populate/02_populate_data.sql
3. sql/procedures/03_procedures.sql

PASUL 4: Configurare Variabile de Mediu
---------------------------------------
Setati urmatoarele variabile de mediu:

Windows (Command Prompt):
set DB_TYPE=oracle
set DB_HOST=localhost
set DB_PORT=1521
set DB_NAME=XEPDB1
set DB_USER=turism_siria
set DB_PASSWORD=parola

Linux/Mac:
export DB_TYPE=oracle
export DB_HOST=localhost
export DB_PORT=1521
export DB_NAME=XEPDB1
export DB_USER=turism_siria
export DB_PASSWORD=parola

================================================================================
5. RULARE APLICATIE
================================================================================

Aplicatia Consola:
------------------
cd app
python main.py

Mod Demo (fara baza de date):
python main.py --demo

Interfata Grafica:
------------------
cd app
python gui.py

================================================================================
6. STRUCTURA BAZA DE DATE
================================================================================

Tabele (11 total):
------------------
1. Regiuni          - Regiuni geografice ale Siriei
2. Categorii        - Tipuri de locatii (muzeu, moschee, cetate, etc.)
3. Locatii          - Situri turistice si culturale
4. Turisti          - Informatii despre vizitatori
5. Ghizi            - Ghizi turistici
6. Tururi           - Tururi organizate
7. Rezervari        - Rezervari pentru tururi
8. Vizite           - Vizite individuale la locatii
9. Evenimente       - Evenimente culturale
10. Participari     - Participari la evenimente
11. Recenzii        - Recenzii de la turisti

Relatii principale:
-------------------
- Locatii -> Regiuni, Categorii
- Tururi -> Regiuni, Ghizi
- Rezervari -> Tururi, Turisti
- Vizite -> Locatii, Turisti, Ghizi
- Evenimente -> Locatii
- Participari -> Evenimente, Turisti
- Recenzii -> Turisti, Locatii/Tururi/Ghizi

================================================================================
7. RAPOARTE DISPONIBILE
================================================================================

Raport 1: Top Locatii dupa Rating (Complexitate 4)
- Afiseaza locatiile ordonate dupa rating mediu
- Include numar recenzii si voturi utile

Raport 2: Statistici Tururi pe Regiune (Complexitate 6)
- Statistici agregate pe regiuni
- Include numar tururi, ghizi, venituri totale

Raport 3: Analiza Turisti Activi (Complexitate 8)
- Turisti cu activitate in ultimul an
- Include vizite, rezervari, cheltuieli

Raport 4: Performanta Ghizi (Complexitate 7)
- Evaluarea ghizilor dupa venituri si rating
- Include tururi oferite si rezervari

Raport 5: Popularitate Situri UNESCO (Complexitate 7)
- Focus pe siturile patrimoniu UNESCO
- Include vizite, recenzii, venituri

Raport 6: Evenimente si Participari (Complexitate 5)
- Lista evenimente curente/viitoare
- Include participari si procent ocupare

Raport 7: Dashboard Sumar (Complexitate 4)
- Metrici generale ale sistemului
- Foloseste subquery-uri multiple

