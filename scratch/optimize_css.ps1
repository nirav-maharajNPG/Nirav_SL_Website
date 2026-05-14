$files = Get-ChildItem -Filter *.html | Where-Object { $_.Name -ne "google11184c9eb7e0c0f7.html" -and $_.Name -ne "size-finder-snippet.html" }
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    
    # Remove existing tags (multiline and single line)
    $content = $content -replace '(?m)^\s*<link rel="stylesheet" href="index.css\?v=24\.0">\s*$', ''
    $content = $content -replace '(?m)^\s*<link rel="preconnect" href="https://fonts\.googleapis\.com">\s*$', ''
    $content = $content -replace '(?m)^\s*<link rel="preconnect" href="https://fonts\.gstatic\.com" crossorigin>\s*$', ''
    $content = $content -replace '(?m)^\s*<link href="https://fonts\.googleapis\.com/css2\?family=Playfair\+Display[^"]+" rel="stylesheet">\s*$', ''
    $content = $content -replace '(?m)^\s*<link rel="stylesheet" href="https://cdnjs\.cloudflare\.com/ajax/libs/font-awesome/6\.4\.0/css/all\.min\.css">\s*$', ''
    
    $optimized = @"
    <link rel="preconnect" href="https://fonts.googleapis.com">
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
    </noscript>
"@

    if ($content -notmatch 'media="print" onload="this.media=''all''"') {
        $content = $content -replace '</head>', "$optimized`n</head>"
        # Ensure it's UTF8 without BOM (standard for web)
        [System.IO.File]::WriteAllText($file.FullName, $content, (New-Object System.Text.UTF8Encoding $false))
        Write-Host "Optimized $($file.Name)"
    }
}
