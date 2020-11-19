import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  primarySwatch: Colors.grey,
  primaryColor: Colors.black,
  brightness: Brightness.dark,
  backgroundColor: Color.fromRGBO(36, 35, 49, 1.0),
  accentColor: Colors.white,
  accentIconTheme: IconThemeData(color: Colors.black),
  dividerColor: Colors.black12,
  appBarTheme: AppBarTheme(brightness: Brightness.dark),
);

// backgroundColor: Color.fromRGBO(36, 35, 49, 1.0),
// backgroundColor: Color.fromRGBO(29, 26, 49, 1.0),

final lightTheme = ThemeData(
  primarySwatch: Colors.grey,
  primaryColor: Colors.white,
  brightness: Brightness.light,
  backgroundColor: Colors.white,
  accentColor: Colors.black,
  accentIconTheme: IconThemeData(color: Colors.white),
  dividerColor: Colors.blueGrey.shade50,
  appBarTheme: AppBarTheme(brightness: Brightness.light),
);
