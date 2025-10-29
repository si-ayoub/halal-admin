# DIAGNOSTIC COMPLET - Trouve la source REELLE du probleme
Write-Host "=== DIAGNOSTIC APPROFONDI ===" -ForegroundColor Cyan

# 1. Verifier l'encodage REEL des fichiers
Write-Host "`n1. ENCODAGE DES FICHIERS SOURCE:" -ForegroundColor Yellow

$files = @(
    "lib\presentation\screens\auth\home_page.dart",
    "lib\core\constants\app_strings.dart",
    "lib\presentation\widgets\restaurant_card.dart"
)

foreach ($f in $files) {
    if (Test-Path $f) {
        $bytes = [System.IO.File]::ReadAllBytes($f)
        
        # Detection BOM
        $hasBOM = $false
        $encoding = "Unknown"
        
        if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            $encoding = "UTF-8 avec BOM"
            $hasBOM = $true
        } elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
            $encoding = "UTF-16 LE"
        } elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
            $encoding = "UTF-16 BE"
        } else {
            $encoding = "UTF-8 sans BOM (ou ASCII)"
        }
        
        Write-Host "  $f" -ForegroundColor White
        Write-Host "    Encodage detecte: $encoding" -ForegroundColor Gray
        
        # Lire le contenu et chercher les caracteres problematiques
        $content = Get-Content $f -Raw
        
        if ($content -match "Ã©|Ã¨|Ã |â€¢|ðŸ|â†'") {
            Write-Host "    *** PROBLEME TROUVE: Caracteres mal encodes DANS LE FICHIER ***" -ForegroundColor Red
            
            # Afficher quelques exemples
            $matches = [regex]::Matches($content, ".{0,20}(Ã©|Ã¨|Ã |â€¢|ðŸ|â†').{0,20}")
            foreach ($match in $matches | Select-Object -First 3) {
                Write-Host "      Exemple: $($match.Value)" -ForegroundColor DarkRed
            }
        } else {
            Write-Host "    OK - Pas de caracteres mal encodes detectes" -ForegroundColor Green
        }
    } else {
        Write-Host "  $f - FICHIER INTROUVABLE" -ForegroundColor Red
    }
}

# 2. Verifier les fichiers BUILD generes
Write-Host "`n2. FICHIERS BUILD GENERES:" -ForegroundColor Yellow

if (Test-Path "build\web") {
    $buildFiles = Get-ChildItem "build\web" -Recurse -Include "*.js","*.html" | Select-Object -First 5
    
    foreach ($bf in $buildFiles) {
        $buildContent = Get-Content $bf.FullName -Raw -ErrorAction SilentlyContinue
        
        if ($buildContent -match "Ã©|Ã¨|Ã |â€¢|ðŸ") {
            Write-Host "  *** PROBLEME dans: $($bf.Name) ***" -ForegroundColor Red
        }
    }
} else {
    Write-Host "  Dossier build\web n'existe pas (normal si pas encore build)" -ForegroundColor Gray
}

# 3. Verifier la configuration pubspec.yaml
Write-Host "`n3. CONFIGURATION PROJET:" -ForegroundColor Yellow

