import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/Models/user.dart';

class Club {
  String id;
  String adminId;
  String name;
  String description;
  int memberCount;
  List<PostUser> memberList;
  int postCount;
  List<PostUser> joinRequests;
  bool admin;
  bool inClub;
  bool requested;
  int privacy;

  Club(
      {this.id,
      this.adminId,
      this.name,
      this.description,
      this.memberCount,
      this.memberList,
      this.postCount,
      this.joinRequests,
      this.admin,
      this.inClub,
      this.requested,
      this.privacy});
}

FirebaseAuth firebaseAuth = FirebaseAuth.instance;

Future<List<Club>> fetchClubs() async {
  var uniKey = checkUniversity();
  List<Club> c = List<Club>();
  var db = uniKey == 0
      ? FirebaseDatabase.instance.reference().child("clubs").child('UofT')
      : FirebaseDatabase.instance.reference().child("clubs").child('YorkU');

  DataSnapshot s = await db.once();

  Map<dynamic, dynamic> values = s.value;

  for (var value in values.values) {
    var club = Club(
        id: value['id'],
        name: value['name'],
        description: value['description'],
        memberCount: value['memberCount'],
        postCount: value['postCount'],
        admin: value['adminId'] == firebaseAuth.currentUser.uid,
        privacy: value['privacy'],
        adminId: value['adminId']);

    PostUser admin = await getUser(value['adminId']);

    if (value['memberList'] != null) {
      club.memberList = await getMemberList(value['memberList']);
      club.memberList.insert(0, admin);
    } else {
      club.memberList = [admin];
    }

    if (value['joinRequests'] != null) {
      club.joinRequests = await getJoinRequests(value['joinRequests']);
    }

    club.inClub = inClub(club);
    club.requested = isRequested(club);

    c.add(club);
  }

  return c;
}

Future<List<PostUser>> getJoinRequests(Map<dynamic, dynamic> requests) async {
  var db = FirebaseDatabase.instance.reference().child('users');
  List<PostUser> p = [];
  for (var value in requests.values) {
    DataSnapshot s = await db.child(value).once();
    Map<dynamic, dynamic> v = s.value;
    var user = PostUser(id: s.key, email: v['email'], name: v['name']);
    p.add(user);
  }
  return p;
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

Future<bool> requestToJoin(Club club) async {
  var uniKey = checkUniversity();
  var db = FirebaseDatabase.instance
      .reference()
      .child("clubs")
      .child(uniKey == 0 ? 'UofT' : 'YorkU')
      .child(club.id)
      .child('joinRequests')
      .child(firebaseAuth.currentUser.uid);
  await db.set(firebaseAuth.currentUser.uid);
  return true;
}

Future<bool> removeJoinRequest(Club club) async {
  var uniKey = checkUniversity();
  var db = FirebaseDatabase.instance
      .reference()
      .child("clubs")
      .child(uniKey == 0 ? 'UofT' : 'YorkU')
      .child(club.id)
      .child('joinRequests')
      .child(firebaseAuth.currentUser.uid);
  await db.remove();
  return true;
}

Future<bool> removeUserFromRequests(Club club, PostUser user) async {
  var uniKey = checkUniversity();
  var db = FirebaseDatabase.instance
      .reference()
      .child("clubs")
      .child(uniKey == 0 ? 'UofT' : 'YorkU')
      .child(club.id)
      .child('joinRequests')
      .child(user.id);
  await db.remove();
  return true;
}

Future<bool> acceptUserToClub(PostUser user, Club club) async {
  var uniKey = checkUniversity();
  var db = FirebaseDatabase.instance
      .reference()
      .child("clubs")
      .child(uniKey == 0 ? 'UofT' : 'YorkU')
      .child(club.id)
      .child('memberList')
      .child(user.id);
  await db.set(user.id);
  await removeUserFromRequests(club, user);
  return true;
}

bool inClub(Club club) {
  var uid = firebaseAuth.currentUser.uid;
  var memberList = club.memberList;
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

bool isRequested(Club club) {
  var uid = firebaseAuth.currentUser.uid;
  var joinRequests = club.joinRequests;
  if (joinRequests == null || joinRequests.length == 0) {
    return false;
  }
  if ((joinRequests.singleWhere((it) => it.id == uid, orElse: () => null)) !=
      null) {
    return true;
  } else {
    return false;
  }
}

Future<bool> createClub(Club club) async {
  var uniKey = checkUniversity();
  var uid = firebaseAuth.currentUser.uid;
  var db = uniKey == 0
      ? FirebaseDatabase.instance.reference().child('clubs').child('UofT')
      : FirebaseDatabase.instance.reference().child('clubs').child('YorkU');
  var key = db.push();

  final Map<String, dynamic> data = {
    "id": key.key,
    "name": club.name,
    "description": club.description,
    "memberCount": 1,
    "postCount": 0,
    "adminId": uid
  };

  await key.set(data);
  DataSnapshot ds = await key.once();
  if (ds.value != null) {
    return true;
  } else {
    return false;
  }
}

Future<bool> joinClub(Club club) async {}

Future<bool> leaveClub(Club club) async {}
