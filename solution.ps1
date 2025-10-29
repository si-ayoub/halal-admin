# SOLUTION FINALE - Nettoyage cache radical
Write-Host "=== NETTOYAGE CACHE RADICAL ===" -ForegroundColor Cyan

# 1. Arreter tous les processus Flutter/Chrome
Write-Host "`n1. Arret des processus..." -ForegroundColor Yellow
Get-Process | Where-Object {
    $_.ProcessName -like "*flutter*" -or 
    $_.ProcessName -like "*dart*" -or 
    $_.ProcessName -like "*chrome*"
} | Stop-Process -Force -ErrorAction SilentlyContinue

Start-Sleep -Seconds 2

# 2. Supprimer TOUT le cache Flutter
Write-Host "`n2. Suppression cache Flutter..." -ForegroundColor Yellow

$cacheDirs = @(
    "build",
    ".dart_tool",
    ".flutter-plugins",
    ".flutter-plugins-dependencies",
    ".packages"
)

foreach ($dir in $cacheDirs) {
    if (Test-Path $dir) {
        Remove-Item -Recurse -Force $dir -ErrorAction SilentlyContinue
        Write-Host "  Supprime: $dir" -ForegroundColor Gray
    }
}

# 3. Nettoyer le cache Flutter global
Write-Host "`n3. Nettoyage cache global Flutter..." -ForegroundColor Yellow
flutter clean

# 4. Supprimer le cache Chrome (CRITIQUE!)
Write-Host "`n4. Suppression cache Chrome..." -ForegroundColor Yellow

$chromeCachePaths = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Service Worker",
    "$env:LOCALAPPDATA\Temp"
)

foreach ($cachePath in $chromeCachePaths) {
    if (Test-Path $cachePath) {
        try {
            Get-ChildItem $cachePath -Recurse -ErrorAction SilentlyContinue | 
                Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "  Nettoye: $cachePath" -ForegroundColor Gray
        } catch {
            Write-Host "  Cache Chrome en cours d'utilisation (normal)" -ForegroundColor DarkGray
        }
    }
}

# 5. Recreer le projet proprement
Write-Host "`n5. Recreation environnement..." -ForegroundColor Yellow
flutter pub get

# 6. Forcer une recompilation complete
Write-Host "`n6. Recompilation complete..." -ForegroundColor Yellow
flutter build web --release

# 7. Lancement avec mode debug (pour voir les logs)
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "LANCEMENT DE L'APPLICATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`nIMPORTANT:" -ForegroundColor Red
Write-Host "  1. Chrome va s'ouvrir" -ForegroundColor White
Write-Host "  2. Appuyez sur Ctrl+Shift+Delete dans Chrome" -ForegroundColor White
Write-Host "  3. Selectionnez 'Toutes les periodes'" -ForegroundColor White
Write-Host "  4. Cochez 'Images et fichiers en cache'" -ForegroundColor White
Write-Host "  5. Cliquez sur 'Effacer les donnees'" -ForegroundColor White
Write-Host "  6. Actualisez la page (F5)" -ForegroundColor White
Write-Host "`nAppuyez sur une touche pour lancer..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

flutter run -d chrome --web-renderer html

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Si le probleme persiste ENCORE:" -ForegroundColor Yellow
Write-Host "  1. Utilisez un navigateur different (Edge, Firefox)" -ForegroundColor White
Write-Host "  2. Ou ouvrez Chrome en mode navigation privee" -ForegroundColor White
Write-Host "     (Ctrl+Shift+N puis allez sur http://localhost:xxxxx)" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Green