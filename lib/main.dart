import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'firebase_options.dart';

void main() async {
  // connection til databasen
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(FlashChat());
}

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        ChatScreen.id: (context) => ChatScreen(),
      },
    );
  }
}

// Applikationen er tilsluttet Firebase-databasen, og konfigurationen filer er i
// Under oprettelsen af projektet i Firebase-databasen
// android/app/google-servies.json
// android/build.gradle.kts
// android/app/build.gradle.kts
// ---> firebase configuration -->
// lib/firebase_options.dart
// her skal man adde dependency i projektet:
// pubspec.lock
//
// /firebase.json

// Filen firebase.json er ikke nødvendig, hvis appen kun benytter Firestore
// eller Authentication, men den er påkrævet eller nyttig, når man bruger
// Hosting, Functions, Local Emulator eller ved deployment af projektet.
// den oprettes med de kommandoer:

// - npm install -g firebase-tools
// - firebase login
// - firebase init
