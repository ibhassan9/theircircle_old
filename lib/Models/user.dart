import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Home/main_screen.dart';
import 'package:unify/Models/assignment.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/match.dart';
import 'package:unify/pages/DB.dart';
import 'package:unify/Models/course.dart';
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
  String deviceToken;
  bool appear;
  int status; // 1 = banned
  String snapchatHandle;
  String linkedinHandle;
  String instagramHandle;
  bool isBlocked;
  String university;
  String about;
  String why;
  List<dynamic> interests;
  List<dynamic> accomplishments;
  int createdAt;
  int points;

  //                               fetchUserNetworkProfile(widget.user.id, widget.user.university)
  //     .then((value) {
  //   var _accomplishments = value[0];
  //   var _interests = value[2];
  //   var _why = value[1];
  //   var _about = value[3];
  // });

  PostUser(
      {this.id,
      this.email,
      this.name,
      this.verified,
      this.courseCount,
      this.clubCount,
      this.bio,
      this.profileImgUrl,
      this.deviceToken,
      this.appear,
      this.status,
      this.snapchatHandle,
      this.linkedinHandle,
      this.instagramHandle,
      this.isBlocked,
      this.university,
      this.about,
      this.why,
      this.interests,
      this.accomplishments,
      this.createdAt,
      this.points});
}

Future signInUser(
    {String email,
    String password,
    BuildContext context,
    Function onError}) async {
  await FIR_AUTH.signOut();
  await FIR_AUTH
      .signInWithEmailAndPassword(email: email, password: password)
      .then((result) async {
    print('5');
    var uni = Constants.checkUniversity();
    uniKey = uni;
    FIR_UID = FirebaseAuth.instance.currentUser.uid;
    FIR_AUTH = FirebaseAuth.instance;
    PostUser _user = await getUser(result.user.uid);
    if (_user.status == 1) {
      final snackBar = SnackBar(
          backgroundColor: Colors.pink,
          content: Text(
            'This account is temporarily banned.',
            style: GoogleFonts.quicksand(
                fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
          ));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    await _firebaseMessaging.setAutoInitEnabled(true);
    await _firebaseMessaging.deleteToken();
    var token = await _firebaseMessaging.getToken();
    var db = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(Constants.uniString(uniKey))
        .child(FIR_UID)
        .child('device_token')
        .set(token);
    await db;
    if (_user.verified == 0 && FIR_AUTH.currentUser.emailVerified != true) {
      await sendVerificationEmail(FIR_AUTH.currentUser);
      FIR_AUTH.signOut().then((value) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove('uni');
        prefs.remove('name');
        prefs.remove('filters');
      });
      // var code = await sendVerificationCode(email);
      // if (code == 0) {
      //   return;
      // }
      onError();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VerificationPage(
                  email: email, password: password, uid: result.user.uid)));
    } else {
      if (FIR_AUTH.currentUser.emailVerified || _user.verified == 1) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('uni', uni);
        prefs.setString('name', _user.name);
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainScreen()));
      } else {
        await sendVerificationEmail(FIR_AUTH.currentUser);
        // var code = await sendVerificationCode(email);
        // if (code == 0) {
        //   return;
        // }
        FIR_AUTH.signOut().then((value) async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.remove('uni');
          prefs.remove('name');
          prefs.remove('filters');
        });

        onError();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VerificationPage(
                    email: email, password: password, uid: result.user.uid)));
      }
    }
  }).catchError((err) {
    var errList = err.toString().split(' ');
    errList.removeAt(0);
    var errString = errList.join(' ');
    final snackBar = SnackBar(
        backgroundColor: Colors.pink,
        content: Text(
          errString,
          style: GoogleFonts.quicksand(
              fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
        ));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    onError();
  });
}

Future<Null> updateUserToken() async {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  ;
  var token = await _firebaseMessaging.getToken();
  var db = USERS_DB
      .child(Constants.uniString(uniKey))
      .child(FIR_UID)
      .child('device_token');
  db.set(token);
}

