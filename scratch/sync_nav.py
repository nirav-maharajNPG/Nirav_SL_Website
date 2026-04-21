import os
import re

with open('index.html', 'r', encoding='utf-8') as f:
    index_content = f.read()

nav_match = re.search(r'<nav class="navbar">.*?</nav>', index_content, re.DOTALL)
if nav_match:
    nav_html = nav_match.group(0)
    
    for filename in os.listdir('.'):
        if filename.endswith('.html') and filename != 'index.html':
            with open(filename, 'r', encoding='utf-8') as f:
                content = f.read()
            
            new_content = re.sub(r'<nav class="navbar">.*?</nav>', nav_html.replace('\\', '\\\\'), content, flags=re.DOTALL)
            
            if new_content != content:
                with open(filename, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                print(f"Updated {filename}")
