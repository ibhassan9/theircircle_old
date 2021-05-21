import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Home/main_screen.dart';
import 'package:unify/pages/DB.dart';
import 'package:unify/pages/Screens/Welcome/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseDatabase.instance.setPersistenceEnabled(false);
  var uni = Constants.checkUniversity();
  if (uni != null) {
    uniKey = uni;
    FIR_UID = FirebaseAuth.instance.currentUser.uid;
    FIR_AUTH = FirebaseAuth.instance;
  }
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
    //final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: 'TheirCircle',
      theme: ThemeData(
          //
          visualDensity: VisualDensity.adaptivePlatformDensity,
          buttonColor: Colors.grey.shade700,
          splashColor: Colors.white,
          primarySwatch: Colors.grey,
          primaryColor: Colors.white,
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          accentColor: Colors.black,
          accentIconTheme: IconThemeData(color: Colors.white),
          dividerColor: Colors.blueGrey[100],
          appBarTheme: AppBarTheme(brightness: Brightness.light),
          shadowColor: Colors.deepPurpleAccent[100],
          cardColor: Colors.white),
      darkTheme: ThemeData(
          //
          visualDensity: VisualDensity.adaptivePlatformDensity,
          buttonColor: Colors.grey.shade200,
          splashColor: Color.fromRGBO(36, 35, 49, 1.0),
          primarySwatch: Colors.grey,
          primaryColor: Colors.black,
          brightness: Brightness.dark,
          backgroundColor: Colors.grey.shade900,
          accentColor: Colors.white,
          accentIconTheme: IconThemeData(color: Colors.black),
          dividerColor: Colors.black12,
          appBarTheme: AppBarTheme(brightness: Brightness.dark),
          shadowColor: Colors.deepPurpleAccent,
          cardColor: Colors.black12),
      debugShowCheckedModeBanner: false,
      home: FIR_AUTH.currentUser != null && uniKey != null
          ? MainScreen()
          : WelcomeScreen(),
    );
  }
}
