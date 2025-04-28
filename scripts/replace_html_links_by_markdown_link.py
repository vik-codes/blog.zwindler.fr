import os
import re

def convert_html_links_to_markdown(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()

    # Expression régulière pour capturer les liens <a> avec 'href' et ignorer les autres balises/attributs
    pattern = r'<a\s+[^>]*?href=["\'](.*?)["\'][^>]*?>(.*?)<\/a>'
    
    # Remplacement des balises HTML par des liens Markdown
    def replace_link(match):
        url = match.group(1)  # Capture de l'URL
        text = re.sub(r'<[^>]+>', '', match.group(2))  # Suppression des balises HTML dans le texte
        return f"[{text}]({url})"

    markdown_links = re.sub(pattern, replace_link, content, flags=re.DOTALL)

    # Sauvegarde du fichier avec les liens convertis
    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(markdown_links)

def traverse_and_convert(root_dir):
    for root, _, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.md'):
                file_path = os.path.join(root, file)
                convert_html_links_to_markdown(file_path)
                print(f"Liens convertis dans le fichier : {file_path}")

if __name__ == "__main__":
    # Remplacez 'content/post' par le chemin de votre répertoire racine
    root_directory = "content/post"
    traverse_and_convert(root_directory)
