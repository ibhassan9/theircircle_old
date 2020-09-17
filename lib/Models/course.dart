import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unify/Models/user.dart';

class Course {
  String id;
  String code;
  String name;
  int memberCount;
  List<PostUser> memberList;
  int postCount;
  bool inCourse;

  Course(
      {this.id,
      this.code,
      this.name,
      this.memberCount,
      this.memberList,
      this.postCount});
}

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
//var coursesDBrefUofT =
//FirebaseDatabase.instance.reference().child('courses').child('UofT');
//var coursesDBrefYork =
//FirebaseDatabase.instance.reference().child('courses').child('YorkU');

// 0 - University of Toronto | 1 - York University

int checkUniversity() {
  var userEmail = firebaseAuth.currentUser.email;
  if (userEmail.contains('utoronto')) {
    return 0;
  } else {
    return 1;
  }
}

Future<List<Course>> fetchCourses() async {
  var uniKey = checkUniversity();
  List<Course> c = List<Course>();
  var db = uniKey == 0
      ? FirebaseDatabase.instance.reference().child("courses").child('UofT')
      : FirebaseDatabase.instance.reference().child("courses").child('YorkU');

  DataSnapshot s = await db.once();

  Map<dynamic, dynamic> values = s.value;

  for (var value in values.values) {
    var course = Course(
        id: value['id'],
        code: value['code'],
        name: value['name'],
        memberCount: value['memberCount'],
        postCount: value['postCount']);

    if (value['memberList'] != null) {
      course.memberList = await getMemberList(value['memberList']);
    }

    course.inCourse = inCourse(course);
    c.add(course);
  }
  return c;
}

bool inCourse(Course course) {
  var uid = firebaseAuth.currentUser.uid;
  var memberList = course.memberList;
  if (memberList == null || memberList.length == 0) {
    return false;
  }
  if ((memberList.singleWhere((it) => it.id == uid, orElse: () => null)) !=
      null) {
    return true;
  } else {
    return false;
  }
}

Future<List<PostUser>> getMemberList(Map<dynamic, dynamic> members) async {
  var db = FirebaseDatabase.instance.reference().child('users');
  List<PostUser> p = [];
  for (var value in members.values) {
    DataSnapshot s = await db.child(value).once();
    Map<dynamic, dynamic> v = s.value;
    var user = PostUser(id: s.key, email: v['email'], name: v['name']);
    p.add(user);
  }
  if (p.isEmpty) {
    return [];
  } else {
    return p;
  }
}
