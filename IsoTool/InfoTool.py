import tkinter as tk
from tkinter import filedialog

# Criando a janela principal
root = tk.Tk()
root.title("IsoTool")
root.geometry("500x350")
root.configure(bg="#1E1E1E")

# Estilizando
font_title = ("Courier", 24, "bold")
font_label = ("Arial", 12)
font_entry = ("Arial", 12)
font_button = ("Arial", 12, "bold")

# Título
title_label = tk.Label(root, text="IsoTool", font=font_title, bg="#1E1E1E", fg="white")
title_label.pack(pady=10)

# Função para selecionar arquivo ISO
def selecionar_arquivo():
    caminho_arquivo = filedialog.askopenfilename(filetypes=[("Arquivos ISO", "*.iso")])
    if caminho_arquivo:
        entry_iso.delete(0, tk.END)
        entry_iso.insert(0, caminho_arquivo)

# Label e Input do caminho da ISO
label_iso = tk.Label(root, text="Caminho da ISO", font=font_label, bg="#1E1E1E", fg="white")
label_iso.pack(anchor="w", padx=50, pady=(10, 0))

entry_iso = tk.Entry(root, font=font_entry, bg="#2D2D2D", fg="white", insertbackground="white", width=40, bd=0)
entry_iso.pack(pady=5)
entry_iso.insert(0, "/Disk/Users/example/Downloads/Debian.iso")

button_iso = tk.Button(root, text="...", font=font_button, command=selecionar_arquivo, bg="#3A3A3A", fg="white", bd=0)
button_iso.pack(pady=2)

# Label e Input do nome do disco
label_disk = tk.Label(root, text="Nome do disco", font=font_label, bg="#1E1E1E", fg="white")
label_disk.pack(anchor="w", padx=50, pady=(10, 0))

entry_disk = tk.Entry(root, font=font_entry, bg="#2D2D2D", fg="white", insertbackground="white", width=40, bd=0)
entry_disk.pack(pady=5)

# Botão para criar
button_create = tk.Button(root, text="CREATE", font=font_button, bg="#3A3A3A", fg="white", width=15, height=2, bd=0)
button_create.pack(pady=20)

# Rodando o app
root.mainloop()