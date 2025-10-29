# 🍽️ Halal Admin

Application d'administration pour la plateforme Halal Boost.

## 📋 Description

Halal Admin est une application Flutter qui permet aux restaurateurs de gérer leur présence sur la plateforme Halal Boost.

## ✨ Fonctionnalités

- 🔐 Authentification sécurisée avec Firebase
- 📊 Dashboard avec analytics
- 🍕 Gestion du menu et des plats
- 📸 Upload de photos
- ⏰ Gestion des horaires d'ouverture
- 📱 Interface responsive (Web, iOS, Android)

## 🚀 Installation

### Prérequis
- Flutter SDK (dernière version stable)
- Firebase account
- Un éditeur de code (VS Code, Android Studio)

### Configuration

1. Cloner le repository
\\\ash
git clone https://github.com/si-ayoub/halal-admin.git
cd halal-admin
\\\

2. Installer les dépendances
\\\ash
flutter pub get
\\\

3. Configurer Firebase
   - Créer un projet sur [Firebase Console](https://console.firebase.google.com)
   - Télécharger les fichiers de configuration
   - Placer \google-services.json\ dans \ndroid/app/\
   - Générer \irebase_options.dart\ avec FlutterFire CLI

4. Lancer l'application
\\\ash
flutter run -d chrome
\\\

## 🏗️ Structure du projet

\\\
lib/
├── core/              # Configuration et constantes
├── data/              # Modèles et services
│   ├── models/        # Classes de données
│   └── services/      # Services Firebase
└── presentation/      # Interface utilisateur
    └── screens/       # Écrans de l'app
\\\

## 🛠️ Technologies utilisées

- **Flutter** : Framework UI
- **Firebase** : Backend (Auth, Firestore, Storage)
- **Provider** : Gestion d'état

## 👨‍💻 Auteur

**Alilou Ayoub** - [2adev]
- Email: 2adevellopment@gmail.com
- GitHub: [@si-ayoub](https://github.com/si-ayoub)

## 📄 Licence

Ce projet est privé et propriétaire.
