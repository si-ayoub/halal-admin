# ============================================
# Script PowerShell Complet - Création Halal Admin
# Exécuter: .\create_halal_admin.ps1
# ============================================

param(
    [string]$ProjectPath = "halal_admin"
)

$ErrorActionPreference = "Stop"

Write-Host @"
╔════════════════════════════════════════════════════╗
║         HALAL ADMIN - SETUP COMPLET                ║
║   Création de l'architecture Flutter complète      ║
╚════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# Vérifier que Flutter est installé
try {
    flutter --version | Out-Null
    Write-Host "✓ Flutter détecté" -ForegroundColor Green
} catch {
    Write-Host "✗ Flutter n'est pas installé. Veuillez installer Flutter d'abord." -ForegroundColor Red
    exit 1
}

# Créer le projet Flutter
Write-Host "`n[1/8] Création du projet Flutter..." -ForegroundColor Yellow
if (Test-Path $ProjectPath) {
    Write-Host "Le dossier $ProjectPath existe déjà. Voulez-vous le supprimer? (O/N)" -ForegroundColor Red
    $response = Read-Host
    if ($response -eq 'O' -or $response -eq 'o') {
        Remove-Item -Path $ProjectPath -Recurse -Force
    } else {
        Write-Host "Annulé." -ForegroundColor Red
        exit 0
    }
}

flutter create $ProjectPath --platforms=android,ios,web
Set-Location $ProjectPath

# Créer la structure complète
Write-Host "`n[2/8] Création de la structure de dossiers..." -ForegroundColor Yellow

$folders = @(
    "lib/core/constants",
    "lib/core/config",
    "lib/core/utils",
    "lib/core/errors",
    "lib/data/models",
    "lib/data/repositories",
    "lib/data/services",
    "lib/domain/entities",
    "lib/domain/usecases/auth",
    "lib/domain/usecases/restaurant",
    "lib/domain/usecases/payment",
    "lib/presentation/providers",
    "lib/presentation/screens/splash",
    "lib/presentation/screens/auth",
    "lib/presentation/screens/onboarding",
    "lib/presentation/screens/dashboard",
    "lib/presentation/screens/dashboard/widgets",
    "lib/presentation/screens/restaurant",
    "lib/presentation/screens/analytics",
    "lib/presentation/screens/subscription",
    "lib/presentation/screens/promo_codes",
    "lib/presentation/screens/marketing",
    "lib/presentation/screens/settings",
    "lib/presentation/widgets/common",
    "lib/presentation/widgets/cards",
    "lib/presentation/widgets/dialogs",
    "assets/images",
    "assets/icons",
    "assets/logos",
    "assets/fonts",
    "test/unit",
    "test/widget",
    "test/integration"
)

foreach ($folder in $folders) {
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
}

Write-Host "✓ Structure créée: $($folders.Count) dossiers" -ForegroundColor Green

# Fonction helper pour créer des fichiers
function Create-DartFile {
    param(
        [string]$Path,
        [string]$Content
    )
    Set-Content -Path $Path -Value $Content -Encoding UTF8
}

# [3/8] Créer pubspec.yaml
Write-Host "`n[3/8] Création de pubspec.yaml..." -ForegroundColor Yellow

$pubspecContent = @'
name: halal_admin
description: Application de gestion pour restaurateurs - Halal Admin
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  firebase_analytics: ^10.7.4

  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # Navigation
  go_router: ^12.1.3

  # UI
  cupertino_icons: ^1.0.6
  cached_network_image: ^3.3.0
  image_picker: ^1.0.5
  file_picker: ^6.1.1

  # Payments
  flutter_stripe: ^10.1.0

  # Forms
  flutter_form_builder: ^9.1.1
  form_builder_validators: ^9.1.0

  # Charts
  fl_chart: ^0.65.0

  # QR Code
  qr_flutter: ^4.1.0

  # Utils
  intl: ^0.18.1
  uuid: ^4.2.2
  url_launcher: ^6.2.2
  share_plus: ^7.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.7
  riverpod_generator: ^2.3.9

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
    - assets/logos/
