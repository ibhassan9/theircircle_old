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
import 'package:unify/pages/MainPage.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/pages/VerificationPage.dart';

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
  String snapchatHandle;
  String linkedinHandle;
  String instagramHandle;
  bool isBlocked;

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
      this.status,
      this.snapchatHandle,
      this.linkedinHandle,
      this.instagramHandle,
      this.isBlocked});
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
        print("error code");
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
    print(err.toString());
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
  var blocks = await getBlocks();
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
      status: value['status'] != null ? value['status'] : 0,
      snapchatHandle:
          value['snapchatHandle'] != null ? value['snapchatHandle'] : "",
      instagramHandle:
          value['instagramHandle'] != null ? value['instagramHandle'] : "",
      linkedinHandle:
          value['linkedinHandle'] != null ? value['linkedinHandle'] : "",
      isBlocked: blocks.contains(id));
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
    PostUser user = PostUser(
        id: key,
        name: value['name'],
        email: value['email'],
        verified: value['verification'],
        courseCount: value['courses'] != null ? value['courses'].length : 0,
        clubCount: value['clubs'] != null ? value['clubs'].length : 0,
        bio: value['bio'] != null ? value['bio'] : "",
        profileImgUrl: value['profileImgUrl'],
        device_token: value['device_token'],
        appear: value['appear'],
        status: value['status'] != null ? value['status'] : 0,
        snapchatHandle:
            value['snapchatHandle'] != null ? value['snapchatHandle'] : "",
        instagramHandle:
            value['instagramHandle'] != null ? value['instagramHandle'] : "",
        linkedinHandle:
            value['linkedinHandle'] != null ? value['linkedinHandle'] : "");
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
  var blocks = await getBlocks();

  values.remove(firebaseAuth.currentUser.uid);

  for (var key in values.keys) {
    var value = values[key];
    if (value['appear'] == true) {
      PostUser user = PostUser(
          id: key,
          name: value['name'],
          email: value['email'],
          verified: value['verification'],
          courseCount: value['courses'] != null ? value['courses'].length : 0,
          clubCount: value['clubs'] != null ? value['clubs'].length : 0,
          bio: value['bio'] != null ? value['bio'] : "",
          profileImgUrl: value['profileImgUrl'],
          device_token: value['device_token'],
          appear: value['appear'],
          status: value['status'] != null ? value['status'] : 0,
          snapchatHandle:
              value['snapchatHandle'] != null ? value['snapchatHandle'] : "",
          instagramHandle:
              value['instagramHandle'] != null ? value['instagramHandle'] : "",
          linkedinHandle:
              value['linkedinHandle'] != null ? value['linkedinHandle'] : "",
          isBlocked: blocks.contains(key));
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

Future<bool> sendReportEmail(String text) async {
  String username = Constants.username;
  String password = Constants.password;
  final smtpServer = gmail(username, password);
  final message = Message()
    ..from = Address(username, 'NOREPLYTHEIRCIRCLE')
    ..recipients.add(Constants.username)
    ..subject = 'TheirCircle issue/complaint'
    ..text = text;

  try {
    await send(message, smtpServer);
    return true;
  } on MailerException catch (e) {
    return false;
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

Future<List<String>> getBlocks() async {
  var uniKey = Constants.checkUniversity();
  var uid = firebaseAuth.currentUser.uid;
  var db = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uniKey == 0 ? 'UofT' : 'YorkU')
      .child(uid)
      .child('blocks');
  var snapshot = await db.once();

  List<String> blockList = [];

  if (snapshot.value != null) {
    Map<dynamic, dynamic> values = snapshot.value;

    for (var key in values.keys) {
      blockList.add(key);
    }
  }

  return blockList;
}

Future<bool> block(String userId) async {
  var uniKey = Constants.checkUniversity();
  var uid = firebaseAuth.currentUser.uid;
  var db = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uniKey == 0 ? 'UofT' : 'YorkU')
      .child(uid)
      .child('blocks')
      .child(userId);
  await db.set(userId).catchError((onError) {
    return false;
  });
  return true;
}

Future<bool> unblock(String userId) async {
  var uniKey = Constants.checkUniversity();
  var uid = firebaseAuth.currentUser.uid;
  var db = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uniKey == 0 ? 'UofT' : 'YorkU')
      .child(uid)
      .child('blocks')
      .child(userId);
  await db.remove().catchError((err) {
    return false;
  });
  return true;
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

Future<bool> updateProfile(String url, String bio, String snap, String linkedin,
    String instagram) async {
  var uid = firebaseAuth.currentUser.uid;
  var uniKey = Constants.checkUniversity();
  if (url == null) {
    var biodb = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(uniKey == 0 ? 'UofT' : 'YorkU')
        .child(uid)
        .child('bio');
    var snapdb = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(uniKey == 0 ? 'UofT' : 'YorkU')
        .child(uid)
        .child('snapchatHandle');
    var igdb = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(uniKey == 0 ? 'UofT' : 'YorkU')
        .child(uid)
        .child('instagramHandle');
    var linkedindb = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(uniKey == 0 ? 'UofT' : 'YorkU')
        .child(uid)
        .child('linkedinHandle');
    await biodb.set(bio);
    await igdb.set(instagram);
    await snapdb.set(snap);
    await linkedindb.set(linkedin);
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
    var snapdb = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(uniKey == 0 ? 'UofT' : 'YorkU')
        .child(uid)
        .child('snapchatHandle');
    var igdb = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(uniKey == 0 ? 'UofT' : 'YorkU')
        .child(uid)
        .child('instagramHandle');
    var linkedindb = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(uniKey == 0 ? 'UofT' : 'YorkU')
        .child(uid)
        .child('linkedinHandle');
    await db.set(url);
    await biodb.set(bio);
    await igdb.set(instagram);
    await snapdb.set(snap);
    await linkedindb.set(linkedin);
    return true;
  }
}

showProfile(
    PostUser me,
    BuildContext context,
    TextEditingController bioController,
    TextEditingController snapchatController,
    TextEditingController instagramController,
    TextEditingController linkedinController) async {
  var user = await getUser(firebaseAuth.currentUser.uid);
  bool object_avail = true;
  Image imag;
  File f;
  AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.NO_HEADER,
      body: StatefulBuilder(builder: (context, setState) {
        return object_avail
            ? Stack(
                children: [
                  ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: AlwaysScrollableScrollPhysics(),
                    children: [
                      me.profileImgUrl == null
                          ? me.id == firebaseAuth.currentUser.uid
                              ? imag != null
                                  ? CircleAvatar(child: imag, radius: 50.0)
                                  : CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      radius: 50.0,
                                      child: InkWell(
                                          onTap: () async {
                                            // var res = await u.getImage();
                                            // if (res.isNotEmpty) {
                                            //   var image = res[0] as Image;
                                            //   var file = res[1] as File;
                                            //   setState(() {
                                            //     imag = image;
                                            //     f = file;
                                            //   });
                                            // }
                                          },
                                          child: Icon(FlutterIcons.user_ant,
                                              color: Colors.white)))
                              : CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  radius: 50.0,
                                  child: Icon(FlutterIcons.user_ant,
                                      color: Colors.white))
                          : Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.network(
                                  me.profileImgUrl,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
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
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes
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
                        me.name == null ? "" : me.name,
                        style: GoogleFonts.quicksand(
                          textStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                      )),
                      SizedBox(height: 5.0),
                      Center(
                          child: me.id == firebaseAuth.currentUser.uid
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10.0),
                                  child: TextField(
                                    controller: bioController,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        hintText:
                                            me.bio == null || me.bio.isEmpty
                                                ? Constants.dummyDescription
                                                : me.bio,
                                        hintStyle: GoogleFonts.quicksand(
                                          textStyle: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade700),
                                        )),
                                    maxLines: null,
                                    style: GoogleFonts.quicksand(
                                      textStyle: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade700),
                                    ),
                                  ),
                                )
                              : Text(
                                  me.bio == null ? "" : me.bio,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.quicksand(
                                    textStyle: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black),
                                  ),
                                )),
                      Center(
                          child: me.id == firebaseAuth.currentUser.uid
                              ? Container()
                              : InkWell(
                                  onTap: () async {
                                    if (me.isBlocked) {
                                      var res = await unblock(me.id);
                                      if (res) {
                                        setState(() {
                                          me.isBlocked = false;
                                        });
                                      }
                                    } else {
                                      var res = await block(me.id);
                                      if (res) {
                                        setState(() {
                                          me.isBlocked = true;
                                        });
                                      }
                                    }
                                  },
                                  child: Text(
                                      me.isBlocked
                                          ? 'Unblock this user'
                                          : 'Block this user',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.quicksand(
                                        textStyle: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blue),
                                      )),
                                )),
                      SizedBox(height: 5.0),
                      Visibility(
                        visible: user.id == me.id,
                        child: InkWell(
                          onTap: () async {
                            var appear = user.appear ? false : true;
                            var res = await changeAppear(appear);
                            if (res) {
                              setState(() {
                                user.appear = appear;
                              });
                            }
                          },
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                    user.appear == false
                                        ? FlutterIcons.eye_ant
                                        : FlutterIcons.eye_off_fea,
                                    color: Colors.blue,
                                    size: 20.0),
                                SizedBox(width: 5.0),
                                Text(
                                    user.appear
                                        ? "Hide from 'Students on Unify'"
                                        : "Appear on 'Students on Unify'",
                                    style: GoogleFonts.quicksand(
                                        textStyle: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blue)))
                              ]),
                        ),
                      ),
                      Divider(),
                      SizedBox(height: 10.0),
                      Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10.0),
                            child: TextField(
                              enabled: me.id == firebaseAuth.currentUser.uid,
                              controller: snapchatController,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(
                                      FlutterIcons.snapchat_ghost_faw,
                                      color: Colors.black),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  hintText: me.snapchatHandle == null ||
                                          me.snapchatHandle.isEmpty
                                      ? me.id == firebaseAuth.currentUser.uid
                                          ? "Insert Snapchat Handle"
                                          : "Snapchat Handle Unavailable"
                                      : me.snapchatHandle,
                                  hintStyle: GoogleFonts.quicksand(
                                    textStyle: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade700),
                                  )),
                              maxLines: null,
                              style: GoogleFonts.quicksand(
                                textStyle: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10.0),
                            child: TextField(
                              enabled: me.id == firebaseAuth.currentUser.uid,
                              controller: instagramController,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(FlutterIcons.instagram_faw,
                                      color: Colors.purple),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  hintText: me.instagramHandle == null ||
                                          me.instagramHandle.isEmpty
                                      ? me.id == firebaseAuth.currentUser.uid
                                          ? "Insert Instagram Handle"
                                          : "Instagram Handle Unavailable"
                                      : me.instagramHandle,
                                  hintStyle: GoogleFonts.quicksand(
                                    textStyle: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade700),
                                  )),
                              maxLines: null,
                              style: GoogleFonts.quicksand(
                                textStyle: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10.0),
                            child: TextField(
                              enabled: me.id == firebaseAuth.currentUser.uid,
                              controller: linkedinController,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(FlutterIcons.linkedin_faw,
                                      color: Colors.blue),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  hintText: me.linkedinHandle == null ||
                                          me.linkedinHandle.isEmpty
                                      ? me.id == firebaseAuth.currentUser.uid
                                          ? "Insert LinkedIn Handle"
                                          : "LinkedIn Handle Unavailable"
                                      : me.linkedinHandle,
                                  hintStyle: GoogleFonts.quicksand(
                                    textStyle: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade700),
                                  )),
                              maxLines: null,
                              style: GoogleFonts.quicksand(
                                textStyle: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700),
                              ),
                            ),
                          )
                        ],
                      ),
                      Visibility(
                        visible: me.id == firebaseAuth.currentUser.uid,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 15.0),
                          child: InkWell(
                            onTap: () async {
                              if (imag == null) {
                                // just update bio
                                var res = await updateProfile(
                                    null,
                                    bioController.text,
                                    snapchatController.text,
                                    linkedinController.text,
                                    instagramController.text);
                                Navigator.pop(context);
                                if (res) {
                                  setState(() {});
                                }
                                bioController.clear();
                                snapchatController.clear();
                                linkedinController.clear();
                                instagramController.clear();
                              } else {
                                // image available, upload image
                                var url = await uploadImageToStorage(f);
                                var res = await updateProfile(
                                    url,
                                    bioController.text,
                                    snapchatController.text,
                                    linkedinController.text,
                                    instagramController.text);
                                Navigator.pop(context);
                                if (res) {
                                  setState(() {});
                                }
                                bioController.clear();
                                snapchatController.clear();
                                linkedinController.clear();
                                instagramController.clear();
                              }
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                  color: Colors.purple,
                                  borderRadius: BorderRadius.circular(5.0)),
                              child: Center(
                                child: Text(
                                  "Update Profile",
                                  style: GoogleFonts.quicksand(
                                    textStyle: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              )
            : Center(
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                ),
              );
      }),
      btnOkColor: Colors.deepOrange,
      btnOk: null)
    ..show();
}
