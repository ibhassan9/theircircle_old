import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:unify/Components/Constants.dart';
import 'package:http/http.dart' as http;
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/Models/room.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ChatPage.dart';
import 'package:unify/pages/VideoPreview.dart';
import 'package:unify/pages/club_page.dart';
import 'package:unify/pages/course_page.dart';
import 'package:unify/pages/post_detail_page.dart';

class Notification {
  String notificationId;
  String screen;
  String type;
  String postId;
  String id;
  String chatId;
  String from;
  String university;
  String body;
  int timestamp;
  bool seen;

  Notification(
      {this.notificationId,
      this.screen,
      this.type,
      this.postId,
      this.id,
      this.chatId,
      this.from,
      this.university,
      this.body,
      this.timestamp,
      this.seen});
}

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
String title = "TheirCircle";

List<String> tokens = [
  "fUyyEAP3zE31kpDbULq5kx:APA91bFn73XC33Aa0m_mXvATmfq4GuUyxfcvRACoya6HBp7g7NhjKauk_LSMHpqUw9xEJRuwSILh-gumx7LRTMAW0URfKXilB44Ui23rcBf0m9q20XjJp0VdcITo5Gq4Ue6vnIsggCDQ",
  "duaYanAKcUNEohtCKPbRd-:APA91bH_MK1GolQBoLsttTFlZ2cQ86ekyrOcUuwQPusJ57pzXrqo26zKQNpvTIUiSvlOfQu_vbLeDk1AT7CGN4Ten8Sq2L0z1KLuobMKtPrtyATyOh_BEiPdGBSE7DFfT2wRNFfwQIl_",
  "e4npd5sc20EchE576RArLV:APA91bH0kvu13mrR-CXuItgJ8_qs0S8WHkF13saw4MyWDXjRehr1-B2-69WICM4F7D3jRxCWvy0GV3y5vGlD2-NwEBjoyTeJcLi8Nfm9Tlp9YmYdanssPJmwq4IECtdBhW93CdJ7LROu",
  "cmCkxsXQ1kRaobVxbvUhyD:APA91bHtMUXUdqgb0bg7VlT12-YW7GpVP8dRTLHlT5YMIVjzuB7p1PCeX-IuNIIhLlxMVhoE65RbtwD0EYBeGQP7OGGhwfiVO5PemsU95BOS8CDdvpotFmW713FukumNEDcEx9-ncT17",
  "fU2ebFuNO0U7tSpisnMSEx:APA91bFF45HAmD0RLmhuqnpfb79k-LPb8CpSfZy4VGz7PfoDau-d4GRic9cnJivOCoDV7Yjy5g-5SKaoWejbTWWijF6Zrge9DGTm482gn9hS4NtqyyECVpdXC0Qo7q8jy9_KdqI5UKmO",
  "cx-O-M-OrUZGhdxpVGwyHH:APA91bHmNXCpTfEWQWQo4OoxdSWpa0oRYQWp3HTs7jobYZqp79Wxu1ajVipwL2RpKl4YMR97Mgqt53sRwrMQDJgs1KSnC96CBXXPhykk7InTU-S4ZLmbbxCGcCQHqfmLKNEClR2UvIBK",
  "dsR6CELexksaoQ1iG1xu_7:APA91bECZNiav7ICXLKkHzBxUpEJt6AkV_c5hH1VM9OATt6XPOpIjyGTyWiFm56lvxkT42ePQeQeO-jqC-m1xqPwc-47uNFnEHMjRcnCtxtylBAYd34UOEzKuumw_3cNb-zTfL0WibpU",
  "ciFT1DxkLUGoj6OL_b2G7K:APA91bF5JhizUOKnyQEU3L2CDqAh4UwwmY8xR5hyG7kuPlByBRDC6RchV1VKTnNP3KUBEhBLce2AZ2s930PNeujkzWh1ZNSQqcK_CVMa6RT7rGHKMNNUljSBCljeg7wFWVRYU2dpwfd8",
  "eVIMsxzlSUm0vXNwu5mjet:APA91bH3vwTyn9L539ms0Dbqpw6YglQMSZazXB3PLlAH90PNN1U21tFPBfqmNERmbrlGDOMiUszG0McMJPvZG9Qx2qd7ZtU3v-wCuPB86yHV0c2sZ2xu0RV4hzjz72x3ZsCD6MtXyBp_",
  "craRXyKiv0p7iJr0IQEGdC:APA91bFIeri2EwDEh0nCw47jKmM093BonDtUIbqyP4N5g1j1LK3HzCrBmOhqYZ-jqqugMwGJxjHVcARHobamJZvI8SHEReD8_1OYtwO_ymsfq5hje7NLlcJ-0owxUaPTI2RfFShflBzv"
];

