import 'package:firebase_database/firebase_database.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/DB.dart';

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
  String imgUrl;

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
      this.privacy,
      this.imgUrl});
}

Future<Club> fetchClub(String id) async {
  var db = CLUBS_DB.child(Constants.uniString(uniKey)).child(id);

  DataSnapshot s = await db.once();

  Map<dynamic, dynamic> value = s.value;

  var club = Club(
      id: value['id'],
      name: value['name'],
      description: value['description'],
      postCount: value['postCount'],
      admin: value['adminId'] == FIR_UID,
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
    club.joinRequests = await getOldJoinRequests(value['joinRequests']);
  } else {}

  club.memberCount = club.memberList.length;

  club.inClub = inClub(club);
  club.requested = isRequested(club);

  return club;
}

Future<List<Club>> fetchClubs() async {
  List<Club> c = [];
  var db = CLUBS_DB.child(Constants.uniString(uniKey));

  DataSnapshot s = await db.once();

  Map<dynamic, dynamic> values = s.value;

  for (var value in values.values) {
    var club = Club(
        id: value['id'],
        name: value['name'],
        description: value['description'],
        postCount: value['postCount'],
        admin: value['adminId'] == FIR_UID,
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
      club.joinRequests = await getOldJoinRequests(value['joinRequests']);
    } else {}

    club.memberCount = club.memberList.length;

    club.inClub = inClub(club);
    club.requested = isRequested(club);

    c.add(club);
  }
  c.sort((a, b) => b.inClub.toString().compareTo(a.inClub.toString()));

  return c;
}

Future<List<PostUser>> getOldJoinRequests(
    Map<dynamic, dynamic> requests) async {
  var db = USERS_DB.child(Constants.uniString(uniKey));
  List<PostUser> p = [];
  for (var value in requests.values) {
    DataSnapshot s = await db.child(value).once();
    Map<dynamic, dynamic> v = s.value;
    var user = PostUser(
        id: s.key,
        email: v['email'],
        name: v['name'],
        bio: v['bio'],
        profileImgUrl: v['profileImgUrl']);
    p.add(user);
  }
  return p;
}

Future<bool> removeUserFromClub(Club club, PostUser user) async {
  var userdb = USERS_DB
      .child(Constants.uniString(uniKey))
      .child(user.id)
      .child('myclubs')
      .child(club.id);
  var db = CLUBS_DB
      .child(Constants.uniString(uniKey))
      .child(club.id)
      .child('memberList')
      .child(user.id);
  await userdb.remove();
  await db.remove().catchError((e) {
    return false;
  });
  return true;
}

Future<List<PostUser>> getJoinRequests(Club club) async {
  List<PostUser> p = [];
  var db = CLUBS_DB
      .child(Constants.uniString(uniKey))
      .child(club.id)
      .child('joinRequests');

  DataSnapshot s = await db.once();
  Map<dynamic, dynamic> values = s.value;
  for (var value in values.values) {
    var id = value;
    DataSnapshot us =
        await USERS_DB.child(Constants.uniString(uniKey)).child(id).once();
    Map<dynamic, dynamic> v = us.value;
    var user = PostUser(id: id, email: v['email'], name: v['name']);
    p.add(user);
  }
  return p;
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

Future<bool> requestToJoin(Club club) async {
  var db = CLUBS_DB
      .child(Constants.uniString(uniKey))
      .child(club.id)
      .child('joinRequests')
      .child(FIR_UID);
  await db.set(FIR_UID);
  return true;
}

Future<bool> removeJoinRequest(Club club) async {
  var db = CLUBS_DB
      .child(Constants.uniString(uniKey))
      .child(club.id)
      .child('joinRequests')
      .child(FIR_UID);
  await db.remove();
  return true;
}

Future<bool> removeUserFromRequests(Club club, PostUser user) async {
  var db = CLUBS_DB
      .child(Constants.uniString(uniKey))
      .child(club.id)
      .child('joinRequests')
      .child(user.id);
  await db.remove();
  return true;
}

Future<bool> acceptUserToClub(PostUser user, Club club) async {
  var userdb = USERS_DB
      .child(Constants.uniString(uniKey))
      .child(user.id)
      .child('myclubs')
      .child(club.id);
  var db = CLUBS_DB.child(Constants.uniString(uniKey)).child(club.id);
  await userdb.set(club.id);
  await db.child('memberList').child(user.id).set(user.id);
  await removeUserFromRequests(club, user);
  return true;
}

bool inClub(Club club) {
  var memberList = club.memberList;
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

bool isRequested(Club club) {
  var joinRequests = club.joinRequests;
  if (joinRequests == null || joinRequests.length == 0) {
    return false;
  }
  if ((joinRequests.singleWhere((it) => it.id == FIR_UID,
          orElse: () => null)) !=
      null) {
    return true;
  } else {
    return false;
  }
}

Future<bool> createClub(Club club) async {
  var db = CLUBS_DB.child(Constants.uniString(uniKey));
  var key = db.push();

  final Map<String, dynamic> data = {
    "id": key.key,
    "name": club.name,
    "description": club.description,
    "memberCount": 1,
    "postCount": 0,
    "adminId": FIR_UID,
    "privacy": club.privacy
  };

  await key.set(data);
  DataSnapshot ds = await key.once();
  if (ds.value != null) {
    return true;
  } else {
    return false;
  }
}

Future<bool> joinClub(Club club) async {
  var db = CLUBS_DB.child(Constants.uniString(uniKey)).child(club.id);
  var userdb = USERS_DB
      .child(Constants.uniString(uniKey))
      .child(FIR_UID)
      .child('myclubs')
      .child(club.id);
  await userdb.set(club.id);
  await db.child('memberList').child(FIR_UID).set(FIR_UID);
  return true;
}

Future<bool> deleteClub(Club club) async {
  var db = CLUBS_DB.child(Constants.uniString(uniKey)).child(club.id);
  await db.remove().catchError((err) {
    return false;
  });
  var assignmentDB = EVENT_REMINDERS_DB.child(club.id);
  await assignmentDB.remove().catchError((err) {
    return false;
  });
  return true;
}

Future<bool> leaveClub(Club club) async {
  var userdb = USERS_DB
      .child(Constants.uniString(uniKey))
      .child(FIR_UID)
      .child('myclubs')
      .child(club.id);
  var db = CLUBS_DB.child(Constants.uniString(uniKey)).child(club.id);
  await db.child('memberList').child(FIR_UID).remove();
  await userdb.remove();
  return true;
}
