import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kPrimaryColor = Color(0xFF6F35A5);
const kPrimaryLightColor = Color(0xFFF1E6FF);
FirebaseAuth fAuth = FirebaseAuth.instance;

class Constants {
  static String text =
      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.";
  static String description =
      "Lorem Ipsum is simply dummy text of the printing and typesetting industry.";
  static String username = "noreplytheircircleapp@gmail.com";
  static String password = "chelseafc00";
  static String dummyDescription = "";
  static String serverToken =
      'AAAAJqrwc8E:APA91bH4aq4iUxbsFitrRD4jV_tQcwIFw1PJTiCqgzX1rQ_MtORMEPmG-Q5On0Ip7xoDtp7ceptPNa0avlsHTXZq_0H3lswJU73chkVjw-GDkLkd3jDNGiwWscY4z0fE4j6T0tdCy7x8';
  static FirebaseMessaging fm = FirebaseMessaging();
  static String t_and_c =
      "http://www.theircircleapp.com/terms_and_conditions.html";
  static String privacy_policy =
      "http://www.theircircleapp.com/privacy_policy.html";
  static String dummyImageUrl =
      'https://hdwallpaperim.com/wp-content/uploads/2017/09/07/468584-One-Punch_Man-Saitama-748x421.jpg';

  static termsDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.NO_HEADER,
      body: StatefulBuilder(builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(
                "Welcome to TheirCircle",
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "You must agree to these terms before posting.",
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "1. Any type of bullying will not be tolerated.",
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "2. Zero tolerance policy on exposing people's personal information.",
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "3. Do not clutter people's feed with useless or offensive information.",
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "4. If your posts are being reported consistently you will be banned.",
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "5. Posting explicit photos under any circumstances will not be tolerated.",
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "Keep a clean and friendly environment. Violation of these terms will result in a permanent ban on your account.",
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              ),
              SizedBox(height: 10.0),
              FlatButton(
                color: Colors.blue,
                child: Text(
                  "I agree to these terms.",
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ),
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setBool('isFirst', true);
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 10.0),
            ],
          ),
        );
      }),
    )..show();
  }

  static int checkUniversity() {
    var userEmail = fAuth.currentUser.email;
    if (userEmail.contains('utoronto')) {
      return 0;
    } else {
      return 1;
    }
  }

  static Color color() {
    Random random = new Random();
    int index = random.nextInt(6);
    switch (index) {
      case 1:
        {
          return Colors.deepOrangeAccent;
        }
        break;
      case 2:
        {
          return Colors.deepPurpleAccent;
        }
        break;
      case 3:
        {
          return Colors.blueAccent;
        }
        break;
      case 4:
        {
          return Colors.purpleAccent;
        }
        break;
      case 5:
        {
          return Colors.redAccent;
        }
        break;
      default:
        {
          return Colors.indigoAccent;
        }
        break;
    }
  }
}
