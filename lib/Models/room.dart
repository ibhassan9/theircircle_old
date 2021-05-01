import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/DB.dart';

class Room {
  String id;
  String name;
  String description;
  List<PostUser> members;
  List<PostUser> requests;
  String adminId;
  bool isAdmin;
  bool isLocked;
  String imageUrl;
  bool inRoom;
  bool isRequested;

  Room(
      {this.id,
      this.name,
      this.description,
      this.members,
      this.requests,
      this.adminId,
      this.isAdmin,
      this.isLocked,
      this.imageUrl,
      this.inRoom,
      this.isRequested});

  static Future<bool> isLive({String id}) async {
    var db = ROOMS_DB.child(Constants.uniString(uniKey)).child(id);
    DataSnapshot snapshot = await db.once();
    if (snapshot.value != null) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> create(
      {String name,
      String description,
      bool isLocked,
      Image coverImg,
      File imgFile}) async {
    var db = ROOMS_DB.child(Constants.uniString(uniKey));
    var key = db.push();

    String imgUrl = await uploadImageToStorage(imgFile);

    final Map<String, dynamic> data = {
      "id": key.key,
      "name": name,
      "description": description,
      "adminId": FIR_UID,
      "locked": isLocked,
      "imageUrl": imgUrl
    };

    await key.set(data);
    DataSnapshot ds = await key.once();
    if (ds.value != null) {
      return true;
    } else {
      return false;
    }
  }

  static Future<List<Room>> fetchAll() async {
    List<Room> rooms = [];
    var db = ROOMS_DB.child(Constants.uniString(uniKey));

    DataSnapshot s = await db.once();

    Map<dynamic, dynamic> values = s.value;

    if (s.value != null) {
      for (var key in values.keys) {
        Room room = await fetch(id: key);
        print(room);
        rooms.add(room);
      }
      rooms.sort((a, b) => b.inRoom.toString().compareTo(a.inRoom.toString()));
    }

    return rooms;
  }

  static Future<bool> delete({String id}) async {
    var db = ROOMS_DB.child(Constants.uniString(uniKey)).child(id);
    await db.remove().catchError((err) {
      return false;
    });
    return true;
  }

  static Future<Room> fetch({String id}) async {
    var db = ROOMS_DB.child(Constants.uniString(uniKey)).child(id);

    DataSnapshot s = await db.once();

    Map<dynamic, dynamic> value = s.value;

    var room = Room(
        id: value['id'],
        name: value['name'],
        description: value['description'],
        isAdmin: value['adminId'] == FIR_UID,
        isLocked: value['locked'],
        adminId: value['adminId'],
        imageUrl: value['imageUrl']);

    PostUser admin = await getUser(value['adminId']);

    if (value['members'] != null) {
      room.members = await getMembers(value['members']);
      room.members.insert(0, admin);
    } else {
      room.members = [admin];
    }

    if (value['joinRequests'] != null) {
      room.requests = await getRequests(value['requests']);
    } else {
      room.requests = [];
    }

    room.inRoom = isInRoom(room);
    room.isRequested = requested(room);

    return room;
  }

  static Future<bool> addMembers(
      {String roomId, List<PostUser> members}) async {
    var db = ROOMS_DB
        .child(Constants.uniString(uniKey))
        .child(roomId)
        .child('members');
    for (var member in members) {
      await db
          .child(member.id)
          .set(Constants.uniString(uniKey))
          .catchError((e) {
        return false;
      });
    }

    return true;
  }

  static Future<bool> deleteMember({String roomId, String memberId}) async {
    var db = ROOMS_DB
        .child(Constants.uniString(uniKey))
        .child(roomId)
        .child('members')
        .child(memberId);
    await db.remove().catchError((e) {
      return false;
    });
    return true;
  }

  static Future<bool> deleteRoom({String roomId}) async {
    var db = ROOMS_DB.child(Constants.uniString(uniKey)).child(roomId);
    await db.remove().catchError((e) {
      return false;
    });
    return true;
  }

  static Future<List<PostUser>> allMembers({Room room}) async {
    var db = ROOMS_DB
        .child(Constants.uniString(uniKey))
        .child(room.id)
        .child('members');
    DataSnapshot snap = await db.once();
    Map<dynamic, dynamic> values = snap.value;
    List<PostUser> m = await getMembers(values);
    PostUser admin = await getUser(room.adminId);
    m.insert(0, admin);
    return m;
  }

  static Future<bool> sendMessage({String message, String roomId}) async {
    var myID = FIR_UID;
    var db =
        ROOMS_DB.child(Constants.uniString(uniKey)).child(roomId).child('chat');
    var key = db.push();
    final Map<String, dynamic> data = {
      "messageText": message,
      "senderId": myID,
      "timeStamp": DateTime.now().millisecondsSinceEpoch
    };
    print('sending');
    await key.set(data).catchError((err) {
      return false;
    });
    return true;
  }

  static Future<bool> leave({String roomId}) async {
    var myID = FIR_UID;
    var db = ROOMS_DB
        .child(Constants.uniString(uniKey))
        .child(roomId)
        .child('members')
        .child(myID);
    await db.remove().catchError((e) {
      return false;
    });
    return true;
  }

  static Future<bool> join({String roomId}) async {
    var myID = FIR_UID;
    var db = ROOMS_DB
        .child(Constants.uniString(uniKey))
        .child(roomId)
        .child('members')
        .child(myID);
    await db.set(Constants.uniString(uniKey)).catchError((e) {
      return false;
    });
    return true;
  }

  static Future<dynamic> updateInfo(
      {String roomId, String name, String description, File imageFile}) async {
    var db = ROOMS_DB.child(Constants.uniString(uniKey)).child(roomId);
    String url;
    if (imageFile != null) {
      url = await uploadImageToStorage(imageFile);
    }

    Map<String, dynamic> data = {};

    if (name != null) {
      data['name'] = name;
    }

    if (description != null) {
      data['description'] = description;
    }

    if (url != null && url.contains('error') == false) {
      data['imageUrl'] = url;
    }

    await db.update(data).catchError((e) {
      return false;
    });

    if (url != null) {
      return url;
    } else {
      return true;
    }
  }
}

Future<List<PostUser>> getRequests(Map<dynamic, dynamic> requests) async {
  List<PostUser> users = [];
  for (var key in requests.keys) {
    PostUser user = await getUser(key);
    users.add(user);
  }
  return users;
}

bool isInRoom(Room room) {
  var memberList = room.members;
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

bool requested(Room room) {
  var joinRequests = room.requests;
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

Future<List<PostUser>> getMembers(Map<dynamic, dynamic> members) async {
  List<PostUser> users = [];
  if (members != null) {
    for (var key in members.keys) {
      PostUser user = await getUser(key);
      users.add(user);
    }
  }

  return users;
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
