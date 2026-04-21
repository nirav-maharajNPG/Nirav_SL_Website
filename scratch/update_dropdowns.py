import os
import re

logo_img = '<div class="dropdown-logo-col"><img src="assets/Dynamic%20Workspaces%20Logo.png" alt="Dynamic Workspaces Logo"></div>'

def update_dropdowns(content):
    # Update Locations dropdown
    locations_pattern = r'(<div class="dropdown-grid">\s*)<div class="dropdown-column" style="width: 100%; text-align: center;">\s*<h4>Locations</h4>\s*<ul class="dropdown-links">.*?</ul>\s*</div>(\s*</div>)'
    
    def repl_locations(match):
        grid_start = match.group(1)
        grid_end = match.group(2)
        # Extract column content but remove the style
        col_content = re.search(r'<h4>Locations</h4>.*?</ul>', match.group(0), re.DOTALL).group(0)
        new_col = f'<div class="dropdown-column">{col_content}</div>'
        return f'{grid_start}{new_col}\n                        {logo_img}{grid_end}'

    content = re.sub(locations_pattern, repl_locations, content, flags=re.DOTALL)

    # Update Offerings dropdown
    offerings_pattern = r'(<div class="dropdown-grid">\s*)<div class="dropdown-column" style="width: 100%; text-align: center;">\s*<h4>Offerings</h4>\s*<ul class="dropdown-links">.*?</ul>\s*</div>(\s*</div>)'
    
    def repl_offerings(match):
        grid_start = match.group(1)
        grid_end = match.group(2)
        col_content = re.search(r'<h4>Offerings</h4>.*?</ul>', match.group(0), re.DOTALL).group(0)
        new_col = f'<div class="dropdown-column">{col_content}</div>'
        return f'{grid_start}{new_col}\n                        {logo_img}{grid_end}'

    content = re.sub(offerings_pattern, repl_offerings, content, flags=re.DOTALL)
    
    return content

for filename in os.listdir('.'):
    if filename.endswith('.html'):
        print(f"Processing {filename}...")
        with open(filename, 'r', encoding='utf-8') as f:
            content = f.read()
        
        new_content = update_dropdowns(content)
        
        if new_content != content:
            with open(filename, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Updated {filename}")
        else:
            print(f"No changes for {filename}")