Future<Null> sendToAll() async {
  for (var token in tokens) {
    await http.post('https://fcm.googleapis.com/fcm/send',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=${Constants.serverToken}',
        },
        body: json.encode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body':
                  'A huge thank you to everyone that is a part of TheirCircle! Show your appreciation with a simple post to be featured in our IG page!',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done'
            },
            'to': token,
          },
        ));
  }
}

Future<Null> sendPush(int nID, String token, String text, String postId,
    String receiverId) async {
  var uid = firebaseAuth.currentUser.uid;
  var me = await getUser(uid);

  Notification notification = Notification(
      screen: "COMMENT_PAGE",
      type: "post",
      postId: postId,
      from: me.id,
      university: Constants.checkUniversity() == 0
          ? 'UofT'
          : Constants.checkUniversity() == 1
              ? 'YorkU'
              : 'WesternU',
      body: nID == 0
          ? "${me.name} liked your post: $text"
          : nID == 1
              ? "${me.name} commented on your post: $text"
              : "${me.name} tagged you in a comment: $text");

  await uploadNotification(notification, receiverId);

  await http.post('https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${Constants.serverToken}',
      },
      body: json.encode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': nID == 0
                ? "${me.name} liked your post: $text"
                : nID == 1
                    ? "${me.name} commented on your post: $text"
                    : "${me.name} tagged you in a comment: $text",
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
            "sound": "default",
            "screen": "COMMENT_PAGE",
            "extradata": {'type': 'post', 'postId': postId},
          },
          'to': token,
        },
      ));
}

Future<Null> sendPushVideo(int nID, String token, String text, String videoId,
    String receiverId) async {
  var uid = firebaseAuth.currentUser.uid;
  var me = await getUser(uid);

  Notification notification = Notification(
      screen: "VIDEO_COMMENT_PAGE",
      type: "video",
      from: me.id,
      university: Constants.checkUniversity() == 0
          ? 'UofT'
          : Constants.checkUniversity() == 1
              ? 'YorkU'
              : 'WesternU',
      id: videoId,
      body: nID == 0
          ? "${me.name} liked your video"
          : "${me.name} commented on your video: $text");

  await uploadNotification(notification, receiverId);

  await http.post('https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${Constants.serverToken}',
      },
      body: json.encode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': nID == 0
                ? "${me.name} liked your video"
                : "${me.name} commented on your video: $text",
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
            "sound": "default",
            "screen": "VIDEO_COMMENT_PAGE",
            "extradata": {
              'type': 'video',
              'id': videoId,
            },
          },
          'to': token,
        },
      ));
}

Future<Null> sendPushChat(String token, String text, String userId,
    String chatId, String receiverId) async {
  var uid = firebaseAuth.currentUser.uid;
  var me = await getUser(uid);

  await http.post('https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${Constants.serverToken}',
      },
      body: json.encode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': "$text",
            'title': '${me.name}'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
            "sound": "default",
            "screen": "CHAT_PAGE",
            "extradata": {'type': 'chat', 'id': uid, 'chatId': chatId}
          },
          'to': token,
        },
      ));
}

Future<Null> sendPushRoomChat(
    List<String> tokens, String text, Room room) async {
  var uid = firebaseAuth.currentUser.uid;
  var me = await getUser(uid);
  print('sending');
  for (var token in tokens) {
    print('sending to ' + token);
    await http
        .post('https://fcm.googleapis.com/fcm/send',
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'key=${Constants.serverToken}',
            },
            body: json.encode(
              <String, dynamic>{
                'notification': <String, dynamic>{
                  'body': '${me.name}: $text',
                  'title': '${room.name}'
                },
                'priority': 'high',
                'data': <String, dynamic>{
                  'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                  'status': 'done',
                  "sound": "default",
                  "screen": "ROOM_PAGE",
                  "extradata": {'type': 'room', 'id': room.id}
                },
                'to': token,
              },
            ))
        .catchError((e) {
      print(e.toString());
    });
    print('sent to ' + token);
  }
}