Future registerUser(
    {String name,
    String email,
    String password,
    BuildContext context,
    Function onError}) async {
  if (email.contains(new RegExp(r'yorku', caseSensitive: false)) == false &&
      email.contains(new RegExp(r'utoronto', caseSensitive: false)) == false &&
      email.contains(new RegExp(r'uwo', caseSensitive: false)) == false) {
    final snackBar = SnackBar(
        backgroundColor: Colors.pink,
        content: Text(
          'Please use your university email to sign up.',
          style: GoogleFonts.quicksand(
              fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
        ));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    return;
  }
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  var uniKey = checkUniversityWithEmail(email);
  if (uniKey == null) {
    return;
  }
  var token = await _firebaseMessaging.getToken();
  await FIR_AUTH
      .createUserWithEmailAndPassword(email: email, password: password)
      .then((result) async {
    int code = 0;
    print(uniKey);
    USERS_DB.child(Constants.uniString(uniKey)).child(result.user.uid).set({
      "email": email,
      "name": name,
      "verification": code,
      "device_token": token,
      "appear": true,
      "createdAt": result.user.metadata.creationTime.millisecondsSinceEpoch
    }).then((res) async {
      await sendVerificationEmail(result.user);
      FIR_AUTH.signOut();
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => VerificationPage(
                uid: result.user.uid, email: email, password: password)),
      );
    });
  }).catchError((err) {
    var errList = err.toString().split(' ');
    errList.removeAt(0);
    var errString = errList.join(' ');
    final snackBar = SnackBar(
        backgroundColor: Colors.pink,
        content: Text(
          errString,
          style: GoogleFonts.quicksand(
              fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
        ));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    onError();
  });
}

Future<Null> sendVerificationEmail(User user) async {
  await user.sendEmailVerification().then((value) {
    print("We've sent a verification email to ${user.email}");
  }).onError((error, stackTrace) {
    print("Error sending verification code");
  });
}

Future<PostUser> getUserWithUniversity(String id, String uni) async {
  var userDB = USERS_DB.child(uni).child(id);
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
      deviceToken: value['device_token'],
      appear: value['appear'],
      status: value['status'] != null ? value['status'] : 0,
      snapchatHandle:
          value['snapchatHandle'] != null ? value['snapchatHandle'] : "",
      instagramHandle:
          value['instagramHandle'] != null ? value['instagramHandle'] : "",
      linkedinHandle:
          value['linkedinHandle'] != null ? value['linkedinHandle'] : "",
      isBlocked: blocks.containsKey(id),
      university: uni);

  if (value['accomplishments'] != null) {
    user.accomplishments = value['accomplishments'];
  }

  if (value['createdAt'] != null) {
    user.createdAt = value['createdAt'];
  }

  if (value['why'] != null) {
    user.why = value['why'];
  }

  if (value['interests'] != null) {
    user.interests = value['interests'];
  }

  if (value['about'] != null) {
    user.about = value['about'];
  }

  if (value['points'] != null) {
    user.points = value['points'];
  }

  return user;
}

Future<PostUser> getUser(String id) async {
  var userDB = USERS_DB.child(Constants.uniString(uniKey)).child(id);
  var university = Constants.uniString(uniKey);
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
      deviceToken: value['device_token'],
      appear: value['appear'],
      status: value['status'] != null ? value['status'] : 0,
      snapchatHandle:
          value['snapchatHandle'] != null ? value['snapchatHandle'] : "",
      instagramHandle:
          value['instagramHandle'] != null ? value['instagramHandle'] : "",
      linkedinHandle:
          value['linkedinHandle'] != null ? value['linkedinHandle'] : "",
      isBlocked: blocks.containsKey(id),
      university: university);

  if (value['accomplishments'] != null) {
    user.accomplishments = value['accomplishments'];
  }

  if (value['createdAt'] != null) {
    user.createdAt = value['createdAt'];
  }

  if (value['why'] != null) {
    user.why = value['why'];
  }

  if (value['interests'] != null) {
    user.interests = value['interests'];
  }

  if (value['about'] != null) {
    user.about = value['about'];
  }

  if (value['points'] != null) {
    user.points = value['points'];
  }

  return user;
}

