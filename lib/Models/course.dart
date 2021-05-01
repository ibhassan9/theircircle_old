import 'package:firebase_database/firebase_database.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/DB.dart';

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

// 0 - University of Toronto | 1 - York University

int checkUniversityWithEmail(String email) {
  if (email.toLowerCase().contains('utoronto')) {
    return 0;
  } else if (email.toLowerCase().contains('yorku')) {
    return 1;
  } else {
    return 2;
  }
}

Future<Null> requestCourse(String code) async {
  var db = COURSE_REQUESTS_DB.child(Constants.uniString(uniKey));
  await db.push().set(code);
}

Future<Null> createCourse(String code, String name) async {
  var db =
      FirebaseDatabase.instance.reference().child('courses').child('YorkU');
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

Future<Course> fetchCourse(String id) async {
  var db = COURSES_DB.child(Constants.uniString(uniKey)).child(id);

  DataSnapshot s = await db.once();

  Map<dynamic, dynamic> value = s.value;

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
  return course;
}

Future<List<Course>> fetchCourses() async {
  List<Course> c = [];
  var db = COURSES_DB.child(Constants.uniString(uniKey));

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
  var db = COURSES_DB
      .child(Constants.uniString(uniKey))
      .child(course.id)
      .child('memberList')
      .child(FIR_UID);
  await db.set(FIR_UID);
  return true;
}

Future<bool> leaveCourse(Course course) async {
  var db = COURSES_DB
      .child(Constants.uniString(uniKey))
      .child(course.id)
      .child('memberList')
      .child(FIR_UID);
  await db.remove();
  return true;
}

bool inCourse(Course course) {
  var memberList = course.memberList;
  if (memberList == null || memberList.length == 0) {
    return false;
  }
  if ((memberList.singleWhere((it) => it.id == FIR_UID, orElse: () => null)) !=
      null) {
    return true;
  } else {
    return false;
  }
}

Future<List<PostUser>> getMemberList(Map<dynamic, dynamic> members) async {
  var db = USERS_DB.child(Constants.uniString(uniKey));
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
  var memberDB = (course != null ? COURSES_DB : CLUBS_DB)
      .child(Constants.uniString(uniKey))
      .child(course != null ? course.id : club.id)
      .child('memberList');
  DataSnapshot snap = await memberDB.once();
  Map<dynamic, dynamic> values = snap.value;

  var db = USERS_DB.child(Constants.uniString(uniKey));

  List<PostUser> p = [];
  for (var value in values.values) {
    DataSnapshot s = await db.child(value).once();
    PostUser user = await getUser(s.key);
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
