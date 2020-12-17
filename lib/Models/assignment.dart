import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/Models/user.dart';

class Assignment {
  String id;
  String title;
  String description;
  String createdBy;
  String timeDue;
  String userId;
  bool isMine;
  int timeStamp;

  Assignment(
      {this.id,
      this.title,
      this.description,
      this.createdBy,
      this.timeDue,
      this.userId,
      this.isMine,
      this.timeStamp});
}

FirebaseAuth firebaseAuth = FirebaseAuth.instance;

Future<List<Assignment>> fetchAssignments(DateTime _date, Course course) async {
  String date = DateFormat('yyyy-MM-dd').format(_date);
  var uniKey = Constants.checkUniversity();
  List<Assignment> a = List<Assignment>();
  var db = FirebaseDatabase.instance
      .reference()
      .child("assignments")
      .child(uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU')
      .child(course.id)
      .child(date);

  var snapshot = await db.once();

  Map<dynamic, dynamic> values = snapshot.value;

  if (snapshot.value != null) {
    values.forEach((key, value) {
      var assignment = Assignment(
          id: key,
          title: value['title'],
          description: value['description'],
          createdBy: value['createdBy'],
          timeDue: value['timeDue'],
          timeStamp: value['timeStamp'],
          userId: value['userId']);
      a.add(assignment);
    });
    a.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
  }
  return a;
}

Future<List<Assignment>> fetchEventReminders(DateTime _date, Club club) async {
  String date = DateFormat('yyyy-MM-dd').format(_date);
  var uniKey = Constants.checkUniversity();
  List<Assignment> a = List<Assignment>();
  var db = FirebaseDatabase.instance
      .reference()
      .child("eventreminders")
      .child(uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU')
      .child(club.id)
      .child(date);

  var snapshot = await db.once();

  Map<dynamic, dynamic> values = snapshot.value;

  if (snapshot.value != null) {
    values.forEach((key, value) {
      var assignment = Assignment(
          id: key,
          title: value['title'],
          description: value['description'],
          createdBy: value['createdBy'],
          timeDue: value['timeDue'],
          timeStamp: value['timeStamp'],
          userId: value['userId']);
      a.add(assignment);
    });
    a.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
  }

  return a;
}

Future<bool> createAssignment(
    Assignment assignment, Course course, String date) async {
  PostUser user = await getUser(firebaseAuth.currentUser.uid);
  var uniKey = Constants.checkUniversity();
  var key = FirebaseDatabase.instance
      .reference()
      .child('assignments')
      .child(uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU')
      .child(course.id)
      .child(date)
      .push();
  final Map<String, dynamic> data = {
    "title": assignment.title,
    "description": assignment.description,
    "createdBy": user.name,
    "timeDue": assignment.timeDue,
    "userId": firebaseAuth.currentUser.uid,
    "timeStamp": DateTime.now().millisecondsSinceEpoch
  };

  await key.set(data);
  DataSnapshot ds = await key.once();
  if (ds.value != null) {
    return true;
  } else {
    return false;
  }
}

Future<bool> deleteAssignment(
    Club club, Course course, Assignment a, String dateTime) async {
  var uniKey = Constants.checkUniversity();
  var assignmentDB = FirebaseDatabase.instance
      .reference()
      .child(course != null ? 'assignments' : 'eventreminders')
      .child(uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU')
      .child(course != null ? course.id : club.id)
      .child(dateTime)
      .child(a.id);
  await assignmentDB.remove().catchError((err) {
    return false;
  });
  return true;
}

Future<bool> createEventReminder(
    Assignment assignment, Club club, String date) async {
  PostUser user = await getUser(firebaseAuth.currentUser.uid);
  var uniKey = Constants.checkUniversity();
  var key = FirebaseDatabase.instance
      .reference()
      .child('assignments')
      .child(uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU')
      .child(club.id)
      .child(date)
      .push();
  final Map<String, dynamic> data = {
    "title": assignment.title,
    "description": assignment.description,
    "createdBy": user.name,
    "timeDue": assignment.timeDue,
    "userId": firebaseAuth.currentUser.uid,
    "timeStamp": DateTime.now().millisecondsSinceEpoch
  };

  await key.set(data);
  DataSnapshot ds = await key.once();
  if (ds.value != null) {
    return true;
  } else {
    return false;
  }
}
