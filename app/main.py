"""
SISTEM DISTRIBUIT PENTRU CULTURA SI TURISM - SIRIA
Aplicatie Python pentru afisarea rapoartelor

Aceasta aplicatie se conecteaza la baza de date Oracle/SQL Server
si afiseaza rapoarte folosind proceduri stocate.
"""

import os
import sys
from datetime import datetime
from typing import List, Dict, Any, Optional
from dataclasses import dataclass
from enum import Enum

# ============================================
# CONFIGURARE
# ============================================
class DatabaseType(Enum):
    ORACLE = "oracle"
    SQLSERVER = "sqlserver"

@dataclass
class DatabaseConfig:
    db_type: DatabaseType
    host: str
    port: int
    database: str
    username: str
    password: str
    
    @classmethod
    def from_env(cls) -> 'DatabaseConfig':
        """Incarca configuratia din variabile de mediu"""
        db_type = os.getenv('DB_TYPE', 'oracle').lower()
        return cls(
            db_type=DatabaseType.ORACLE if db_type == 'oracle' else DatabaseType.SQLSERVER,
            host=os.getenv('DB_HOST', 'localhost'),
            port=int(os.getenv('DB_PORT', '1521' if db_type == 'oracle' else '1433')),
            database=os.getenv('DB_NAME', 'XEPDB1'),
            username=os.getenv('DB_USER', 'system'),
            password=os.getenv('DB_PASSWORD', 'student')
        )

# CLASA CONEXIUNE BAZA DE DATE
class DatabaseConnection:
    """Clasa pentru gestionarea conexiunii la baza de date"""
    
    def __init__(self, config: DatabaseConfig):
        self.config = config
        self.connection = None
        
    def connect(self) -> bool:
        """Stabileste conexiunea la baza de date"""
        try:
            if self.config.db_type == DatabaseType.ORACLE:
                import oracledb
                dsn = f"{self.config.host}:{self.config.port}/{self.config.database}"
                self.connection = oracledb.connect(
                    user=self.config.username,
                    password=self.config.password,
                    dsn=dsn
                )
            else:
                import pyodbc
                conn_str = (
                    f"DRIVER={{ODBC Driver 17 for SQL Server}};"
                    f"SERVER={self.config.host},{self.config.port};"
                    f"DATABASE={self.config.database};"
                    f"UID={self.config.username};"
                    f"PWD={self.config.password}"
                )
                self.connection = pyodbc.connect(conn_str)
            print(f"✓ Conectat la baza de date {self.config.db_type.value}")
            return True
        except Exception as e:
            print(f"✗ Eroare la conectare: {e}")
            return False
    
    def disconnect(self):
        """Inchide conexiunea"""
        if self.connection:
            self.connection.close()
            print("✓ Conexiune inchisa")
    
    def execute_procedure(self, proc_name: str) -> List[Dict[str, Any]]:
        """Executa o procedura stocata si returneaza rezultatele"""
        if not self.connection:
            raise Exception("Nu exista conexiune activa")
        
        cursor = self.connection.cursor()
        results = []
        
        try:
            if self.config.db_type == DatabaseType.ORACLE:
                # Oracle - foloseste cursor OUT
                ref_cursor = self.connection.cursor()
                cursor.callproc(proc_name, [ref_cursor])
                columns = [col[0] for col in ref_cursor.description]
                for row in ref_cursor:
                    results.append(dict(zip(columns, row)))
                ref_cursor.close()
            else:
                # SQL Server
                cursor.execute(f"EXEC {proc_name}")
                columns = [col[0] for col in cursor.description]
                for row in cursor.fetchall():
                    results.append(dict(zip(columns, row)))
        finally:
            cursor.close()
        
        return results

