$files = Get-ChildItem -Filter *.html
foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    
    # Common garbled UTF-8 sequences
    $replacements = @{
        "mÂ²" = "m&sup2;";
        "m\u00b2" = "m&sup2;";
        "â€“" = "&ndash;";
        "â€”" = "&mdash;";
        "ðŸ“¦" = "📦";
        "ðŸ›‹ï¸ " = "🛋️";
        "ðŸ› ï¸ " = "🛌";
        "ðŸ  " = "🏠";
        "ðŸš—" = "🚗";
        "ðŸ ¡" = "🏡";
        "ðŸ ˜ï¸ " = "🏡";
        "ðŸ ­" = "🏭";
        "ðŸ ª" = "🏪";
        "ðŸ ¬" = "🏢";
        "ðŸ ¢" = "🏬";
        "ðŸ —ï¸ " = "🏗️";
        "ðŸš›" = "🚚"
    }

    $modified = $false
    foreach ($key in $replacements.Keys) {
        if ($content.Contains($key)) {
            $content = $content.Replace($key, $replacements[$key])
            $modified = $true
        }
    }

    if ($modified) {
        [System.IO.File]::WriteAllText($file.FullName, $content, (New-Object System.Text.UTF8Encoding $false))
        Write-Host "Fixed encoding in $($file.Name)"
    }
}
