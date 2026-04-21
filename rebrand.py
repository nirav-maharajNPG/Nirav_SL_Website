import os
import re

replacements = {
    'Dynamic Workspaces': 'Storage Locker',
    'dynamicworkspaces.co.za': 'storagelocker.co.za',
    'assets/Dynamic%20Workspaces%20Logo.png': 'assets/Storage%20Locker/storagelockerlogo.png',
    'assets/Dynamic Workspaces Logo.png': 'assets/Storage Locker/storagelockerlogo.png'
}

for filename in os.listdir('.'):
    if filename.endswith('.html') or filename.endswith('.css') or filename.endswith('.js'):
        with open(filename, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        for old, new in replacements.items():
            content = re.sub(re.escape(old), new, content, flags=re.IGNORECASE)
        
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(content)