Future<List<PostUser>> allUsers() async {
  var snapshot = await USERS_DB.once();
  List<PostUser> p = [];
  Map<dynamic, dynamic> values = snapshot.value;

  values.remove(FIR_UID);

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
        deviceToken: value['device_token'],
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

Future<List<PostUser>> allStudents() async {
  List<String> universities = ['UofT', 'YorkU', 'WesternU'];
  List<PostUser> p = [];
  var university = universities[uniKey];
  var userDB = USERS_DB.child(university);
  var snapshot = await userDB.once();
  Map<dynamic, dynamic> values = snapshot.value;

  values.remove(FIR_UID);

  for (var key in values.keys) {
    PostUser user = await getUserWithUniversity(key, university);
    p.add(user);
  }
  p.shuffle();
  return p;
}

Future<List<PostUser>> peopleList() async {
  var userDB = USERS_DB.child(Constants.uniString(uniKey));
  var snapshot = await userDB.once();
  List<PostUser> p = [];
  Map<dynamic, dynamic> values = snapshot.value;
  var blocks = await getBlocks();
  var mylikes = await fetchMyLikes();

  values.remove(FIR_UID);

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
          deviceToken: value['device_token'],
          appear: value['appear'],
          status: value['status'] != null ? value['status'] : 0,
          snapchatHandle:
              value['snapchatHandle'] != null ? value['snapchatHandle'] : "",
          instagramHandle:
              value['instagramHandle'] != null ? value['instagramHandle'] : "",
          linkedinHandle:
              value['linkedinHandle'] != null ? value['linkedinHandle'] : "",
          isBlocked: blocks.containsKey(key));
      if (mylikes != null) {
        if (mylikes.contains(user.id) == false) {
          p.add(user);
        }
      }
    }
  }
  p.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return p;
}

Future<Map<String, List<Assignment>>> fetchAllMyAssignments(
    DateTime date) async {
  Map<String, List<Assignment>> assignments = {};
  List<Course> myCourses = [];
  List<Club> myClubs = [];
  // Fetch courses i'm in
  List<Course> courses = await fetchCourses();
  // Fetch clubs i'm in
  List<Club> clubs = await fetchClubs();

  if (courses != null || courses.isNotEmpty) {
    for (var course in courses) {
      if (course.inCourse) {
        myCourses.add(course);
      }
    }
  }

  if (clubs != null || clubs.isNotEmpty) {
    for (var club in clubs) {
      if (club.inClub) {
        myClubs.add(club);
      }
    }
  }

  if (myCourses != null || myCourses.isNotEmpty) {
    for (var course in myCourses) {
      List<Assignment> assignment = await fetchAssignments(date, course);
      assignments[course.name] = assignment;
    }
  }

  if (myClubs != null || myClubs.isNotEmpty) {
    for (var club in myClubs) {
      List<Assignment> reminder = await fetchEventReminders(date, club);
      assignments[club.name] = reminder;
    }
  }

  return assignments;
}

