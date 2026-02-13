"""
SISTEM DISTRIBUIT PENTRU CULTURA SI TURISM - SIRIA
Modele de date

Acest modul contine clasele model pentru entitatile din baza de date.
"""

from dataclasses import dataclass, field
from datetime import date, datetime
from typing import Optional, List
from enum import Enum

# ============================================
# ENUMERARI
# ============================================

class StareConservare(Enum):
    EXCELENTA = "Excelenta"
    BUNA = "Buna"
    MEDIE = "Medie"
    DETERIORATA = "Deteriorata"
    DISTRUSA = "Distrusa"

class StatusRezervare(Enum):
    IN_ASTEPTARE = "In asteptare"
    CONFIRMATA = "Confirmata"
    ANULATA = "Anulata"
    FINALIZATA = "Finalizata"

class NivelDificultate(Enum):
    USOR = "Usor"
    MEDIU = "Mediu"
    DIFICIL = "Dificil"

class StatusEveniment(Enum):
    PROGRAMAT = "Programat"
    IN_DESFASURARE = "In desfasurare"
    FINALIZAT = "Finalizat"
    ANULAT = "Anulat"

# ============================================
# MODELE
# ============================================

@dataclass
class Regiune:
    """Model pentru regiuni geografice"""
    id_regiune: int
    nume_regiune: str
    descriere: Optional[str] = None
    populatie: Optional[int] = None
    suprafata_km2: Optional[float] = None
    capitala: Optional[str] = None
    data_adaugare: date = field(default_factory=date.today)
    
    def __str__(self):
        return f"{self.nume_regiune} (pop: {self.populatie:,})" if self.populatie else self.nume_regiune


@dataclass
class Categorie:
    """Model pentru categorii de locatii"""
    id_categorie: int
    nume_categorie: str
    descriere: Optional[str] = None
    icon_path: Optional[str] = None
    
    def __str__(self):
        return self.nume_categorie


@dataclass
class Locatie:
    """Model pentru locatii turistice si culturale"""
    id_locatie: int
    nume_locatie: str
    id_regiune: int
    id_categorie: int
    descriere: Optional[str] = None
    adresa: Optional[str] = None
    latitudine: Optional[float] = None
    longitudine: Optional[float] = None
    pret_intrare: float = 0.0
    program_lucru: Optional[str] = None
    an_construire: Optional[int] = None
    patrimoniu_unesco: bool = False
    stare_conservare: StareConservare = StareConservare.BUNA
    data_adaugare: date = field(default_factory=date.today)
    activ: bool = True
    
    # Relatii (populate manual dupa fetch)
    regiune: Optional[Regiune] = None
    categorie: Optional[Categorie] = None
    
    def __str__(self):
        unesco = " [UNESCO]" if self.patrimoniu_unesco else ""
        return f"{self.nume_locatie}{unesco}"
    
    @property
    def coordonate(self) -> Optional[tuple]:
        if self.latitudine and self.longitudine:
            return (self.latitudine, self.longitudine)
        return None


@dataclass
class Turist:
    """Model pentru turisti"""
    id_turist: int
    nume: str
    prenume: str
    email: Optional[str] = None
    telefon: Optional[str] = None
    tara_origine: Optional[str] = None
    data_nastere: Optional[date] = None
    sex: Optional[str] = None
    limba_preferata: str = "Engleza"
    data_inregistrare: date = field(default_factory=date.today)
    nr_vizite_total: int = 0
    
    def __str__(self):
        return f"{self.prenume} {self.nume}"
    
    @property
    def nume_complet(self) -> str:
        return f"{self.prenume} {self.nume}"
    
    @property
    def varsta(self) -> Optional[int]:
        if self.data_nastere:
            today = date.today()
            return today.year - self.data_nastere.year - (
                (today.month, today.day) < (self.data_nastere.month, self.data_nastere.day)
            )
        return None


@dataclass
class Ghid:
    """Model pentru ghizi turistici"""
    id_ghid: int
    nume: str
    prenume: str
    email: Optional[str] = None
    telefon: str = ""
    limbi_vorbite: Optional[str] = None
    experienta_ani: int = 0
    rating_mediu: float = 0.0
    pret_ora: Optional[float] = None
    id_regiune: Optional[int] = None
    specializare: Optional[str] = None
    disponibil: bool = True
    data_angajare: date = field(default_factory=date.today)
    
    # Relatii
    regiune: Optional[Regiune] = None
    
    def __str__(self):
        return f"{self.prenume} {self.nume} ({self.rating_mediu}★)"
    
    @property
    def limbi_list(self) -> List[str]:
        if self.limbi_vorbite:
            return [l.strip() for l in self.limbi_vorbite.split(',')]
        return []


