$indexContent = Get-Content -Raw index.html
if ($indexContent -match '(?ms)<footer class="footer".*?</footer>') {
    $footerHtml = $Matches[0]
} else {
    Write-Error "Could not find footer in index.html"
    exit
}

Get-ChildItem *.html -Exclude index.html | ForEach-Object {
    $content = Get-Content -Raw $_.FullName
    $newContent = $content -replace '(?ms)<footer class="footer".*?</footer>', $footerHtml
    if ($newContent -ne $content) {
        Set-Content -Path $_.FullName -Value $newContent
        Write-Host "Updated $($_.Name)"
    }
}
