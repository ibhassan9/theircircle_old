import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unify/Components/theme.dart';
import 'package:unify/Components/theme_notifier.dart';
import 'package:unify/Home/main_screen.dart';
import 'package:unify/pages/MainPage.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/Screens/Welcome/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseDatabase.instance.setPersistenceEnabled(false);
  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]).then((_) {
    // SharedPreferences.getInstance().then((prefs) {
    //   var darkModeOn = prefs.getBool('darkMode') ?? false;
    //   runApp(
    //     ChangeNotifierProvider<ThemeNotifier>(
    //       create: (_) => ThemeNotifier(darkModeOn ? darkTheme : lightTheme),
    //       child: MyApp(),
    //     ),
    //   );
    // });
    runApp(MyApp());
  });
  // runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    //final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: 'TheirCircle',
      theme: ThemeData(
          buttonColor: Colors.grey.shade900,
          splashColor: Colors.white,
          primarySwatch: Colors.grey,
          primaryColor: Colors.white,
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          accentColor: Colors.black,
          accentIconTheme: IconThemeData(color: Colors.white),
          dividerColor: Colors.grey[100],
          appBarTheme: AppBarTheme(brightness: Brightness.light),
          shadowColor: Colors.deepPurpleAccent[100],
          cardColor: Colors.white),
      darkTheme: ThemeData(
          buttonColor: Colors.grey.shade200,
          splashColor: Color.fromRGBO(36, 35, 49, 1.0),
          primarySwatch: Colors.grey,
          primaryColor: Colors.black,
          brightness: Brightness.dark,
          backgroundColor: Color.fromRGBO(36, 35, 49, 1.0),
          accentColor: Colors.white,
          accentIconTheme: IconThemeData(color: Colors.black),
          dividerColor: Colors.black12,
          appBarTheme: AppBarTheme(brightness: Brightness.dark),
          shadowColor: Colors.deepPurpleAccent,
          cardColor: Color.fromRGBO(36, 35, 49, 1.0)),
      debugShowCheckedModeBanner: false,
      home: firebaseAuth.currentUser != null ? MainScreen() : WelcomeScreen(),
    );
  }
}