Future<List<PostUser>> myCampusUsers() async {
  var userDB = USERS_DB.child(Constants.uniString(uniKey));
  var university = Constants.uniString(uniKey);
  var snapshot = await userDB.once();
  List<PostUser> p = [];
  Map<dynamic, dynamic> values = snapshot.value;
  var blocks = await getBlocks();

  values.remove(FIR_UID);

  for (var key in values.keys) {
    var value = values[key];
    if (value['appear'] == true) {
      var user = PostUser(
          id: key,
          name: value['name'],
          email: value['email'],
          verified: value['verification'],
          courseCount: value['courses'] != null ? value['courses'].length : 0,
          clubCount: value['clubs'] != null ? value['clubs'].length : 0,
          bio: value['bio'] != null ? value['bio'] : "",
          profileImgUrl: value['profileImgUrl'],
          deviceToken: value['device_token'],
          appear: value['appear'],
          status: value['status'] != null ? value['status'] : 0,
          snapchatHandle:
              value['snapchatHandle'] != null ? value['snapchatHandle'] : "",
          instagramHandle:
              value['instagramHandle'] != null ? value['instagramHandle'] : "",
          linkedinHandle:
              value['linkedinHandle'] != null ? value['linkedinHandle'] : "",
          isBlocked: blocks.containsKey(key),
          university: university);

      if (value['accomplishments'] != null) {
        user.accomplishments = value['accomplishments'];
      }

      if (value['why'] != null) {
        user.why = value['why'];
      }

      if (value['createdAt'] != null) {
        user.createdAt = value['createdAt'];
      }

      if (value['interests'] != null) {
        user.interests = value['interests'];
      }

      if (value['about'] != null) {
        user.about = value['about'];
      }
      p.add(user);
    }
  }
  return p;
}