Future<Null> sendPushPoll(String token, String text, Club club, Course course,
    String postId, String receiverId) async {
  var uid = firebaseAuth.currentUser.uid;
  var me = await getUser(uid);

  Notification notification = Notification(
      screen: "COMMENT_PAGE",
      type: club == null && course == null
          ? 'post'
          : club == null
              ? 'course'
              : 'club',
      postId: postId,
      from: me.id,
      university: Constants.checkUniversity() == 0
          ? 'UofT'
          : Constants.checkUniversity() == 1
              ? 'YorkU'
              : 'WesternU',
      id: club == null && course == null
          ? null
          : club == null
              ? course.id
              : club.id,
      body: text);

  await uploadNotification(notification, receiverId);

  await http.post('https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${Constants.serverToken}',
      },
      body: json.encode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': "$text",
            'title': '${me.name}'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
            "sound": "default",
            "screen": "COMMENT_PAGE",
            "extradata": {
              'type': club == null && course == null
                  ? 'post'
                  : club == null
                      ? 'course'
                      : 'club',
              'id': club == null && course == null
                  ? null
                  : club == null
                      ? course.id
                      : club.id,
              'postId': postId
            },
          },
          'to': token,
        },
      ));
}

Future<Null> send(String token, String receiverId) async {
  await http
      .post('https://fcm.googleapis.com/fcm/send',
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=${Constants.serverToken}',
          },
          body: json.encode(
            <String, dynamic>{
              'notification': <String, dynamic>{
                'body':
                    "Answer our question of the day: How do you deal with negative criticism?",
              },
              'priority': 'high',
              'data': <String, dynamic>{
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'status': 'done'
              },
              'to': token,
            },
          ))
      .then((value) {
    print('Sent to ' + receiverId);
  });
}

Future<Null> pushAddedToRoom({Room room, String receiverId}) async {
  await http.post('https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${Constants.serverToken}',
      },
      body: json.encode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': "You've been added to ${room.name}",
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
            "sound": "default",
            "screen": "ROOMS_PAGE",
            "extradata": {
              'type': 'room',
              'id': room.id,
            },
          },
          'to': receiverId,
        },
      ));
}

Future<Null> pushRemovedFromRoom({Room room, String receiverId}) async {
  await http.post('https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${Constants.serverToken}',
      },
      body: json.encode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': "You've been removed from ${room.name}",
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
            "sound": "default",
          },
          'to': receiverId,
        },
      ));
}

Future<Null> sendWelcome(
    String token, String username, String receiverId) async {
  await http.post('https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${Constants.serverToken}',
      },
      body: json.encode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body':
                "Hey $username 👋🏻. Your account has been verified! You should be able to use the app now.",
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done'
          },
          'to': token,
        },
      ));
}

Future<Null> sendNewQuestionToAll() async {
  List<String> tokenIds = [];
  var user1db =
      FirebaseDatabase.instance.reference().child('users').child('UofT');
  var user2db =
      FirebaseDatabase.instance.reference().child('users').child('YorkU');
  var user3db =
      FirebaseDatabase.instance.reference().child('users').child('WesternU');

  DataSnapshot user1snap = await user1db.once();
  DataSnapshot user2snap = await user2db.once();
  DataSnapshot user3snap = await user3db.once();

  Map<dynamic, dynamic> users1 = user1snap.value;
  Map<dynamic, dynamic> users2 = user2snap.value;
  Map<dynamic, dynamic> users3 = user3snap.value;

  for (var value in users1.values) {
    var token = value['device_token'];
    tokenIds.add(token);
  }

  for (var value in users2.values) {
    var token = value['device_token'];
    tokenIds.add(token);
  }

  for (var value in users3.values) {
    var token = value['device_token'];
    tokenIds.add(token);
  }

  for (var token in tokenIds) {
    await send(token, '');
  }
}

