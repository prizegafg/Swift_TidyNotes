import os
import re

# Nama folder target
target_folder = "TidyNotes"
modules_folder = os.path.join(target_folder, "Modules")
output_dir = "AI Integration"
excluded_dirs = {".xcworkspace", ".xcodeproj", "DerivedData", "__pycache__", "TidyNotesTests", "TidyNotesUITests"}

# Buat folder output kalau belum ada
os.makedirs(output_dir, exist_ok=True)

# Kumpulan konten
bundles = {}     # key = module name, value = list of file paths
misc_files = []  # file2 selain Modules di dalam TidyNotes

# Proses folder Modules terlebih dahulu
if os.path.exists(modules_folder):
    for module_name in os.listdir(modules_folder):
        module_path = os.path.join(modules_folder, module_name)
        if os.path.isdir(module_path):
            bundles[module_name] = []
            for root, _, files in os.walk(module_path):
                for file in files:
                    if file.endswith(".swift"):
                        bundles[module_name].append(os.path.join(root, file))

# Sekarang proses semua file swift di TidyNotes (tapi exclude Modules/)
for root, dirs, files in os.walk(target_folder):
    relative_root = os.path.relpath(root, ".")
    if any(ex in relative_root for ex in excluded_dirs) or "Modules" in relative_root.split(os.sep):
        continue

    for file in files:
        if file.endswith(".swift"):
            misc_files.append(os.path.join(root, file))

# Tulis file per modul
for module_name, file_paths in bundles.items():
    out_file = os.path.join(output_dir, f"{module_name}.swift.txt")
    with open(out_file, "w", encoding="utf-8") as bundle:
        bundle.write(f"// === ✅ Module: {module_name} ===\n\n")
        for file_path in file_paths:
            try:
                with open(file_path, "r", encoding="utf-8") as f:
                    content = f.read()
                    content = re.sub(r'//.*?\n', '', content)
                    content = re.sub(r'\n\s*\n', '\n', content)
                    rel_path = os.path.relpath(file_path, ".")
                    bundle.write(f"\n// --- {rel_path} ---\n")
                    bundle.write(content)
            except Exception as e:
                print(f"❌ Error reading {file_path}: {e}")

# Tulis file Misc satu per satu
for file_path in misc_files:
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()
            content = re.sub(r'//.*?\n', '', content)
            content = re.sub(r'\n\s*\n', '\n', content)
            rel_path = os.path.relpath(file_path, target_folder).replace(os.sep, "_")
            out_file = os.path.join(output_dir, f"Misc_{rel_path}.swift.txt")
            with open(out_file, "w", encoding="utf-8") as out:
                out.write(f"// === ✅ Misc File: {file_path} ===\n\n")
                out.write(content)
    except Exception as e:
        print(f"❌ Error reading {file_path}: {e}")

print(f"✅ Done! Output disimpan di folder '{output_dir}'")

