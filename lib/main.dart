import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unify/Components/theme.dart';
import 'package:unify/Components/theme_notifier.dart';
import 'package:unify/Home/main_screen.dart';
import 'package:unify/pages/MainPage.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/Screens/Welcome/welcome_screen.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseDatabase.instance.setPersistenceEnabled(false);
  //cameras = await availableCameras();
  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]).then((_) {
    SharedPreferences.getInstance().then((prefs) {
      var darkModeOn = prefs.getBool('darkMode') ?? true;
      runApp(
        ChangeNotifierProvider<ThemeNotifier>(
          create: (_) => ThemeNotifier(darkModeOn ? darkTheme : lightTheme),
          child: MyApp(),
        ),
      );
    });
  });
  // runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: 'TheirCircle',
      theme: themeNotifier.getTheme(),
      debugShowCheckedModeBanner: false,
      home: firebaseAuth.currentUser != null ? MainScreen() : WelcomeScreen(),
    );
  }
}
