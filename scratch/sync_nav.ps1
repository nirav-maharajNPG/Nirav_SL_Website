$indexContent = Get-Content -Raw index.html
if ($indexContent -match '(?ms)<nav class="navbar".*?</nav>') {
    $navHtml = $Matches[0]
    Write-Host "Found navbar in index.html"
} else {
    Write-Error "Could not find navbar in index.html"
    exit
}

Get-ChildItem *.html -Exclude index.html | ForEach-Object {
    $content = Get-Content -Raw $_.FullName
    $currentNavHtml = $navHtml
    
    # Check if the page uses navbar-blue
    if ($content -match 'navbar-blue') {
        $currentNavHtml = $navHtml -replace 'navbar"', 'navbar navbar-blue"'
    }
    
    # Use a broader regex to catch different navbar class combinations
    $newContent = $content -replace '(?ms)<nav class="navbar.*?>.*?</nav>', $currentNavHtml
    if ($newContent -ne $content) {
        Set-Content -Path $_.FullName -Value $newContent
        Write-Host "Updated $($_.Name)"
    } else {
        Write-Host "No change for $($_.Name)"
    }
}