# CLASA RAPOARTE
class ReportManager:
    """Clasa pentru gestionarea si afisarea rapoartelor"""
    
    def __init__(self, db: DatabaseConnection):
        self.db = db
        self.reports = {
            1: ("Top Locatii dupa Rating", "sp_top_locatii_rating"),
            2: ("Statistici Tururi pe Regiune", "sp_statistici_tururi_regiune"),
            3: ("Analiza Turisti Activi", "sp_analiza_turisti_activi"),
            4: ("Performanta Ghizi", "sp_performanta_ghizi"),
            5: ("Popularitate Situri UNESCO", "sp_popularitate_unesco"),
            6: ("Evenimente si Participari", "sp_evenimente_participari"),
            7: ("Dashboard Sumar", "sp_dashboard_sumar"),
        }
    
    def get_report(self, report_id: int) -> Optional[List[Dict]]:
        """Obtine datele unui raport"""
        if report_id not in self.reports:
            print(f"Raport invalid: {report_id}")
            return None
        
        name, proc = self.reports[report_id]
        print(f"\n{'='*60}")
        print(f"RAPORT: {name}")
        print(f"{'='*60}")
        
        try:
            results = self.db.execute_procedure(proc)
            return results
        except Exception as e:
            print(f"Eroare la executare: {e}")
            return None
    
    def display_report(self, report_id: int):
        """Afiseaza un raport in consola"""
        results = self.get_report(report_id)
        if not results:
            print("Nu exista date de afisat.")
            return
        
        # Afisare tabel
        if results:
            headers = list(results[0].keys())
            col_widths = {h: max(len(str(h)), max(len(str(r.get(h, ''))) for r in results)) 
                         for h in headers}
            
            # Header
            header_line = " | ".join(str(h).ljust(col_widths[h]) for h in headers)
            print(header_line)
            print("-" * len(header_line))
            
            # Rows
            for row in results:
                row_line = " | ".join(str(row.get(h, '')).ljust(col_widths[h]) for h in headers)
                print(row_line)
        
        print(f"\nTotal randuri: {len(results)}")
    
    def display_menu(self):
        """Afiseaza meniul de rapoarte"""
        print("\n" + "="*50)
        print("SISTEM TURISM SIRIA - MENIU RAPOARTE")
        print("="*50)
        for rid, (name, _) in self.reports.items():
            print(f"  {rid}. {name}")
        print("  0. Iesire")
        print("="*50)

# CLASA VIZUALIZARI (Optional - matplotlib)
class ReportVisualizer:
    """Clasa pentru vizualizari grafice ale rapoartelor"""
    
    def __init__(self, report_manager: ReportManager):
        self.rm = report_manager
        self._check_matplotlib()
    
    def _check_matplotlib(self):
        """Verifica daca matplotlib este disponibil"""
        try:
            import matplotlib.pyplot as plt
            self.plt = plt
            self.available = True
        except ImportError:
            self.available = False
            print("Nota: matplotlib nu este instalat. Vizualizarile grafice nu sunt disponibile.")
    
    def plot_top_locatii(self, save_path: str = None):
        """Grafic pentru top locatii dupa rating"""
        if not self.available:
            return
        
        results = self.rm.get_report(1)
        if not results:
            return
        
        names = [r['NUME_LOCATIE'][:20] for r in results[:10]]
        ratings = [float(r['RATING_MEDIU'] or 0) for r in results[:10]]
        reviews = [int(r['NUMAR_RECENZII'] or 0) for r in results[:10]]
        
        fig, ax1 = self.plt.subplots(figsize=(12, 6))
        
        x = range(len(names))
        bars = ax1.bar(x, ratings, color='steelblue', alpha=0.8)
        ax1.set_ylabel('Rating Mediu', color='steelblue')
        ax1.set_ylim(0, 5.5)
        
        ax2 = ax1.twinx()
        ax2.plot(x, reviews, 'ro-', linewidth=2, markersize=8)
        ax2.set_ylabel('Numar Recenzii', color='red')
        
        self.plt.xticks(x, names, rotation=45, ha='right')
        self.plt.title('Top Locatii Turistice - Rating si Recenzii')
        self.plt.tight_layout()
        
        if save_path:
            self.plt.savefig(save_path, dpi=150)
            print(f"Grafic salvat: {save_path}")
        else:
            self.plt.show()
    
    def plot_tururi_regiune(self, save_path: str = None):
        """Grafic pentru statistici tururi pe regiune"""
        if not self.available:
            return
        
        results = self.rm.get_report(2)
        if not results:
            return
        
        regions = [r['NUME_REGIUNE'] for r in results]
        revenues = [float(r['VENIT_TOTAL'] or 0) for r in results]
        tours = [int(r['NUMAR_TURURI'] or 0) for r in results]
        
        fig, (ax1, ax2) = self.plt.subplots(1, 2, figsize=(14, 5))
        
        # Pie chart - venituri
        ax1.pie(revenues, labels=regions, autopct='%1.1f%%', startangle=90)
        ax1.set_title('Distributie Venituri per Regiune')
        
        # Bar chart - numar tururi
        ax2.barh(regions, tours, color='teal')
        ax2.set_xlabel('Numar Tururi')
        ax2.set_title('Tururi Disponibile per Regiune')
        
        self.plt.tight_layout()
        
        if save_path:
            self.plt.savefig(save_path, dpi=150)
            print(f"Grafic salvat: {save_path}")
        else:
            self.plt.show()
    
    def plot_dashboard(self, save_path: str = None):
        """Dashboard sumar vizual"""
        if not self.available:
            return
        
        results = self.rm.get_report(7)
        if not results:
            return
        
        data = results[0]
        
        fig, axes = self.plt.subplots(2, 4, figsize=(16, 8))
        axes = axes.flatten()
        
        metrics = [
            ('Locatii Active', data.get('LOCATII_ACTIVE', 0), 'green'),
            ('Total Turisti', data.get('TOTAL_TURISTI', 0), 'blue'),
            ('Ghizi Disponibili', data.get('GHIZI_DISPONIBILI', 0), 'orange'),
            ('Tururi Active', data.get('TURURI_ACTIVE', 0), 'purple'),
            ('Rezervari Confirmate', data.get('REZERVARI_CONFIRMATE', 0), 'teal'),
            ('Venituri (USD)', data.get('VENITURI_REZERVARI', 0), 'gold'),
            ('Evenimente Curente', data.get('EVENIMENTE_CURENTE', 0), 'red'),
            ('Rating Mediu', data.get('RATING_MEDIU_GENERAL', 0), 'navy'),
        ]
        
        for ax, (label, value, color) in zip(axes, metrics):
            ax.text(0.5, 0.5, str(value), fontsize=36, ha='center', va='center',
                   color=color, fontweight='bold', transform=ax.transAxes)
            ax.text(0.5, 0.15, label, fontsize=12, ha='center', va='center',
                   transform=ax.transAxes)
            ax.set_xlim(0, 1)
            ax.set_ylim(0, 1)
            ax.axis('off')
            ax.patch.set_facecolor('#f0f0f0')
        
        self.plt.suptitle('Dashboard Turism Siria', fontsize=16, fontweight='bold')
        self.plt.tight_layout()
        
        if save_path:
            self.plt.savefig(save_path, dpi=150)
            print(f"Dashboard salvat: {save_path}")
        else:
            self.plt.show()

