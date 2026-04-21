Get-ChildItem *.html | ForEach-Object {
    $content = Get-Content -Raw $_.FullName
    $newContent = $content -replace '(?i)<p style="[^"]*">\*Excluding VAT</p>', '<p class="vat-text">*Excluding VAT</p>'
    if ($newContent -ne $content) {
        Set-Content -Path $_.FullName -Value $newContent
        Write-Host "Updated $($_.Name)"
    }
}
