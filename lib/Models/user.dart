import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/MainPage.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/VerificationPage.dart';

class PostUser {
  String id;
  String email;
  String name;
  String verified;

  PostUser({this.id, this.email, this.name, this.verified});
}

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
DatabaseReference usersDBref =
    FirebaseDatabase.instance.reference().child('users');

Future signInUser(String email, String password, BuildContext context) async {
  await firebaseAuth
      .signInWithEmailAndPassword(email: email, password: password)
      .then((result) async {
    var uni = Constants.checkUniversity();
    PostUser _user = await getUser(result.user.uid);
    if (_user.verified != "verified") {
      var code = await sendVerificationCode(email);
      if (code == 0) {
        print("Error retreiving code...");
        return;
      }
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VerificationPage(
                  code: code,
                  email: email,
                  password: password,
                  uid: result.user.uid)));
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('uni', uni);
      prefs.setString('name', _user.name);
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MainPage()));
    }
  }).catchError((err) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(err.toString()),
            actions: [
              FlatButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  });
}

Future registerUser(
    String name, String email, String password, BuildContext context) async {
  if (email.contains(new RegExp(r'yorku', caseSensitive: false)) == false &&
      email.contains(new RegExp(r'utoronto', caseSensitive: false)) == false) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content:
                Text("Please sign up using your university email address."),
            actions: [
              FlatButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
    return;
  }
  var uniKey = checkUniversityWithEmail(email);
  await firebaseAuth
      .createUserWithEmailAndPassword(email: email, password: password)
      .then((result) async {
    int code = await sendVerificationCode(email);
    usersDBref.child(uniKey == 0 ? 'UofT' : 'YorkU').child(result.user.uid).set(
        {"email": email, "name": name, "verification": code}).then((res) async {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VerificationPage(
                code: code,
                uid: result.user.uid,
                email: email,
                password: password)),
      );
    });
  }).catchError((err) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(err.toString()),
            actions: [
              FlatButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  });
}

Future<PostUser> getUser(String id) async {
  var uniKey = Constants.checkUniversity();
  var userDB = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uniKey == 0 ? 'UofT' : 'YorkU')
      .child(id);
  var snapshot = await userDB.once();
  Map<dynamic, dynamic> value = snapshot.value;
  return PostUser(
      id: id,
      name: value['name'],
      email: value['email'],
      verified: value['verification']);
}

Future<List<PostUser>> allUsers() async {
  var userDB = FirebaseDatabase.instance.reference().child('users');
  var snapshot = await userDB.once();
  List<PostUser> p = [];
  Map<dynamic, dynamic> values = snapshot.value;

  values.remove(firebaseAuth.currentUser.uid);

  for (var key in values.keys) {
    var value = values[key];
    // var user = PostUser(id: '', name: value['name'], email: value['email']);
    PostUser user =
        PostUser(id: key, name: value['name'], email: value['email']);
    p.add(user);
  }

  return p;
}

Future<List<PostUser>> myCampusUsers() async {
  var uniKey = Constants.checkUniversity();
  var userDB = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uniKey == 0 ? 'UofT' : 'YorkU');
  var snapshot = await userDB.once();
  List<PostUser> p = [];
  Map<dynamic, dynamic> values = snapshot.value;

  values.remove(firebaseAuth.currentUser.uid);

  for (var key in values.keys) {
    var value = values[key];
    // var user = PostUser(id: '', name: value['name'], email: value['email']);
    PostUser user =
        PostUser(id: key, name: value['name'], email: value['email']);
    p.add(user);
  }

  return p;
}

Future<int> sendVerificationCode(String email) async {
  String username = Constants.username;
  String password = Constants.password;
  var code = verificationCode();
  final smtpServer = gmail(username, password);
  final message = Message()
    ..from = Address(username, 'NOREPLYUNIFYAPP')
    ..recipients.add(email)
    ..subject = 'Verification Code'
    ..text = 'Your Verification Code is: $code';
  // ..html = "<h1>Test</h1>\n<p>Hey! Here's some HTML content</p>";

  try {
    await send(message, smtpServer);
    return code;
  } on MailerException catch (e) {
    return 0;
  }
}

Future<bool> updateVerification(String uid) async {
  var uniKey = Constants.checkUniversity();
  var db = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uniKey == 0 ? 'UofT' : 'YorkU')
      .child(uid);
  Map<String, dynamic> value = {"verification": "verified"};
  await db.update(value);
  return true;
}

int verificationCode() {
  var rnd = new Random();
  var next = rnd.nextDouble() * 10000;
  while (next < 1000) {
    next *= 10;
  }
  return next.toInt();
}