if (Test-Path "pubspec.yaml") {
    $pubspec = Get-Content "pubspec.yaml" -Raw
    
    # Verifier si flutter_localizations est configure
    if ($pubspec -match "flutter_localizations") {
        Write-Host "  flutter_localizations: PRESENT" -ForegroundColor Green
        
        # Verifier l10n.yaml
        if (Test-Path "l10n.yaml") {
            Write-Host "  l10n.yaml: PRESENT" -ForegroundColor Green
        } else {
            Write-Host "  l10n.yaml: ABSENT (peut causer des problemes)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  flutter_localizations: ABSENT" -ForegroundColor Gray
    }
}

# 4. Verifier les fichiers de localisation
Write-Host "`n4. FICHIERS DE LOCALISATION:" -ForegroundColor Yellow

$l10nDirs = @("lib\l10n", "lib\localization", "assets\translations")

foreach ($dir in $l10nDirs) {
    if (Test-Path $dir) {
        Write-Host "  Trouve: $dir" -ForegroundColor Green
        $arbFiles = Get-ChildItem $dir -Filter "*.arb" -ErrorAction SilentlyContinue
        
        foreach ($arb in $arbFiles) {
            Write-Host "    - $($arb.Name)" -ForegroundColor Gray
            
            $arbContent = Get-Content $arb.FullName -Raw
            if ($arbContent -match "Ã©|Ã¨|Ã ") {
                Write-Host "      *** PROBLEME TROUVE dans ce fichier ARB ***" -ForegroundColor Red
            }
        }
    }
}

# 5. Lister TOUS les fichiers .dart avec des caracteres francais
Write-Host "`n5. RECHERCHE COMPLETE DANS TOUS LES .DART:" -ForegroundColor Yellow

$allDartFiles = Get-ChildItem "lib" -Recurse -Filter "*.dart" -ErrorAction SilentlyContinue

$problematicFiles = @()

foreach ($df in $allDartFiles) {
    $dartContent = Get-Content $df.FullName -Raw -ErrorAction SilentlyContinue
    
    # Chercher des mots francais avec accents MAL encodes
    if ($dartContent -match "Ã©|Ã¨|Ã |Ã´|Ã®|Ã§|â€¢|ðŸ|â†'|Â©") {
        $problematicFiles += $df.FullName
        Write-Host "  *** $($df.FullName)" -ForegroundColor Red
    }
}

if ($problematicFiles.Count -eq 0) {
    Write-Host "  Aucun fichier avec caracteres mal encodes trouve" -ForegroundColor Green
} else {
    Write-Host "`n  TOTAL: $($problematicFiles.Count) fichiers avec problemes d'encodage" -ForegroundColor Red
}

# 6. Verifier la configuration VS Code / editeur
Write-Host "`n6. CONFIGURATION EDITEUR:" -ForegroundColor Yellow

if (Test-Path ".vscode\settings.json") {
    $vscodeSettings = Get-Content ".vscode\settings.json" -Raw
    
    if ($vscodeSettings -match '"files.encoding":\s*"utf8"') {
        Write-Host "  VS Code: UTF-8 configure" -ForegroundColor Green
    } else {
        Write-Host "  VS Code: Encodage UTF-8 NON configure explicitement" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Pas de configuration VS Code trouvee" -ForegroundColor Gray
}

# 7. Test rapide de compilation
Write-Host "`n7. TEST DE COMPILATION:" -ForegroundColor Yellow
Write-Host "  Lancement flutter analyze..." -ForegroundColor Gray

$analyzeResult = flutter analyze 2>&1
$hasWarnings = $analyzeResult -match "warning|error"

if ($hasWarnings) {
    Write-Host "  Des warnings/errors detectes - voir ci-dessous:" -ForegroundColor Yellow
    $analyzeResult | Where-Object { $_ -match "warning|error" } | Select-Object -First 5 | ForEach-Object {
        Write-Host "    $_" -ForegroundColor DarkYellow
    }
}

# RESUME
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "RESUME DU DIAGNOSTIC:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($problematicFiles.Count -gt 0) {
    Write-Host "`n*** PROBLEME IDENTIFIE ***" -ForegroundColor Red
    Write-Host "$($problematicFiles.Count) fichier(s) contiennent des caracteres mal encodes" -ForegroundColor Red
    Write-Host "`nFichiers a corriger:" -ForegroundColor Yellow
    $problematicFiles | ForEach-Object { Write-Host "  - $_" -ForegroundColor White }
} else {
    Write-Host "`nAucun probleme d'encodage trouve dans les fichiers sources!" -ForegroundColor Green
    Write-Host "Le probleme vient probablement:" -ForegroundColor Yellow
    Write-Host "  1. Du cache Flutter (build/)" -ForegroundColor White
    Write-Host "  2. Du cache Chrome" -ForegroundColor White
    Write-Host "  3. Des fichiers generes automatiquement" -ForegroundColor White
}

Write-Host "`n========================================" -ForegroundColor Cyan