# 🔥 CONFIGURATION FIREBASE REQUISE

Pour activer Firebase dans votre application, suivez ces étapes :

## 1. Créer un projet Firebase
- Allez sur https://console.firebase.google.com
- Créez un nouveau projet "hallal-admin"
- Activez Authentication (Email/Password)
- Activez Firestore Database
- Activez Storage

## 2. Installer Firebase CLI
npm install -g firebase-tools

## 3. Configurer Firebase pour Flutter
firebase login
firebase projects:list
flutterfire configure --project=hallal-admin

## 4. Cette commande va :
- Générer automatiquement firebase_options.dart avec vos vraies clés
- Configurer Android (google-services.json)
- Configurer iOS (GoogleService-Info.plist)
- Configurer Web

## 5. Redémarrer l'application
flutter clean
flutter pub get
flutter run -d chrome

## MODE DÉMO (sans Firebase)
Pour tester sans Firebase, commentez ces lignes dans main.dart :
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

Et utilisez des données mock dans les services.
