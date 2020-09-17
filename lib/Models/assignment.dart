import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/Models/user.dart';

class Assignment {
  String title;
  String description;
  String createdBy;
  String timeDue;
  String userId;
  bool isMine;
  int timeStamp;

  Assignment(
      {this.title,
      this.description,
      this.createdBy,
      this.timeDue,
      this.userId,
      this.isMine,
      this.timeStamp});
}

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
var assignmentDBrefUofT =
    FirebaseDatabase.instance.reference().child('assignments').child('UofT');
var assignmentDBrefYork =
    FirebaseDatabase.instance.reference().child('assignments').child('YorkU');

int checkUniversity() {
  var userEmail = firebaseAuth.currentUser.email;
  if (userEmail.contains('utoronto')) {
    return 0;
  } else {
    return 1;
  }
}

Future<List<Assignment>> fetchAssignments(DateTime _date, Course course) async {
  String date = DateFormat('yyyy-MM-dd').format(_date);
  var uniKey = checkUniversity();
  List<Assignment> a = List<Assignment>();
  var db = uniKey == 0
      ? FirebaseDatabase.instance
          .reference()
          .child("assignments")
          .child('UofT')
          .child(course.code)
          .child(date)
      : FirebaseDatabase.instance
          .reference()
          .child("assignments")
          .child('YorkU')
          .child(course.code)
          .child(date);

  var snapshot = await db.once();

  Map<dynamic, dynamic> values = snapshot.value;

  values.forEach((key, value) {
    var assignment = Assignment(
        title: value['title'],
        description: value['description'],
        createdBy: value['createdBy'],
        timeDue: value['timeDue'],
        timeStamp: value['timeStamp'],
        userId: value['userId']);
    a.add(assignment);
  });
  a.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
  return a;
}

Future<bool> createAssignment(
    Assignment assignment, Course course, String date) async {
  PostUser user = await getUser(firebaseAuth.currentUser.uid);
  var uniKey = checkUniversity();
  if (uniKey == 0) {
    var key = assignmentDBrefUofT.child(course.code).child(date).push();
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
  } else {
    var key = assignmentDBrefYork.child(course.code).child(date).push();
    final Map<String, dynamic> data = {
      "title": assignment.title,
      "description": assignment.description,
      "createdBy": user.name,
      "timeDue": assignment.timeDue,
      "userId": firebaseAuth.currentUser.uid,
      "timeStamp": DateTime.now().millisecondsSinceEpoch
    };

    //TODO:- Fix Push Random Key

    await key.set(data);
    DataSnapshot ds = await key.once();
    if (ds.value != null) {
      return true;
    } else {
      return false;
    }
  }
}
