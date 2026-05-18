Add-Type -AssemblyName System.Drawing

function Optimize-Image {
    param (
        [string]$SourcePath,
        [string]$DestPath,
        [int]$MaxWidth = 1920,
        [int]$Quality = 75
    )

    if (-not (Test-Path $SourcePath)) {
        Write-Warning "Source file not found: $SourcePath"
        return
    }

    try {
        $oldSize = (Get-Item $SourcePath).Length
        Write-Host "Optimizing: $SourcePath ($([math]::Round($oldSize/1MB, 2)) MB)"

        # Read bytes to avoid locking the file
        $bytes = [System.IO.File]::ReadAllBytes($SourcePath)
        $ms = New-Object System.IO.MemoryStream(,$bytes)
        $img = [System.Drawing.Image]::FromStream($ms)

        # Calculate new dimensions if it exceeds MaxWidth
        $newWidth = $img.Width
        $newHeight = $img.Height
        if ($img.Width -gt $MaxWidth) {
            $ratio = $MaxWidth / $img.Width
            $newWidth = $MaxWidth
            $newHeight = [math]::Max(1, [int]($img.Height * $ratio))
            Write-Host "  Resizing from $($img.Width)x$($img.Height) to $($newWidth)x$($newHeight)"
        }

        # Create bitmap and draw
        $newImg = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
        $graphics = [System.Drawing.Graphics]::FromImage($newImg)
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $graphics.DrawImage($img, 0, 0, $newWidth, $newHeight)

        # Ensure directory exists for destination
        $destDir = Split-Path -Parent $DestPath
        if ($destDir -and -not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }

        # Save image as JPEG
        $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
        $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
        $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, $Quality)
        
        $newImg.Save($DestPath, $jpegCodec, $encoderParams)

        # Cleanup handles
        $encoderParams.Dispose()
        $graphics.Dispose()
        $newImg.Dispose()
        $img.Dispose()
        $ms.Dispose()

        $newSize = (Get-Item $DestPath).Length
        Write-Host "  Saved to: $DestPath ($([math]::Round($newSize/1KB, 2)) KB)"
        Write-Host "  Savings: $([math]::Round((1 - $newSize/$oldSize)*100, 2))%"
        
        # If we replaced the format, delete the old file if the path is different
        if ($SourcePath -ne $DestPath -and (Test-Path $SourcePath)) {
            Remove-Item $SourcePath -Force
            Write-Host "  Removed old file: $SourcePath"
        }
    }
    catch {
        Write-Error "Failed to optimize $($SourcePath) - $_"
    }
}

# 1. Optimize large cover images
Write-Host "=== OPTIMIZING COVERS ==="
Optimize-Image -SourcePath "assets/chadwick-cover/Gemini_Generated_Image_jmmo96jmmo96jmmo.png" -DestPath "assets/chadwick-cover/Gemini_Generated_Image_jmmo96jmmo96jmmo.jpg" -Quality 75
Optimize-Image -SourcePath "assets/Storage Locker/Cover pics/wynbergcover1.png" -DestPath "assets/Storage Locker/Cover pics/wynbergcover1.jpg" -Quality 75
Optimize-Image -SourcePath "assets/Storage Locker/Cover pics/deventon.png" -DestPath "assets/Storage Locker/Cover pics/deventon.jpg" -Quality 75
Optimize-Image -SourcePath "assets/aboutpagecover.png" -DestPath "assets/aboutpagecover.jpg" -Quality 75

# 2. Optimize in-place large JPEGs
Optimize-Image -SourcePath "assets/Storage Locker/Cover pics/Johannesburg Cbd.jpg" -DestPath "assets/Storage Locker/Cover pics/Johannesburg Cbd.jpg" -Quality 75
Optimize-Image -SourcePath "assets/Storage Locker/Cover pics/Vereeniging1.jpg" -DestPath "assets/Storage Locker/Cover pics/Vereeniging1.jpg" -Quality 75

# 3. Optimize other large images
Optimize-Image -SourcePath "assets/coworking.png" -DestPath "assets/coworking.jpg" -Quality 75
Optimize-Image -SourcePath "assets/private-office.png" -DestPath "assets/private-office.jpg" -Quality 75
Optimize-Image -SourcePath "assets/virtual-office.png" -DestPath "assets/virtual-office.jpg" -Quality 75
Optimize-Image -SourcePath "assets/chadwick_01_hq.png" -DestPath "assets/chadwick_01_hq.jpg" -Quality 75
Optimize-Image -SourcePath "assets/wynbergoffice.jpg" -DestPath "assets/wynbergoffice.jpg" -Quality 75
Optimize-Image -SourcePath "assets/morning side cover/Gemini_Generated_Image_m2g25fm2g25fm2g2 (1).png" -DestPath "assets/morning side cover/Gemini_Generated_Image_m2g25fm2g25fm2g2 (1).jpg" -Quality 75

Write-Host "=== UPDATING HTML REFERENCES ==="
# Find all HTML files
$htmlFiles = Get-ChildItem -Filter *.html

$asyncStyleBlock = @"
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

$syncStyleBlock = @"
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,700;0,900;1,700&family=Inter:wght@300;400;500;600;700&display=swap">
    <link rel="stylesheet" href="index.css?v=24.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
"@