Future<bool> changeAppear(bool appear) async {
  var userDB = USERS_DB
      .child(Constants.uniString(uniKey))
      .child(FIR_UID)
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
    ..from = Address(username, 'NOREPLYTHEIRCIRCLEAPP')
    ..recipients.add(email)
    ..subject = 'Verification Code'
    ..text = 'Your Verification Code is: $code';
  // ..html = "<h1>Test</h1>\n<p>Hey! Here's some HTML content</p>";
  //

  print(code);

  try {
    await send(message, smtpServer);
    return code;
  } on MailerException catch (e) {
    print(e.message);
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
  var db = USERS_DB.child(Constants.uniString(uniKey)).child(uid);
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
  String urlString;
  try {
    final DateTime now = DateTime.now();
    final int millSeconds = now.millisecondsSinceEpoch;
    final String month = now.month.toString();
    final String date = now.day.toString();
    final String storageId = (millSeconds.toString());
    final String today = ('$month-$date');

    FirebaseStorage storage = FirebaseStorage.instance;

    Reference ref = storage.ref().child('files').child(today).child(storageId);
    UploadTask uploadTask = ref.putFile(file);
    await uploadTask.then((res) async {
      await res.ref.getDownloadURL().then((value) {
        urlString = value;
      });
    });

    return urlString;
  } catch (error) {
    return "error";
  }
}

Future<Map<String, String>> getBlocks() async {
  var db = USERS_DB
      .child(Constants.uniString(uniKey))
      .child(FIR_UID)
      .child('blocks');
  var snapshot = await db.once();

  Map<String, String> blockList = {};

  if (snapshot.value != null) {
    Map<dynamic, dynamic> values = snapshot.value;

    for (var key in values.keys) {
      blockList[key] = values[key];
    }
  }

  return blockList;
}

Future<bool> block(String userId, String university) async {
  var db = USERS_DB
      .child(Constants.uniString(uniKey))
      .child(FIR_UID)
      .child('blocks')
      .child(userId);
  var uni = university == "University of Toronto"
      ? "UofT"
      : university == "York University"
          ? "YorkU"
          : "WesternU";
  await db.set(uni).catchError((onError) {
    return false;
  });
  return true;
}

Future<bool> unblock(String userId) async {
  var db = USERS_DB
      .child(Constants.uniString(uniKey))
      .child(FIR_UID)
      .child('blocks')
      .child(userId);
  await db.remove().catchError((err) {
    return false;
  });
  return true;
}

Future<List> getImageString() async {
  var url;
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

    FirebaseStorage storage = FirebaseStorage.instance;

    Reference ref = storage.ref().child('files').child(today).child(storageId);
    UploadTask uploadTask = ref.putFile(File(f.path));
    await uploadTask.then((res) async {
      await res.ref.getDownloadURL().then((value) {
        url = value;
      });
    });

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

Future<bool> updateProfile(
    String url,
    String bio,
    String snap,
    String linkedin,
    String instagram,
    String about,
    String accomplishment1,
    String accomplishment2,
    String accomplishment3,
    String why,
    List<String> interests) async {
  var shareddb = USERS_DB.child(Constants.uniString(uniKey)).child(FIR_UID);
  var accomplishments = [accomplishment1, accomplishment2, accomplishment3];
  var accomplishmentsdb = shareddb.child('accomplishments');
  var aboutdb = shareddb.child('about');
  var whydb = shareddb.child('why');
  var interestsdb = shareddb.child('interests');
  var biodb = shareddb.child('bio');
  var snapdb = shareddb.child('snapchatHandle');
  var igdb = shareddb.child('instagramHandle');
  var linkedindb = shareddb.child('linkedinHandle');
  await biodb.set(bio);
  await igdb.set(instagram);
  await snapdb.set(snap);
  await linkedindb.set(linkedin);
  await accomplishmentsdb.set(accomplishments);
  await aboutdb.set(about);
  await whydb.set(why);
  await interestsdb.set(interests);

  if (url == null) {
    return true;
  } else {
    var db = shareddb.child('profileImgUrl');
    await db.set(url);
    return true;
  }
}

Future<bool> updateNetworkProfile(
    String about,
    String accomplishment1,
    String accomplishment2,
    String accomplishment3,
    String why,
    List<String> interests) async {
  var userDB = USERS_DB.child(Constants.uniString(uniKey)).child(FIR_UID);

  Map<dynamic, dynamic> values = {
    'about': about,
    'accomplishments': [accomplishment1, accomplishment2, accomplishment3],
    'why': why,
    'interests': interests
  };
  await userDB.child('networking').set(values).catchError((onError) {
    return false;
  });
  return true;
}

Future<List<dynamic>> fetchNetworkProfile() async {
  List<dynamic> items = [];
  var userDB = USERS_DB
      .child(Constants.uniString(uniKey))
      .child(FIR_UID)
      .child('networking');

  DataSnapshot snapshot = await userDB.once();

  if (snapshot.value != null) {
    Map<dynamic, dynamic> values = snapshot.value;

    var accomplishments = values['accomplishments'];
    var why = values['why'];
    var interests = values['interests'];
    var about = values['about'];
    items = [accomplishments, why, interests, about];
  }

  return items;
}

Future<List<dynamic>> fetchUserNetworkProfile(
    String userId, String university) async {
  List<dynamic> items = [];
  var userDB = USERS_DB.child(university).child(userId).child('networking');
  DataSnapshot snapshot = await userDB.once();

  if (snapshot.value != null) {
    Map<dynamic, dynamic> values = snapshot.value;

    var accomplishments = values['accomplishments'] ?? [];
    var why = values['why'] ?? "";
    var interests = values['interests'] ?? [];
    var about = values['about'] ?? "";
    items = [accomplishments, why, interests, about];
  }

  return items;
}

Future<bool> addPoints({int addedPoints}) async {
  var db = USERS_DB
      .child(Constants.uniString(uniKey))
      .child(FIR_UID)
      .child('points');
  DataSnapshot snap = await db.once();
  int points = snap.value;
  await db.set(points + addedPoints).then((value) {
    return true;
  }).catchError((e) {
    return false;
  });
  return true;
}

Future<int> checkPoints() async {
  var db = USERS_DB
      .child(Constants.uniString(uniKey))
      .child(FIR_UID)
      .child('points');
  DataSnapshot snap = await db.once();
  int points = snap.value;
  return points;
}
