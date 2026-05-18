import os

replacements = {
    "mÂ²": "m&sup2;",
    "â€“": "&ndash;",
    "â€”": "&mdash;",
    "ðŸ“¦": "📦",
    "ðŸ›‹ï¸ ": "🛋️",
    "ðŸ› ï¸ ": "🛌",
    "ðŸ  ": "🏠",
    "ðŸš—": "🚗",
    "ðŸ ¡": "🏡",
    "ðŸ ˜ï¸ ": "🏡",
    "ðŸ ­": "🏭",
    "ðŸ ª": "🏪",
    "ðŸ ¬": "🏢",
    "ðŸ ¢": "🏬",
    "ðŸ —ï¸ ": "🏗️",
    "ðŸš›": "🚚"
}

files = [f for f in os.listdir('.') if f.endswith('.html')]

for filename in files:
    try:
        with open(filename, 'rb') as f:
            content = f.read()
        
        modified = False
        for old, new in replacements.items():
            old_bytes = old.encode('utf-8')
            new_bytes = new.encode('utf-8')
            if old_bytes in content:
                content = content.replace(old_bytes, new_bytes)
                modified = True
        
        if modified:
            with open(filename, 'wb') as f:
                f.write(content)
            print(f"Fixed {filename}")
    except Exception as e:
        print(f"Error processing {filename}: {e}")
