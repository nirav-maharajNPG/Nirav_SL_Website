import os
import re

html_files = [f for f in os.listdir('.') if f.endswith('.html')]

# Target patterns to replace
patterns = [
    (r'<link rel="stylesheet" href="index.css\?v=24\.0">', ''),
    (r'<link rel="preconnect" href="https://fonts\.googleapis\.com">', ''),
    (r'<link rel="preconnect" href="https://fonts\.gstatic\.com" crossorigin>', ''),
    (r'<link href="https://fonts\.googleapis\.com/css2\?family=Playfair\+Display[^"]+" rel="stylesheet">', ''),
    (r'<link rel="stylesheet" href="https://cdnjs\.cloudflare\.com/ajax/libs/font-awesome/6\.4\.0/css/all\.min\.css">', '')
]

optimized_block = """    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="preload" as="style" href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,700;0,900;1,700&family=Inter:wght@300;400;500;600;700&display=swap">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,700;0,900;1,700&family=Inter:wght@300;400;500;600;700&display=swap" media="print" onload="this.media='all'">
    <link rel="preload" as="style" href="index.css?v=24.0">
    <link rel="stylesheet" href="index.css?v=24.0" media="print" onload="this.media='all'">
    <link rel="preload" as="style" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" media="print" onload="this.media='all'">
    <noscript>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,700;0,900;1,700&family=Inter:wght@300;400;500;600;700&display=swap">
        <link rel="stylesheet" href="index.css?v=24.0">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    </noscript>"""

for filename in html_files:
    if filename == 'google11184c9eb7e0c0f7.html' or filename == 'size-finder-snippet.html':
        continue
        
    print(f"Optimizing {filename}...")
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Remove old tags
    new_content = content
    for pattern, replacement in patterns:
        new_content = re.sub(pattern, replacement, new_content)
    
    # Insert optimized block before </head> or after meta tags
    if '</head>' in new_content:
        # Try to find a good spot (after meta tags or where the first removed tag was)
        # For simplicity, we'll place it right before </head> for now, or replace a specific marker.
        # Actually, let's find the first occurrence of one of the removed tags and put it there.
        # But since we already removed them, let's just put it before </head>.
        new_content = new_content.replace('</head>', optimized_block + '\n</head>')
    
    # Cleanup extra blank lines
    new_content = re.sub(r'\n\s*\n\s*\n', '\n\n', new_content)
    
    with open(filename, 'w', encoding='utf-8') as f:
        f.write(new_content)

print("Done!")
