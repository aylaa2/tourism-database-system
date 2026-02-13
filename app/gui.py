import tkinter as tk
from tkinter import ttk, messagebox, filedialog
import csv
import oracledb

class TurismSiriaApp:
    def __init__(self, root):
        self.root = root
        self.root.title("✨ Sistem Turism Siria - Dashboard")
        self.root.geometry("1100x700")
        
        # --- 1. CONFIGURARE AUTOMATA ---
        self.db_config = {
            "user": "system",
            "password": "student",  
            "dsn": "localhost:1521/XEPDB1"
        }
        
        self.connection = None
        
        # Mapare Rapoarte
        self.report_map = {
            "🏆 Top Locatii dupa Rating": "sp_top_locatii_rating",
            "🌍 Statistici Tururi pe Regiune": "sp_statistici_tururi_regiune",
            "👥 Analiza Turisti Activi": "sp_analiza_turisti_activi",
            "⭐ Performanta Ghizi": "sp_performanta_ghizi",
            "🏛️ Popularitate Situri UNESCO": "sp_popularitate_unesco",
            "📊 Dashboard Sumar (KPIs)": "sp_dashboard_sumar"
        }
        
        self.setup_styles()
        self.create_layout()
        
        # CONECTARE AUTOMATA LA PORNIRE
        self.root.after(500, self.auto_connect)

    def setup_styles(self):
        style = ttk.Style()
        style.theme_use('alt')  # 'alt' permite culori custom la butoane

        # Culori
        bg_color = "#f4f7f6"
        header_bg = "#2c3e50" # Dark Blue
        header_fg = "white"
        btn_gen_bg = "#3498db" # Blue
        btn_exp_bg = "#f39c12" # Orange
        
        # Configurare Generala
        self.root.configure(bg=bg_color)
        style.configure("TFrame", background=bg_color)
        style.configure("TLabel", background=bg_color, font=('Segoe UI', 10))
        
        # Header Style
        style.configure("Title.TLabel", background=header_bg, foreground=header_fg, 
                       font=('Segoe UI', 18, 'bold'), padding=15)
        
        # Button Styles
        style.configure("Generate.TButton", background=btn_gen_bg, foreground="white", 
                       font=('Segoe UI', 10, 'bold'))
        style.map("Generate.TButton", background=[('active', '#2980b9')])
        
        style.configure("Export.TButton", background=btn_exp_bg, foreground="white", 
                       font=('Segoe UI', 10, 'bold'))
        style.map("Export.TButton", background=[('active', '#d35400')])

        # Treeview (Tabel)
        style.configure("Treeview", font=('Segoe UI', 10), rowheight=25)
        style.configure("Treeview.Heading", font=('Segoe UI', 10, 'bold'), 
                       background="#ecf0f1", foreground="#2c3e50")
        
    def create_layout(self):
        # --- HEADER ---
        header_frame = tk.Frame(self.root, bg="#2c3e50")
        header_frame.pack(fill=tk.X)
        
        lbl_title = tk.Label(header_frame, text="SISTEM DISTRIBUIT TURISM SIRIA", 
                            bg="#2c3e50", fg="white", font=('Segoe UI', 16, 'bold'), pady=15)
        lbl_title.pack(side=tk.LEFT, padx=20)
        
        self.lbl_status = tk.Label(header_frame, text="Se conecteaza...", 
                                  bg="#2c3e50", fg="#f1c40f", font=('Segoe UI', 10, 'bold'))
        self.lbl_status.pack(side=tk.RIGHT, padx=20)

        # --- CONTROL PANEL ---
        control_frame = ttk.Frame(self.root, padding=20)
        control_frame.pack(fill=tk.X)
        
        # Dropdown
        ttk.Label(control_frame, text="Alege Raportul:", font=('Segoe UI', 11)).pack(side=tk.LEFT, padx=5)
        
        self.combo_reports = ttk.Combobox(control_frame, values=list(self.report_map.keys()), 
                                         width=35, state="readonly", font=('Segoe UI', 10))
        self.combo_reports.current(0)
        self.combo_reports.pack(side=tk.LEFT, padx=15)
        
        # Butoane
        btn_gen = ttk.Button(control_frame, text="▶ GENERARE RAPORT", style="Generate.TButton", 
                            command=self.run_selected_report)
        btn_gen.pack(side=tk.LEFT, padx=5)
        
        btn_exp = ttk.Button(control_frame, text="💾 Export CSV", style="Export.TButton", 
                            command=self.export_csv)
        btn_exp.pack(side=tk.LEFT, padx=5)

        # --- REZULTATE ---
        result_frame = ttk.Frame(self.root, padding=(20, 0, 20, 20))
        result_frame.pack(fill=tk.BOTH, expand=True)
        
        # Scrollbars
        y_scroll = ttk.Scrollbar(result_frame)
        x_scroll = ttk.Scrollbar(result_frame, orient=tk.HORIZONTAL)
        
        self.tree = ttk.Treeview(result_frame, show='headings', 
                                yscrollcommand=y_scroll.set, xscrollcommand=x_scroll.set)
        
        y_scroll.config(command=self.tree.yview)
        x_scroll.config(command=self.tree.xview)
        
        y_scroll.pack(side=tk.RIGHT, fill=tk.Y)
        x_scroll.pack(side=tk.BOTTOM, fill=tk.X)
        self.tree.pack(fill=tk.BOTH, expand=True)
        
        # Culori alternative pentru randuri (Stripes)
        self.tree.tag_configure('odd', background='#ffffff')
        self.tree.tag_configure('even', background='#e8f6f3')

    def auto_connect(self):
        """Incearca sa se conecteze automat la start"""
        try:
            self.connection = oracledb.connect(
                user=self.db_config["user"],
                password=self.db_config["password"],
                dsn=self.db_config["dsn"]
            )
            self.lbl_status.config(text="✓ CONECTAT LA BAZA DE DATE", fg="#2ecc71") # Verde
            
            # Ruleaza automat primul raport ca sa nu fie gol ecranul
            self.run_selected_report()
            
        except Exception as e:
            self.lbl_status.config(text="⚠ EROARE CONEXIUNE", fg="#e74c3c") # Rosu
            messagebox.showerror("Eroare Fatala", 
                               f"Nu m-am putut conecta la baza de date!\n\nVerifica daca Docker ruleaza.\n\nDetalii: {e}")

    def run_selected_report(self):
        if not self.connection:
            return

        report_name = self.combo_reports.get()
        proc_name = self.report_map.get(report_name)

        # Curata tabelul
        self.tree.delete(*self.tree.get_children())
        self.tree["columns"] = []

        try:
            cursor = self.connection.cursor()
            ref_cursor = self.connection.cursor()
            
            cursor.callproc(proc_name, [ref_cursor])
            
            columns = [col[0] for col in ref_cursor.description]
            self.tree["columns"] = columns
            
            for col in columns:
                self.tree.heading(col, text=col, anchor=tk.CENTER)
                self.tree.column(col, width=150, anchor=tk.CENTER)

            rows = ref_cursor.fetchall()
            for i, row in enumerate(rows):
                tag = 'even' if i % 2 == 0 else 'odd'
                self.tree.insert("", tk.END, values=row, tags=(tag,))
            
            cursor.close()
            ref_cursor.close()

        except Exception as e:
            messagebox.showerror("Eroare SQL", str(e))

    def export_csv(self):
        if not self.tree.get_children():
            return
            
        file_path = filedialog.asksaveasfilename(defaultextension=".csv", filetypes=[("CSV", "*.csv")])
        if file_path:
            try:
                with open(file_path, 'w', newline='', encoding='utf-8') as f:
                    writer = csv.writer(f)
                    writer.writerow(self.tree["columns"])
                    for row_id in self.tree.get_children():
                        writer.writerow(self.tree.item(row_id)['values'])
                messagebox.showinfo("Succes", "Fisier salvat!")
            except Exception as e:
                messagebox.showerror("Eroare", str(e))

if __name__ == "__main__":
    root = tk.Tk()
    app = TurismSiriaApp(root)
    root.mainloop()