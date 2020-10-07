import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFF6F35A5);
const kPrimaryLightColor = Color(0xFFF1E6FF);
FirebaseAuth fAuth = FirebaseAuth.instance;

class Constants {
  static String text =
      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.";
  static String description =
      "Lorem Ipsum is simply dummy text of the printing and typesetting industry.";
  static String username = "noreplyunifyapp@gmail.com";
  static String password = "chelseafc00";
  static String dummyDescription = "Insert Bio Here...";

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
