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
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ChatPage.dart';
import 'package:unify/pages/VideoPreview.dart';
import 'package:unify/pages/club_page.dart';
import 'package:unify/pages/course_page.dart';
import 'package:unify/pages/post_detail_page.dart';

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
              'title': 'TheirCircle'
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

Future<Null> sendPush(int nID, String token, String text, String postId) async {
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
            'body': nID == 0
                ? "${me.name} liked your post: $text"
                : "${me.name} commented on your post: $text",
            'title': 'TheirCircle'
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

Future<Null> sendPushVideo(
    int nID, String token, String text, String videoId) async {
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
            'body': nID == 0
                ? "${me.name} liked your video"
                : "${me.name} commented on your video: $text",
            'title': 'TheirCircle'
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

Future<Null> sendPushChat(
    String token, String text, String userId, String chatId) async {
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
            "extradata": {'type': 'chat', 'id': userId, 'chatId': chatId}
          },
          'to': token,
        },
      ));
}

Future<Null> sendPushPoll(
    String token, String text, Club club, Course course, String postId) async {
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
                      ? course
                      : club,
              'postId': postId
            },
          },
          'to': token,
        },
      ));
}

Future<Null> send(String token) async {
  await http.post('https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${Constants.serverToken}',
      },
      body: json.encode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body':
                "Enter our Amazon Card Giveaway! For more information visit our instagram page @theircircle.",
            'title': 'Win with us!'
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

Future<Null> sendWelcome(String token, String username) async {
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
            'title': 'TheirCircle'
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

  DataSnapshot user1snap = await user1db.once();
  DataSnapshot user2snap = await user2db.once();

  Map<dynamic, dynamic> users1 = user1snap.value;
  Map<dynamic, dynamic> users2 = user2snap.value;

  for (var value in users1.values) {
    var token = value['device_token'];
    tokenIds.add(token);
  }

  for (var value in users2.values) {
    var token = value['device_token'];
    tokenIds.add(token);
  }

  for (var token in tokenIds) {
    await send(token);
  }
}

Future<Null> sendPushClub(
    Club club, int nID, String token, String text, String postId) async {
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
  }

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
            "extradata": {'type': 'club', 'id': club, 'postId': postId},
          },
          'to': token,
        },
      ));
}

Future<Null> sendPushCourse(
    Course course, int nID, String token, String text, String postId) async {
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
  }

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
            "extradata": {'type': 'course', 'id': course, 'postId': postId},
          },
          'to': token,
        },
      ));
}

Future<List<dynamic>> handleNotification(Map<String, dynamic> data) async {
  print('handling');
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

  print(screen);
  print(status);
  print(extradata);
  print(type);

  print('we are here');

  // if (data['extradata'] != null) {
  //   print('fetching extradata');
  //   extradata = data['extradata'];
  //   print('extradata found');
  //   print(extradata['type']);
  //   if (extradata['type'] != null) {
  //     type = extradata['type'];
  //     print('type found');
  //   } else {
  //     print('no type');
  //   }
  //   if (extradata['postId'] != null) {
  //     postId = extradata['postId'];
  //     print('postId found');
  //   } else {
  //     print('no postId');
  //   }
  //   if (extradata['id'] != null) {
  //     id = extradata['id'];
  //     print('id found');
  //   } else {
  //     print('no id');
  //   }
  //   if (extradata['chatId'] != null) {
  //     chatId = extradata['chatId'];
  //     print('chatId found');
  //   } else {
  //     print('no chatId');
  //   }
  //   print('done fetching');
  // }

  print('waiting');

  if (status == null || screen == null || extradata == null) {
    return null;
  }

  print('unsuccessful');

  switch (type) {
    // course, club, post, chat, video
    case "course":
      switch (screen) {
        case "COMMENT_PAGE":
          Post post = await fetchCoursePost(postId, id);
          Course course = id;
          print(post);
          values = [0, post, course, null, null, null, chatId];
          break;
        case "COURSE_PAGE":
          Course course = id;
          values = [1, null, course, null, null, null, chatId];
      }
      break;
    case "club":
      switch (screen) {
        case "COMMENT_PAGE":
          Post post = await fetchClubPost(postId, id);
          Club club = id;
          print(post);
          values = [2, post, null, club, null, null, chatId];
          break;
        case "CLUB_PAGE":
          Club club = id;
          values = [3, null, null, club, null, null, chatId];
      }
      break;
    case "post":
      Post post = await fetchPost(postId);
      print(post);
      values = [4, post, null, null, null, null, chatId];
      break;
    case "chat":
      PostUser receiver = await getUser(id);
      values = [5, null, null, null, null, receiver, chatId];
      break;
    case "video":
      Video video = await VideoApi.fetchVideo(id);
      print(video);
      values = [6, null, null, null, video, null, chatId];
      break;
    default:
      return null;
      break;
  }
  return values;
}
