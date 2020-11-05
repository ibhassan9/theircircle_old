import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:unify/Components/AppTheme.dart';
import 'package:unify/Home/main_screen.dart';
import 'package:unify/pages/MainPage.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/Screens/Welcome/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseDatabase.instance.setPersistenceEnabled(false);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    return MaterialApp(
      title: 'TheirCircle',
      debugShowCheckedModeBanner: false,
      home: firebaseAuth.currentUser != null ? MainScreen() : WelcomeScreen(),
    );
  }
}