Future<Null> sendPushClub(Club club, int nID, String token, String text,
    String postId, String receiverId) async {
  var body = "";

  await Constants.fm.requestNotificationPermissions(
    const IosNotificationSettings(
        sound: true, badge: true, alert: true, provisional: false),
  );

  var uid = firebaseAuth.currentUser.uid;
  var me = await getUser(uid);
  var t = "${club.name}";

  switch (nID) {
    case 0:
      body = "${me.name} liked your post: $text";
      break;
    case 1:
      body = "${me.name} commented on your post: $text";
      break;
    case 2:
      body = "Your join request has been approved.";
      break;
    case 3:
      body = "Your event has been removed by admin from the shared calender.";
      break;
    case 4:
      body = "${me.name} added a note: $text";
      break;
    case 5:
      body = "${me.name} sent a request to join your club.";
      break;
    case 6:
      body = "${me.name} joined your club.";
      break;
    case 7:
      body = "${me.name} tagged you in a comment: $text";
      break;
  }

  Notification notification = Notification(
      university: Constants.checkUniversity() == 0
          ? 'UofT'
          : Constants.checkUniversity() == 1
              ? 'YorkU'
              : 'WesternU',
      from: me.id,
      screen: nID == 0 || nID == 1 ? "COMMENT_PAGE" : "CLUB_PAGE",
      type: 'club',
      id: club.id,
      postId: postId,
      body: body);

  await uploadNotification(notification, receiverId);

  await http.post('https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${Constants.serverToken}',
      },
      body: json.encode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': body, 'title': t},
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
            "sound": "default",
            "screen": nID == 0 || nID == 1 ? "COMMENT_PAGE" : "CLUB_PAGE",
            "extradata": {'type': 'club', 'id': club.id, 'postId': postId},
          },
          'to': token,
        },
      ));
}

Future<Null> sendPushCourse(Course course, int nID, String token, String text,
    String postId, String receiverId) async {
  var body = "";

  await Constants.fm.requestNotificationPermissions(
    const IosNotificationSettings(
        sound: true, badge: true, alert: true, provisional: false),
  );

  var uid = firebaseAuth.currentUser.uid;
  var me = await getUser(uid);
  var t = "${course.name}";

  switch (nID) {
    case 0:
      body = "${me.name} liked your post: $text";
      break;
    case 1:
      body = "${me.name} commented on your post: $text";
      break;
    case 4:
      body = "${me.name} added a note: $text";
      break;
    case 5:
      body = "${me.name} tagged you in a comment: $text";
      break;
  }

  Notification notification = Notification(
      university: Constants.checkUniversity() == 0
          ? 'UofT'
          : Constants.checkUniversity() == 1
              ? 'YorkU'
              : 'WesternU',
      from: me.id,
      screen: nID == 4 ? "COURSE_PAGE" : "COMMENT_PAGE",
      type: 'course',
      id: course.id,
      postId: postId,
      body: body);
  await uploadNotification(notification, receiverId);

  await http.post('https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${Constants.serverToken}',
      },
      body: json.encode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': body, 'title': t},
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
            "sound": "default",
            "screen": nID == 4 ? "COURSE_PAGE" : "COMMENT_PAGE",
            "extradata": {'type': 'course', 'id': course.id, 'postId': postId},
          },
          'to': token,
        },
      ));
}

Future<bool> uploadNotification(Notification n, String receiverId) async {
  var db = FirebaseDatabase.instance
      .reference()
      .child('notifications')
      .child(receiverId);
  var key = db.push();

  Map<dynamic, dynamic> data = {
    "timestamp": DateTime.now().millisecondsSinceEpoch,
    "seen": false,
  };

  if (n.screen != null) {
    data["screen"] = n.screen;
  }

  if (n.type != null) {
    data['type'] = n.type;
  }

  if (n.postId != null) {
    data['postId'] = n.postId;
  }

  if (n.id != null) {
    data['id'] = n.id;
  }

  if (n.chatId != null) {
    data['chatId'] = n.chatId;
  }

  if (n.from != null) {
    data['from'] = n.from;
  }

  if (n.university != null) {
    data['university'] = n.university;
  }

  if (n.body != null) {
    data['body'] = n.body;
  }

  db.child(key.key).set(data).catchError((e) {
    return false;
  });
  return true;
}

