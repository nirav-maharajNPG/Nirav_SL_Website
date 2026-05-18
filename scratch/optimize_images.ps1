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
}

foreach ($file in $htmlFiles) {
    Write-Host "Updating HTML: $($file.Name)"
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    $modified = $false
    
    foreach ($key in $replacements.Keys) {
        if ($content.Contains($key)) {
            $content = $content.Replace($key, $replacements[$key])
            $modified = $true
            Write-Host "  Replaced $key -> $($replacements[$key])"
        }
    }
    
    if ($modified) {
        [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
        Write-Host "  Saved changes to $($file.Name)"
    }
}

Write-Host "=== DONE ==="
