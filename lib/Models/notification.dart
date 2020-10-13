import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:unify/Components/Constants.dart';
import 'package:http/http.dart' as http;
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/user.dart';

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
String title = "UNIFY";

Future<Null> sendPush(int nID, String token, String text) async {
  await Constants.fm.requestNotificationPermissions(
    const IosNotificationSettings(
        sound: true, badge: true, alert: true, provisional: false),
  );

  var uid = firebaseAuth.currentUser.uid;
  var me = await getUser(uid);

  await http.post('https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${Constants.serverToken}',
      },
      body: json.encode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': nID == 0
                ? "${me.name} liked your post: $text"
                : "${me.name} commented on your post: $text",
            'title': 'Unify'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done'
          },
          'to': token,
        },
      ));
}

Future<Null> sendPushClub(Club club, int nID, String token, String text) async {
  var body = "";

  await Constants.fm.requestNotificationPermissions(
    const IosNotificationSettings(
        sound: true, badge: true, alert: true, provisional: false),
  );

  var uid = firebaseAuth.currentUser.uid;
  var me = await getUser(uid);
  var t = "${club.name}";

  switch (nID) {
    case 0:
      body = "${me.name} liked your post: $text";
      break;
    case 1:
      body = "${me.name} commented on your post: $text";
      break;
    case 2:
      body = "Your join request has been approved.";
      break;
    case 3:
      body = "Your event has been removed by admin from the shared calender.";
      break;
    case 4:
      body = "${me.name} added an note: $text";
      break;
    case 5:
      body = "${me.name} sent a request to join your club.";
      break;
    case 6:
      body = "${me.name} joined your club.";
      break;
  }

  await http.post('https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${Constants.serverToken}',
      },
      body: json.encode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': body, 'title': t},
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done'
          },
          'to': token,
        },
      ));
}

Future<Null> sendPushCourse(
    Course course, int nID, String token, String text) async {
  var body = "";

  await Constants.fm.requestNotificationPermissions(
    const IosNotificationSettings(
        sound: true, badge: true, alert: true, provisional: false),
  );

  var uid = firebaseAuth.currentUser.uid;
  var me = await getUser(uid);
  var t = "${course.name}";

  switch (nID) {
    case 0:
      body = "${me.name} liked your post: $text";
      break;
    case 1:
      body = "${me.name} commented on your post: $text";
      break;
    case 4:
      body = "${me.name} added a note: $text";
      break;
  }

  await http.post('https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${Constants.serverToken}',
      },
      body: json.encode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': body, 'title': t},
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done'
          },
          'to': token,
        },
      ));
}