Future<List<Notification>> fetchNotifications() async {
  List<Notification> notifications = [];
  var uid = firebaseAuth.currentUser.uid;
  var db =
      FirebaseDatabase.instance.reference().child('notifications').child(uid);

  DataSnapshot snap = await db.once();
  Map<dynamic, dynamic> values = snap.value;

  if (snap.value != null) {
    values.forEach((key, value) {
      var screen = value['screen'] != null ? value['screen'] : null;
      var type = value['type'] != null ? value['type'] : null;
      var postId = value['postId'] != null ? value['postId'] : null;
      var id = value['id'] != null ? value['id'] : null;
      var chatId = value['chatId'] != null ? value['chatId'] : null;
      var from = value['from'] != null ? value['from'] : null;
      var university = value['university'] != null ? value['university'] : null;
      var body = value['body'] != null ? value['body'] : null;
      var seen = value['seen'] != null ? value['seen'] : false;
      Notification notification = Notification(
          notificationId: key,
          screen: screen,
          type: type,
          postId: postId,
          id: id,
          chatId: chatId,
          from: from,
          university: university,
          body: body,
          timestamp: value['timestamp'],
          seen: seen);

      notifications.add(notification);
    });
  }

  notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

  return notifications;
}

Future<List<dynamic>> handleNotification(Map<String, dynamic> data) async {
  var status = data['status'];
  var screen = data['screen'];
  Map<String, dynamic> extradata;
  var type;
  var postId;
  var id;
  var chatId;

  if (data['extradata'] != null) {
    extradata = json.decode(data['extradata']);
    extradata.forEach((key, value) {
      if (key == 'type') {
        type = value;
      } else if (key == 'postId') {
        postId = value;
      } else if (key == 'id') {
        id = value;
      } else if (key == 'chatId') {
        chatId = value;
      }
    });
  }

  List<dynamic> values;

  if (status == null || screen == null || extradata == null) {
    return null;
  }

  switch (type) {
    // course, club, post, chat, video
    case "course":
      Course course = await fetchCourse(id);
      switch (screen) {
        case "COMMENT_PAGE":
          Post post = await fetchCoursePost(postId, id);
          // fetch course
          values = [0, post, course, null, null, null, chatId];
          break;
        case "COURSE_PAGE":
          values = [1, null, course, null, null, null, chatId];
      }
      break;
    case "club":
      Club club = await fetchClub(id);
      switch (screen) {
        case "COMMENT_PAGE":
          Post post = await fetchClubPost(postId, id);
          // fetch club
          values = [2, post, null, club, null, null, chatId, null];
          break;
        case "CLUB_PAGE":
          values = [3, null, null, club, null, null, chatId, null];
      }
      break;
    case "post":
      Post post = await fetchPost(postId);
      values = [4, post, null, null, null, null, chatId, null];
      break;
    case "chat":
      PostUser receiver = await getUser(id);
      values = [5, null, null, null, null, receiver, chatId, null];
      break;
    case "video":
      Video video = await VideoApi.fetchVideo(id);
      values = [6, null, null, null, video, null, chatId, null];
      break;
    case "room":
      Room room = await Room.fetch(id: id);
      values = [7, null, null, null, null, null, null, room];
      break;
    default:
      return null;
      break;
  }
  return values;
}

Future<Null> seenAllNotifications() async {
  var db = FirebaseDatabase.instance
      .reference()
      .child('notifications')
      .child(firebaseAuth.currentUser.uid);
  List<Notification> notifications = await fetchNotifications();
  for (var notification in notifications) {
    var key = notification.notificationId;
    db.child(key).child('seen').set(true);
  }
}

Future<Null> seenNotification(String id) async {
  var db = FirebaseDatabase.instance
      .reference()
      .child('notifications')
      .child(firebaseAuth.currentUser.uid)
      .child(id)
      .child('seen');
  await db.set(true);
}