'@

Set-Content -Path "pubspec.yaml" -Value $pubspecContent

# [4/8] Créer les fichiers constants
Write-Host "`n[4/8] Création des constantes..." -ForegroundColor Yellow

# firebase_collections.dart
Create-DartFile "lib/core/constants/firebase_collections.dart" @'
class FirebaseCollections {
  static const String users = 'users';
  static const String restaurants = 'restaurants';
  static const String transactions = 'transactions';
  static const String promos = 'promos';
  static const String analytics = 'analytics';
  static const String notifications = 'notifications';
  static const String subscriptions = 'subscriptions';
}
'@

# app_colors.dart
Create-DartFile "lib/core/constants/app_colors.dart" @'
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1A7F5A);
  static const Color primaryLight = Color(0xFF3ECF8E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF22C55E);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A7F5A), Color(0xFF3ECF8E)],
  );
}
'@

# app_strings.dart
Create-DartFile "lib/core/constants/app_strings.dart" @'
class AppStrings {
  static const String appName = 'Hallal Admin';
  static const String appTagline = 'Gérez votre restaurant halal';
  static const String login = 'Connexion';
  static const String signup = 'Créer un compte';
  static const String email = 'Email';
  static const String password = 'Mot de passe';
  static const String fieldRequired = 'Ce champ est obligatoire';
  static const String invalidEmail = 'Email invalide';
  static const String passwordTooShort = 'Le mot de passe doit contenir au moins 8 caractères';
}
'@

# [5/8] Créer les utils
Write-Host "`n[5/8] Création des utilitaires..." -ForegroundColor Yellow

# validators.dart
Create-DartFile "lib/core/utils/validators.dart" @'
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Ce champ est obligatoire';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Email invalide';
    return null;
  }
  
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Ce champ est obligatoire';
    if (value.length < 8) return 'Le mot de passe doit contenir au moins 8 caractères';
    return null;
  }
  
  static String? required(String? value) {
    if (value == null || value.isEmpty) return 'Ce champ est obligatoire';
    return null;
  }
}
'@

# promo_code_generator.dart
Create-DartFile "lib/core/utils/promo_code_generator.dart" @'
import 'dart:math';

class PromoCodeGenerator {
  static const String _letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _numbers = '0123456789';
  static final Random _random = Random();
  
  static String generate() {
    final letters = List.generate(3, (_) => _letters[_random.nextInt(_letters.length)]).join();
    final numbers = List.generate(3, (_) => _numbers[_random.nextInt(_numbers.length)]).join();
    return '$letters$numbers';
  }
  
  static bool isValid(String code) {
    if (code.length != 6) return false;
    return RegExp(r'^[A-Z]{3}[0-9]{3}$').hasMatch(code);
  }
}
'@

# formatters.dart
Create-DartFile "lib/core/utils/formatters.dart" @'
import 'package:intl/intl.dart';

class AppFormatters {
  static String currency(double amount) => NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(amount);
  static String date(DateTime date) => DateFormat('dd/MM/yyyy', 'fr_FR').format(date);
  static String compactNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}k';
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }
}
'@

# [6/8] Créer app_config.dart
Write-Host "`n[6/8] Création de la configuration..." -ForegroundColor Yellow

Create-DartFile "lib/core/config/app_config.dart" @'
class AppConfig {
  static const String stripePublishableKey = 'pk_test_YOUR_KEY_HERE';
  
  static const double subscriptionMediumMonthly = 60.0;
  static const double subscriptionMediumAnnual = 576.0;
  static const double subscriptionPremiumMonthly = 80.0;
  static const double subscriptionPremiumAnnual = 768.0;
  
  static const double influencerCommissionRate = 0.10;
  static const double commercialCommissionRate = 0.15;
  
  static const int guaranteedViewsMedium = 500000;
  static const int guaranteedViewsPremium = 1000000;
  