$replacements = @{
    "Gemini_Generated_Image_jmmo96jmmo96jmmo.png" = "Gemini_Generated_Image_jmmo96jmmo96jmmo.jpg"
    "wynbergcover1.png" = "wynbergcover1.jpg"
    "deventon.png" = "deventon.jpg"
    "aboutpagecover.png" = "aboutpagecover.jpg"
    "coworking.png" = "coworking.jpg"
    "private-office.png" = "private-office.jpg"
    "virtual-office.png" = "virtual-office.jpg"
    "chadwick_01_hq.png" = "chadwick_01_hq.jpg"
    "Gemini_Generated_Image_m2g25fm2g25fm2g2 (1).png" = "Gemini_Generated_Image_m2g25fm2g25fm2g2 (1).jpg"
    "Gemini_Generated_Image_m2g25fm2g25fm2g2%20(1).png" = "Gemini_Generated_Image_m2g25fm2g25fm2g2%20(1).jpg"
    'type="image/png" href="assets/Storage Locker/storagelockerlogo.png"' = 'type="image/jpeg" href="assets/Storage Locker/storagelockerlogo.jpg"'
    "storagelockerlogo.png" = "storagelockerlogo.jpg"
    '<script src="index.js"></script>' = '<script src="index.js" defer></script>'
    '<button class="hero-arrow prev" onclick="moveHero(-1)">' = '<button class="hero-arrow prev" onclick="moveHero(-1)" aria-label="Previous slide">'
    '<button class="hero-arrow next" onclick="moveHero(1)">' = '<button class="hero-arrow next" onclick="moveHero(1)" aria-label="Next slide">'
    '<button class="feature-nav-btn prev" onclick="moveFeature(-1)">' = '<button class="feature-nav-btn prev" onclick="moveFeature(-1)" aria-label="Previous feature">'
    '<button class="feature-nav-btn next" onclick="moveFeature(1)">' = '<button class="feature-nav-btn next" onclick="moveFeature(1)" aria-label="Next feature">'
    '<button class="gallery-btn prev" id="prevBtn">' = '<button class="gallery-btn prev" id="prevBtn" aria-label="Previous image">'
    '<button class="gallery-btn next" id="nextBtn">' = '<button class="gallery-btn next" id="nextBtn" aria-label="Next image">'
    '<button class="gallery-btn prev" id="storagePrev" style="width: 50px; height: 50px; background: rgba(255,255,255,0.9); color: var(--black);">' = '<button class="gallery-btn prev" id="storagePrev" style="width: 50px; height: 50px; background: rgba(255,255,255,0.9); color: var(--black);" aria-label="Previous image">'
    '<button class="gallery-btn next" id="storageNext" style="width: 50px; height: 50px; background: rgba(255,255,255,0.9); color: var(--black);">' = '<button class="gallery-btn next" id="storageNext" style="width: 50px; height: 50px; background: rgba(255,255,255,0.9); color: var(--black);" aria-label="Next image">'
    
    # Navbar Logo Sizing
    '<img src="assets/Storage Locker/storagelockerlogo.jpg" alt="Storage Locker Logo" fetchpriority="high">' = '<img src="assets/Storage Locker/storagelockerlogo.jpg" alt="Storage Locker Logo" fetchpriority="high" width="51" height="70">'
    '<img src="assets/Storage Locker/storagelockerlogo.jpg" alt="Storage Locker Logo" fetchpriority="high" loading="lazy">' = '<img src="assets/Storage Locker/storagelockerlogo.jpg" alt="Storage Locker Logo" fetchpriority="high" loading="lazy" width="51" height="70">'
    
    # Dropdown Logo Sizing
    '<img src="assets/Storage Locker/storagelockerlogo.jpg" alt="Storage Locker Logo">' = '<img src="assets/Storage Locker/storagelockerlogo.jpg" alt="Storage Locker Logo" width="150" height="205">'
    '<img src="assets/Storage Locker/storagelockerlogo.jpg" alt="Storage Locker Logo" loading="lazy">' = '<img src="assets/Storage Locker/storagelockerlogo.jpg" alt="Storage Locker Logo" loading="lazy" width="150" height="205">'
    
    # Footer Logo Sizing
    '<img src="assets/Storage Locker/storagelockerlogo.jpg" alt="Storage Locker Logo" style="filter: contrast(1.2) brightness(1.1); mix-blend-mode: multiply;" loading="lazy">' = '<img src="assets/Storage Locker/storagelockerlogo.jpg" alt="Storage Locker Logo" style="filter: contrast(1.2) brightness(1.1); mix-blend-mode: multiply;" loading="lazy" width="161" height="220">'
    
    # Style Block Replacement
    $asyncStyleBlock = $syncStyleBlock
}

foreach ($file in $htmlFiles) {
    Write-Host "Updating HTML: $($file.Name)"
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    # Normalize file contents to LF to ensure line-ending agnostic matching
    $content = $content -replace "\r\n", "`n"
    $modified = $false
    
    foreach ($key in $replacements.Keys) {
        $normKey = $key -replace "\r\n", "`n"
        $normVal = $replacements[$key] -replace "\r\n", "`n"
        if ($content.Contains($normKey)) {
            $content = $content.Replace($normKey, $normVal)
            $modified = $true
            Write-Host "  Replaced $normKey -> $normVal"
        }
    }
    
    if ($modified) {
        # Keep LF line endings consistently for web files
        [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
        Write-Host "  Saved changes to $($file.Name)"
    }
}

Write-Host "=== DONE ==="
