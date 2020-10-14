import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:unify/AppTheme.dart';
import 'package:unify/MainPage.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/Screens/Welcome/welcome_screen.dart';

PostUser user;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  user = await getUser(firebaseAuth.currentUser.uid);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    return MaterialApp(
      title: 'Unify',
      debugShowCheckedModeBanner: false,
      home:
          firebaseAuth.currentUser != null && user != null && user.verified == 1
              ? MainPage()
              : WelcomeScreen(),
    );
  }
}