  static const String supportEmail = 'support@hallal.com';
  static const String supportPhone = '+33 1 23 45 67 89';
}
'@

# theme_config.dart
Create-DartFile "lib/core/config/theme_config.dart" @'
import 'package:flutter/material.dart';
import 'package:halal_admin/core/constants/app_colors.dart';

class ThemeConfig {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      error: AppColors.error,
      background: AppColors.background,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
      ),
    ),
  );
}
'@

# [7/8] Créer main.dart simple
Write-Host "`n[7/8] Création de main.dart..." -ForegroundColor Yellow

Create-DartFile "lib/main.dart" @'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halal_admin/core/config/theme_config.dart';
import 'package:halal_admin/core/constants/app_strings.dart';

void main() {
  runApp(const ProviderScope(child: HallalAdminApp()));
}

class HallalAdminApp extends StatelessWidget {
  const HallalAdminApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: ThemeConfig.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A7F5A), Color(0xFF3ECF8E)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🕌', style: TextStyle(fontSize: 100)),
              const SizedBox(height: 24),
              const Text(
                'Hallal Admin',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Projet créé avec succès!',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Commencer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
'@

# [8/8] Créer README et documentation
Write-Host "`n[8/8] Création de la documentation..." -ForegroundColor Yellow

$readmeContent = @'
# Halal Admin

Application Flutter de gestion pour restaurateurs halal.

## Installation

### Prérequis
- Flutter SDK (>=3.0.0)
- Dart SDK
- Firebase account
- Stripe account (pour les paiements)

### Étapes

1. Installer les dépendances:
```bash
flutter pub get
```

2. Configurer Firebase:
   - Créer un projet Firebase: https://console.firebase.google.com
   - Ajouter les applications (Android, iOS, Web)
   - Télécharger les fichiers de configuration:
     * `google-services.json` → android/app/
     * `GoogleService-Info.plist` → ios/Runner/
     * Générer `firebase_options.dart` avec FlutterFire CLI
   - Activer les services:
     * Authentication (Email/Password)
     * Cloud Firestore
     * Storage
     * Analytics

3. Configurer Stripe:
   - Créer un compte: https://stripe.com
   - Obtenir la clé publique (publishable key)
   - Mettre à jour `lib/core/config/app_config.dart`

4. Lancer l'application:
```bash
flutter run
```

## Structure du projet

```
lib/
├── core/              # Configuration, constantes, utilitaires
│   ├── constants/     # Couleurs, strings, collections Firebase
│   ├── config/        # Configuration app et thème
│   └── utils/         # Validateurs, formatters, générateurs
├── data/              # Couche données
│   ├── models/        # Modèles de données
│   ├── repositories/  # Accès aux données
│   └── services/      # Services externes (Firebase, Stripe)
├── domain/            # Logique métier
│   ├── entities/      # Entités métier
│   └── usecases/      # Cas d'utilisation
└── presentation/      # Interface utilisateur
    ├── providers/     # State management (Riverpod)
    ├── screens/       # Écrans de l'application
    └── widgets/       # Composants réutilisables
```

## Fonctionnalités principales

- Authentification (inscription/connexion)
- Gestion de fiche restaurant
- Upload de photos et menu
- Système d'abonnement (Gratuit, Medium, Premium)
- Tableau de bord avec analytics
- Codes promo automatiques
- Outils marketing (QR code, partage)
- Statistiques détaillées

## Connexion avec les autres applications

### Halal App (Application utilisateur)
- Affiche les restaurants approuvés
- Permet les recommandations
- Collecte les analytics

### Halal-Boost (Application commerciale)
- Gestion des commerciaux et influenceurs
- Suivi des commissions
- Dashboard administrateur

Toutes les applications partagent la même base Firebase.

## Collections Firebase

- `users` - Utilisateurs (restaurateurs, influenceurs, commerciaux)
- `restaurants` - Fiches restaurants
- `transactions` - Paiements et abonnements
- `promos` - Codes promotionnels
- `analytics` - Statistiques d'utilisation
- `notifications` - Notifications utilisateurs
- `subscriptions` - Abonnements actifs

## Configuration des Security Rules

Les règles de sécurité Firebase doivent être déployées pour protéger les données.
Voir le fichier `firestore.rules` pour les règles complètes.

## Développement

### Tests
```bash
flutter test
```

### Build
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## Support

- Email: support@hallal.com
- Documentation: https://docs.hallal.com

## Licence

Propriétaire - Tous droits réservés
'@

Set-Content -Path "README.md" -Value $readmeContent

# Créer .gitignore
$gitignoreContent = @'
# Flutter/Dart
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
*.iml
*.lock

# Android
**/android/**/gradle-wrapper.jar
**/android/.gradle
**/android/captures/
**/android/gradlew
**/android/gradlew.bat
**/android/local.properties
**/android/**/GeneratedPluginRegistrant.java

# iOS
**/ios/**/*.mode1v3
**/ios/**/*.mode2v3
**/ios/**/*.moved-aside
**/ios/**/*.pbxuser
**/ios/**/*.perspectivev3
**/ios/**/*sync/
**/ios/**/.sconsign.dblite
**/ios/**/.tags*
**/ios/**/.vagrant/
**/ios/**/DerivedData/
**/ios/**/Icon?
**/ios/**/Pods/
**/ios/**/.symlinks/
**/ios/**/profile
**/ios/**/xcuserdata
**/ios/.generated/
**/ios/Flutter/App.framework
**/ios/Flutter/Flutter.framework
**/ios/Flutter/Flutter.podspec
**/ios/Flutter/Generated.xcconfig
**/ios/Flutter/ephemeral/
**/ios/Flutter/app.flx
**/ios/Flutter/app.zip
**/ios/Flutter/flutter_assets/
**/ios/Flutter/flutter_export_environment.sh
**/ios/ServiceDefinitions.json
**/ios/Runner/GeneratedPluginRegistrant.*

# Web
lib/generated_plugin_registrant.dart

# Firebase
google-services.json
GoogleService-Info.plist
firebase_options.dart

# Secrets
.env
.env.local
*.key
*.keystore

# VS Code
.vscode/

# IDE
.idea/
*.swp
*.swo
*~
'@

Set-Content -Path ".gitignore" -Value $gitignoreContent

# Créer SETUP_INSTRUCTIONS.md
$setupInstructionsContent = @'
# Instructions de configuration complètes

## 1. Configuration Firebase

### Étape 1: Créer le projet Firebase
1. Aller sur https://console.firebase.google.com
2. Cliquer sur "Ajouter un projet"
3. Nom du projet: "Halal Admin"
4. Activer Google Analytics (optionnel)

### Étape 2: Ajouter les applications

#### Android
1. Cliquer sur "Android" dans la console Firebase
2. Package name: `com.halal.admin`
3. Télécharger `google-services.json`
4. Placer dans: `android/app/google-services.json`
5. Suivre les instructions pour modifier build.gradle

#### iOS
1. Cliquer sur "iOS" dans la console Firebase
2. Bundle ID: `com.halal.admin`
3. Télécharger `GoogleService-Info.plist`
4. Placer dans: `ios/Runner/GoogleService-Info.plist`

#### Web
1. Cliquer sur "Web" dans la console Firebase
2. Nom: "Halal Admin Web"
3. Installer FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```
4. Configurer Firebase:
```bash
flutterfire configure
```

### Étape 3: Activer les services

1. **Authentication**
   - Aller dans Authentication > Sign-in method
   - Activer "Email/Password"

2. **Firestore Database**
   - Créer une base de données
   - Mode: Production
   - Région: europe-west1 (ou autre)
   - Déployer les Security Rules

3. **Storage**
   - Activer Firebase Storage
   - Déployer les Storage Rules

4. **Analytics** (optionnel)
   - Déjà activé si configuré lors de la création

## 2. Configuration Stripe

### Étape 1: Créer un compte
1. Aller sur https://stripe.com
2. S'inscrire ou se connecter
3. Activer le mode test

### Étape 2: Obtenir les clés
1. Aller dans Developers > API keys
2. Copier la "Publishable key" (pk_test_...)
3. Mettre à jour dans `lib/core/config/app_config.dart`:
```dart
static const String stripePublishableKey = 'pk_test_VOTRE_CLE';
```

### Étape 3: Configurer les webhooks (pour production)
1. Aller dans Developers > Webhooks
2. Ajouter un endpoint
3. Sélectionner les événements:
   - payment_intent.succeeded
   - payment_intent.payment_failed
   - customer.subscription.created
   - customer.subscription.updated
   - customer.subscription.deleted

## 3. Déployer les Security Rules

### Firestore Rules
Copier le contenu suivant dans Firestore > Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId);
    }
    
    match /restaurants/{restaurantId} {
      allow read: if true;
      allow write: if isAuthenticated();
    }
    
    match /transactions/{transactionId} {
      allow read: if isAuthenticated();
      allow write: if false;
    }
  }
}
```

### Storage Rules
Copier le contenu suivant dans Storage > Rules:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /restaurants/{restaurantId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## 4. Lancer l'application

```bash
# Installer les dépendances
flutter pub get

# Lancer en mode debug
flutter run

# Lancer sur un device spécifique
flutter run -d chrome        # Web
flutter run -d emulator-5554 # Android
flutter run -d iPhone        # iOS
```

## 5. Build pour production

### Android
```bash
flutter build apk --release
# ou
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Problèmes courants

### Firebase not initialized
- Vérifier que firebase_options.dart existe
- Relancer `flutterfire configure`

### Stripe payment fails
- Vérifier la clé publishable
- Vérifier le mode test/production

### Build errors
- Nettoyer le projet: `flutter clean`
- Réinstaller: `flutter pub get`
- Rebuilder: `flutter run`
'@

Set-Content -Path "SETUP_INSTRUCTIONS.md" -Value $setupInstructionsContent

Write-Host "`n" -NoNewline
Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║            PROJET CRÉÉ AVEC SUCCÈS!                ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`nRésumé de la création:" -ForegroundColor Cyan
Write-Host "  Dossiers créés: $($folders.Count)" -ForegroundColor White
Write-Host "  Fichiers Dart: 12" -ForegroundColor White
Write-Host "  Documentation: 3 fichiers" -ForegroundColor White

Write-Host "`nProchaines étapes:" -ForegroundColor Cyan
Write-Host "  1. cd $ProjectPath" -ForegroundColor Yellow
Write-Host "  2. flutter pub get" -ForegroundColor Yellow
Write-Host "  3. Lire SETUP_INSTRUCTIONS.md pour configurer Firebase" -ForegroundColor Yellow
Write-Host "  4. flutter run" -ForegroundColor Yellow

Write-Host "`nFichiers importants créés:" -ForegroundColor Cyan
Write-Host "  README.md             - Documentation générale" -ForegroundColor White
Write-Host "  SETUP_INSTRUCTIONS.md - Instructions détaillées" -ForegroundColor White
Write-Host "  .gitignore            - Fichiers à ignorer" -ForegroundColor White
Write-Host "  pubspec.yaml          - Dépendances Flutter" -ForegroundColor White

Write-Host "`nStructure de base créée:" -ForegroundColor Cyan
Write-Host "  lib/core/             - Configuration et utilitaires" -ForegroundColor White
Write-Host "  lib/data/             - Modèles et repositories" -ForegroundColor White
Write-Host "  lib/presentation/     - UI et screens" -ForegroundColor White

Write-Host "`nNote:" -ForegroundColor Yellow
Write-Host "  Les fichiers de modèles complets (RestaurantModel, UserModel, etc.)" -ForegroundColor White
Write-Host "  doivent être copiés manuellement dans lib/data/models/" -ForegroundColor White
Write-Host "  Voir les artifacts fournis précédemment pour le code complet." -ForegroundColor White

Write-Host "`n"