# FUNCTIE PRINCIPALA
def main():
    """Functia principala a aplicatiei"""
    print("\n" + "="*60)
    print("  SISTEM DISTRIBUIT PENTRU CULTURA SI TURISM - SIRIA")
    print("  Aplicatie Rapoarte v1.0")
    print("="*60)
    
    # Configurare
    config = DatabaseConfig.from_env()
    print(f"\nConfiguratie: {config.db_type.value} @ {config.host}:{config.port}")
    
    # Conectare
    db = DatabaseConnection(config)
    if not db.connect():
        print("Nu s-a putut realiza conexiunea. Verificati configuratia.")
        sys.exit(1)
    
    try:
        # Manager rapoarte
        rm = ReportManager(db)
        viz = ReportVisualizer(rm)
        
        while True:
            rm.display_menu()
            
            try:
                choice = input("\nAlegeti optiunea: ").strip()
                
                if choice == '0':
                    print("\nLa revedere!")
                    break
                
                report_id = int(choice)
                
                if report_id in rm.reports:
                    rm.display_report(report_id)
                    
                    # Optiune pentru grafic
                    if viz.available and report_id in [1, 2, 7]:
                        save_graph = input("\nDoriti sa salvati graficul? (d/n): ").lower()
                        if save_graph == 'd':
                            filename = f"raport_{report_id}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.png"
                            if report_id == 1:
                                viz.plot_top_locatii(filename)
                            elif report_id == 2:
                                viz.plot_tururi_regiune(filename)
                            elif report_id == 7:
                                viz.plot_dashboard(filename)
                else:
                    print("Optiune invalida!")
                    
            except ValueError:
                print("Introduceti un numar valid!")
            except KeyboardInterrupt:
                print("\n\nIntrerupt de utilizator.")
                break
    
    finally:
        db.disconnect()

# MODUL DEMO (fara conexiune reala)
def demo_mode():
    """Mod demonstrativ cu date fictive"""
    print("\n" + "="*60)
    print("  SISTEM TURISM SIRIA - MOD DEMONSTRATIV")
    print("="*60)
    print("\nAcesta este modul demo. Pentru a rula cu baza de date reala,")
    print("configurati variabilele de mediu si rulati: python app.py")
    
    # Date demo
    demo_data = {
        "Top Locatii": [
            {"Locatie": "Moscheea Umayyad", "Rating": 4.9, "Recenzii": 45},
            {"Locatie": "Krak des Chevaliers", "Rating": 4.8, "Recenzii": 38},
            {"Locatie": "Teatrul Bosra", "Rating": 4.7, "Recenzii": 32},
        ],
        "Statistici": {
            "Locatii active": 15,
            "Total turisti": 12,
            "Ghizi": 6,
            "Tururi": 8,
            "Rating mediu": 4.5
        }
    }
    
    print("\n--- DATE DEMO ---")
    for category, data in demo_data.items():
        print(f"\n{category}:")
        if isinstance(data, list):
            for item in data:
                print(f"  - {item}")
        else:
            for key, val in data.items():
                print(f"  {key}: {val}")

# ============================================
# ENTRY POINT
# ============================================
if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description='Sistem Turism Siria - Rapoarte')
    parser.add_argument('--demo', action='store_true', help='Ruleaza in mod demo')
    args = parser.parse_args()
    
    if args.demo:
        demo_mode()
    else:
        main()
