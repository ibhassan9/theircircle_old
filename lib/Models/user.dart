import 'dart:io';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
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
  int verified;
  int courseCount;
  int clubCount;
  String bio;
  String profileImgUrl;
  String device_token;
  bool appear;
  int status; // 1 = banned

  PostUser(
      {this.id,
      this.email,
      this.name,
      this.verified,
      this.courseCount,
      this.clubCount,
      this.bio,
      this.profileImgUrl,
      this.device_token,
      this.appear,
      this.status});
}

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
DatabaseReference usersDBref =
    FirebaseDatabase.instance.reference().child('users');

Future signInUser(String email, String password, BuildContext context) async {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  await _firebaseMessaging.setAutoInitEnabled(true);
  await _firebaseMessaging.deleteInstanceID();
  var token = await _firebaseMessaging.getToken();
  await firebaseAuth
      .signInWithEmailAndPassword(email: email, password: password)
      .then((result) async {
    var uni = Constants.checkUniversity();
    PostUser _user = await getUser(result.user.uid);
    if (_user.status == 1) {
      final snackBar = SnackBar(
          content: Text('This account is temporarily banned.',
              style: GoogleFonts.quicksand(
                textStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              )));
      Scaffold.of(context).showSnackBar(snackBar);
      return;
    }
    var uid = firebaseAuth.currentUser.uid;
    var uniKey = Constants.checkUniversity();
    var db = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(uniKey == 0 ? 'UofT' : 'YorkU')
        .child(uid)
        .child('device_token')
        .set(token);
    await db;
    if (_user.verified != 1) {
      final snackBar = SnackBar(
          content: Text('Please wait...',
              style: GoogleFonts.quicksand(
                textStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              )));
      Scaffold.of(context).showSnackBar(snackBar);
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
    final snackBar = SnackBar(
        content: Text('Problem logging in. Please try again.',
            style: GoogleFonts.quicksand(
              textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            )));
    Scaffold.of(context).showSnackBar(snackBar);
  });
}

Future registerUser(
    String name, String email, String password, BuildContext context) async {
  if (email.contains(new RegExp(r'yorku', caseSensitive: false)) == false &&
      email.contains(new RegExp(r'utoronto', caseSensitive: false)) == false) {
    final snackBar = SnackBar(
        content: Text('Please use your university email to sign up.',
            style: GoogleFonts.quicksand(
              textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            )));
    Scaffold.of(context).showSnackBar(snackBar);
    return;
  }
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  var uniKey = checkUniversityWithEmail(email);
  var token = await _firebaseMessaging.getToken();
  await firebaseAuth
      .createUserWithEmailAndPassword(email: email, password: password)
      .then((result) async {
    int code = await sendVerificationCode(email);
    usersDBref
        .child(uniKey == 0 ? 'UofT' : 'YorkU')
        .child(result.user.uid)
        .set({
      "email": email,
      "name": name,
      "verification": code,
      "device_token": token,
      "appear": true,
    }).then((res) async {
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
    final snackBar = SnackBar(
        content:
            Text('Problem creating account / email might already be in use.',
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                )));
    Scaffold.of(context).showSnackBar(snackBar);
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
  var user = PostUser(
      id: id,
      name: value['name'],
      email: value['email'],
      verified: value['verification'],
      courseCount: value['courses'] != null ? value['courses'].length : 0,
      clubCount: value['clubs'] != null ? value['clubs'].length : 0,
      bio: value['bio'] != null ? value['bio'] : "",
      profileImgUrl: value['profileImgUrl'],
      device_token: value['device_token'],
      appear: value['appear'],
      status: value['status'] != null ? value['status'] : 0);
  print(user);
  return user;
}

Future<List<PostUser>> allUsers() async {
  var userDB = FirebaseDatabase.instance.reference().child('users');
  var snapshot = await userDB.once();
  List<PostUser> p = [];
  Map<dynamic, dynamic> values = snapshot.value;

  values.remove(firebaseAuth.currentUser.uid);

  for (var key in values.keys) {
    var value = values[key];
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
    if (value['appear'] == true) {
      PostUser user =
          PostUser(id: key, name: value['name'], email: value['email']);
      p.add(user);
    }
  }
  p.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return p;
}

Future<bool> changeAppear(bool appear) async {
  var uniKey = Constants.checkUniversity();
  var userDB = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uniKey == 0 ? 'UofT' : 'YorkU')
      .child(firebaseAuth.currentUser.uid)
      .child('appear');
  userDB.set(appear).catchError((err) {
    return false;
  });
  return true;
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
  Map<String, dynamic> value = {"verification": 1};
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

Future<String> uploadImageToStorage(File file) async {
  try {
    final DateTime now = DateTime.now();
    final int millSeconds = now.millisecondsSinceEpoch;
    final String month = now.month.toString();
    final String date = now.day.toString();
    final String storageId = (millSeconds.toString());
    final String today = ('$month-$date');

    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child("files")
        .child(today)
        .child(storageId);
    StorageUploadTask uploadTask = ref.putFile(file);

    var snapShot = await uploadTask.onComplete;

    var url = await snapShot.ref.getDownloadURL();
    var urlString = url.toString();

    return urlString;
  } catch (error) {
    return "error";
  }
}

Future<List> getImageString() async {
  try {
    final DateTime now = DateTime.now();
    final int millSeconds = now.millisecondsSinceEpoch;
    final String month = now.month.toString();
    final String date = now.day.toString();
    final String storageId = (millSeconds.toString());
    final String today = ('$month-$date');

    final picker = ImagePicker();

    final f = await picker.getImage(source: ImageSource.gallery);
    var image = Image.file(File(f.path));

    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child("files")
        .child(today)
        .child(storageId);
    var file = File(f.path);
    StorageUploadTask uploadTask = ref.putFile(file);

    var snapShot = await uploadTask.onComplete;

    var url = await snapShot.ref.getDownloadURL();

    List lst = [url, image];

    return lst;
  } catch (error) {
    return [];
  }
}

Future<List> getImage() async {
  final picker = ImagePicker();

  final f =
      await picker.getImage(source: ImageSource.gallery, imageQuality: 50);
  var image = Image.file(File(f.path));
  List lst = [image, File(f.path)];
  return lst;
}

Future<bool> updateProfile(String url, String bio) async {
  var uid = firebaseAuth.currentUser.uid;
  var uniKey = Constants.checkUniversity();
  if (url == null) {
    var biodb = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(uniKey == 0 ? 'UofT' : 'YorkU')
        .child(uid)
        .child('bio');
    await biodb.set(bio).catchError((onErr) {
      return false;
    });
    return true;
  } else {
    var db = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(uniKey == 0 ? 'UofT' : 'YorkU')
        .child(uid)
        .child('profileImgUrl');
    var biodb = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(uniKey == 0 ? 'UofT' : 'YorkU')
        .child(uid)
        .child('bio');
    await db.set(url).catchError((err) async {
      await biodb.set(bio).catchError((onErr) {
        return false;
      });
      return false;
    });
    return true;
  }
}

showProfile(PostUser user, BuildContext c) {
  AwesomeDialog(
      context: c,
      animType: AnimType.SCALE,
      dialogType: DialogType.NO_HEADER,
      body: StatefulBuilder(builder: (context, setState) {
        return Stack(
          children: [
            ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                user.profileImgUrl == null
                    ? CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 50.0,
                        child: Icon(FlutterIcons.user_ant, color: Colors.white))
                    : Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(
                            user.profileImgUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) return child;
                              return SizedBox(
                                height: 100,
                                width: 100,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            Colors.grey.shade600),
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                SizedBox(height: 10.0),
                Center(
                    child: Text(
                  user.name == null ? "" : user.name,
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                )),
                SizedBox(height: 5.0),
                Center(
                    child: Text(
                  user.bio == null ? "" : user.bio,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                )),
                SizedBox(height: 5.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                        child: Icon(FlutterIcons.linkedin_faw,
                            color: Colors.blue)),
                    InkWell(
                        child: Icon(FlutterIcons.instagram_faw,
                            color: Colors.purple)),
                    InkWell(
                        child: Icon(FlutterIcons.snapchat_ghost_faw,
                            color: Colors.black)),
                  ],
                ),
                SizedBox(height: 10.0),
              ],
            )
          ],
        );
      }),
      btnOkColor: Colors.deepOrange,
      btnOk: null)
    ..show();
}
