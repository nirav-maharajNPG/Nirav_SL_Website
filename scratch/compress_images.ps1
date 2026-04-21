# PowerShell script to compress images over 500KB
Add-Type -AssemblyName System.Drawing

function Compress-Image {
    param (
        [string]$Path,
        [int]$Quality = 75,
        [int]$MaxWidth = 1920
    )

    try {
        $img = [System.Drawing.Image]::FromFile($Path)
        $width = $img.Width
        $height = $img.Height

        # Calculate new dimensions if necessary
        if ($width -gt $MaxWidth) {
            $ratio = $MaxWidth / $width
            $newWidth = $MaxWidth
            $newHeight = [int]($height * $ratio)
            
            $newImg = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
            $graphics = [System.Drawing.Graphics]::FromImage($newImg)
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.DrawImage($img, 0, 0, $newWidth, $newHeight)
            $graphics.Dispose()
            $img.Dispose()
            $img = $newImg
        }

        # Setup codec and parameters for JPEG quality
        $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
        $params = New-Object System.Drawing.Imaging.EncoderParameters(1)
        $params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, $Quality)

        # Temp path to avoid lock
        $tempPath = $Path + ".tmp.jpg"
        
        # We always save as JPEG for maximum compression in this script
        # Note: If the original was PNG, it will now be a JPEG content-wise but keeping the .png extension
        # (Alternatively, we can just save back with original extension with default compression)
        
        if ($Path -match "\.png$") {
            # For PNG, we stay PNG but System.Drawing's default Save is reasonable
            $img.Save($Path + ".new.png", [System.Drawing.Imaging.ImageFormat]::Png)
            $img.Dispose()
            Move-Item ($Path + ".new.png") $Path -Force
        } else {
            $img.Save($tempPath, $codec, $params)
            $img.Dispose()
            Move-Item $tempPath $Path -Force
        }
        
        Write-Host "Compressed: $Path"
    } catch {
        Write-Host "Error processing $Path : $_"
    }
}

$largeImages = Get-ChildItem -Path "assets" -Recurse -File | Where-Object { $_.Length -gt 512000 -and $_.Extension -match "\.(jpg|jpeg|png)$" }

foreach ($file in $largeImages) {
    Compress-Image -Path $file.FullName
}