@dataclass
class Tur:
    """Model pentru tururi organizate"""
    id_tur: int
    nume_tur: str
    id_regiune: int
    pret_persoana: float
    descriere: Optional[str] = None
    id_ghid: Optional[int] = None
    durata_ore: Optional[float] = None
    nr_max_participanti: int = 20
    nivel_dificultate: NivelDificultate = NivelDificultate.MEDIU
    include_transport: bool = False
    include_masa: bool = False
    data_creare: date = field(default_factory=date.today)
    activ: bool = True
    
    # Relatii
    ghid: Optional[Ghid] = None
    regiune: Optional[Regiune] = None
    
    def __str__(self):
        return f"{self.nume_tur} ({self.pret_persoana} USD)"


@dataclass
class Rezervare:
    """Model pentru rezervari"""
    id_rezervare: int
    id_tur: int
    id_turist: int
    data_tur: date
    data_rezervare: date = field(default_factory=date.today)
    nr_persoane: int = 1
    pret_total: Optional[float] = None
    status_rezervare: StatusRezervare = StatusRezervare.IN_ASTEPTARE
    metoda_plata: Optional[str] = None
    observatii: Optional[str] = None
    
    # Relatii
    tur: Optional[Tur] = None
    turist: Optional[Turist] = None
    
    def __str__(self):
        return f"Rezervare #{self.id_rezervare} - {self.status_rezervare.value}"


@dataclass
class Vizita:
    """Model pentru vizite individuale"""
    id_vizita: int
    id_turist: int
    id_locatie: int
    data_vizita: date
    durata_minute: Optional[int] = None
    cu_ghid: bool = False
    id_ghid: Optional[int] = None
    pret_platit: Optional[float] = None
    
    # Relatii
    turist: Optional[Turist] = None
    locatie: Optional[Locatie] = None
    ghid: Optional[Ghid] = None


@dataclass
class Eveniment:
    """Model pentru evenimente culturale"""
    id_eveniment: int
    nume_eveniment: str
    data_start: date
    descriere: Optional[str] = None
    id_locatie: Optional[int] = None
    data_end: Optional[date] = None
    pret_bilet: float = 0.0
    capacitate_max: Optional[int] = None
    nr_participanti_actuali: int = 0
    tip_eveniment: Optional[str] = None
    organizator: Optional[str] = None
    status_eveniment: StatusEveniment = StatusEveniment.PROGRAMAT
    
    # Relatii
    locatie: Optional[Locatie] = None
    
    def __str__(self):
        return f"{self.nume_eveniment} ({self.data_start})"
    
    @property
    def locuri_disponibile(self) -> Optional[int]:
        if self.capacitate_max:
            return self.capacitate_max - self.nr_participanti_actuali
        return None


@dataclass
class Participare:
    """Model pentru participari la evenimente"""
    id_participare: int
    id_eveniment: int
    id_turist: int
    data_inscriere: date = field(default_factory=date.today)
    nr_bilete: int = 1
    pret_total: Optional[float] = None
    status_participare: str = "Inscrisa"
    
    # Relatii
    eveniment: Optional[Eveniment] = None
    turist: Optional[Turist] = None


@dataclass
class Recenzie:
    """Model pentru recenzii"""
    id_recenzie: int
    id_turist: int
    rating: int
    id_locatie: Optional[int] = None
    id_tur: Optional[int] = None
    id_ghid: Optional[int] = None
    titlu: Optional[str] = None
    comentariu: Optional[str] = None
    data_recenzie: date = field(default_factory=date.today)
    util: int = 0
    verificat: bool = False
    
    # Relatii
    turist: Optional[Turist] = None
    locatie: Optional[Locatie] = None
    tur: Optional[Tur] = None
    ghid: Optional[Ghid] = None
    
    def __str__(self):
        stars = "★" * self.rating + "☆" * (5 - self.rating)
        return f"{stars} - {self.titlu or 'Fara titlu'}"


# ============================================
# FUNCTII HELPER
# ============================================

def row_to_model(row: dict, model_class):
    """Converteste un dict din baza de date intr-un model"""
    # Mapare nume coloane la campuri model
    field_mapping = {
        'ID_REGIUNE': 'id_regiune',
        'NUME_REGIUNE': 'nume_regiune',
        'ID_LOCATIE': 'id_locatie',
        'NUME_LOCATIE': 'nume_locatie',
        # Adaugati mapari suplimentare dupa nevoie
    }
    
    kwargs = {}
    for db_col, value in row.items():
        field_name = field_mapping.get(db_col, db_col.lower())
        if hasattr(model_class, '__dataclass_fields__'):
            if field_name in model_class.__dataclass_fields__:
                kwargs[field_name] = value
    
    return model_class(**kwargs)
