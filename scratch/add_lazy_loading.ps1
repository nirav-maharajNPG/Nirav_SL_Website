# PowerShell script to add loading="lazy" to all <img> tags that don't have it.
$files = Get-ChildItem -Filter *.html -Recurse

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    # Regex to find <img> tags that don't already have loading="lazy"
    # Matches <img ... >
    $pattern = '(?i)<img(?![^>]*\bloading="lazy"\b)([^>]*)>'
    # Replacement adds loading="lazy" at the end of the attributes
    $replacement = '<img$1 loading="lazy">'
    
    $newContent = [regex]::Replace($content, $pattern, $replacement)
    
    if ($content -ne $newContent) {
        Set-Content $file.FullName $newContent
        Write-Host "Updated $($file.Name)"
    }
}
