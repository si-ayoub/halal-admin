# Script de correction encodage
$file = "lib\presentation\screens\auth\home_page.dart"

Write-Host "Correction en cours..." -ForegroundColor Cyan

# Backup
Copy-Item $file "$file.backup" -Force

# Lecture avec detection auto encodage
$content = Get-Content $file -Raw -Encoding UTF8

# Corrections simples - on retire TOUS les accents
$fixes = @{
    'DÃ©lice' = 'Delice'
    'DÃ©jÃ ' = 'Deja'
    'CrÃ©ez' = 'Creez'
    'BÃ©nÃ©ficiez' = 'Beneficiez'
    'marocaine' = 'marocaine'
    'turques' = 'turques'
    'libanaise' = 'libanaise'
    'VisibilitÃ©' = 'Visibilite'
    'rÃ©servÃ©s' = 'reserves'
    'prÃ¨s' = 'pres'
    'Ã©tiez' = 'etiez'
    'ItinÃ©raire' = 'Itineraire'
    'SpÃ©cialitÃ©s' = 'Specialites'
}

foreach ($old in $fixes.Keys) {
    $content = $content -replace [regex]::Escape($old), $fixes[$old]
}

# Nettoyage caracteres speciaux
$content = $content -replace '[^\x00-\x7F]+', ''

# Sauvegarde UTF8 avec BOM
$utf8 = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText($file, $content, $utf8)

Write-Host "Fichier corrige!" -ForegroundColor Green

# Nettoyage Flutter
Write-Host "`nNettoyage Flutter..." -ForegroundColor Yellow
flutter clean | Out-Null
flutter pub get | Out-Null

Write-Host "`nLancement de l'application..." -ForegroundColor Green
flutter run -d chrome