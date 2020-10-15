import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/club.dart';
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

// 0 - University of Toronto | 1 - York University

int checkUniversityWithEmail(String email) {
  if (email.contains('utoronto')) {
    return 0;
  } else {
    return 1;
  }
}

Future<Null> requestCourse(String code) async {
  var uniKey = Constants.checkUniversity();
  var db = FirebaseDatabase.instance
      .reference()
      .child('courserequests')
      .child(uniKey == 0 ? 'UofT' : 'YorkU');
  await db.push().set(code);
}

Future<Null> createCourse(String code, String name) async {
  var uniKey = Constants.checkUniversity();
  var db = FirebaseDatabase.instance
      .reference()
      .child('courses')
      .child(uniKey == 0 ? 'UofT' : 'YorkU');
  var key = db.push();
  Map<String, dynamic> data = {
    'code': code,
    'name': name,
    'memberCount': 0,
    'postCount': 0,
    'id': key.key
  };
  key.set(data);
}

Future<List<Course>> fetchCourses() async {
  var uniKey = Constants.checkUniversity();
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
        postCount: value['postCount']);

    if (value['memberList'] != null) {
      course.memberList = await getMemberList(value['memberList']);
    } else {
      course.memberList = [];
    }

    course.memberCount = course.memberList.length;

    course.inCourse = inCourse(course);
    c.add(course);
  }
  c.sort((a, b) => b.inCourse.toString().compareTo(a.inCourse.toString()));
  return c;
}

Future<bool> joinCourse(Course course) async {
  var uniKey = Constants.checkUniversity();
  var db = FirebaseDatabase.instance
      .reference()
      .child("courses")
      .child(uniKey == 0 ? 'UofT' : 'YorkU')
      .child(course.id)
      .child('memberList')
      .child(firebaseAuth.currentUser.uid);
  await db.set(firebaseAuth.currentUser.uid);
  return true;
}

Future<bool> leaveCourse(Course course) async {
  var uniKey = Constants.checkUniversity();
  var db = FirebaseDatabase.instance
      .reference()
      .child("courses")
      .child(uniKey == 0 ? 'UofT' : 'YorkU')
      .child(course.id)
      .child('memberList')
      .child(firebaseAuth.currentUser.uid);
  await db.remove();
  return true;
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
  var uniKey = Constants.checkUniversity();
  var db = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uniKey == 0 ? 'UofT' : 'YorkU');
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

Future<List<PostUser>> fetchMemberList(Course course, Club club) async {
  var uniKey = Constants.checkUniversity();
  var memberDB = FirebaseDatabase.instance
      .reference()
      .child(course != null ? 'courses' : 'clubs')
      .child(uniKey == 0 ? 'UofT' : 'YorkU')
      .child(course != null ? course.id : club.id)
      .child('memberList');
  DataSnapshot snap = await memberDB.once();
  Map<dynamic, dynamic> values = snap.value;

  var db = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uniKey == 0 ? 'UofT' : 'YorkU');

  List<PostUser> p = [];
  for (var value in values.values) {
    DataSnapshot s = await db.child(value).once();
    Map<dynamic, dynamic> v = s.value;
    var user = PostUser(id: s.key, email: v['email'], name: v['name']);
    p.add(user);
  }

  if (club != null) {
    var admin = await getUser(club.adminId);
    p.insert(0, admin);
  }

  if (p.isEmpty) {
    return [];
  } else {
    return p;
  }
}
