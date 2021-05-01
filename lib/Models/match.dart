import 'package:firebase_database/firebase_database.dart';
import 'package:unify/pages/DB.dart';

class Match {
  String peerId;
  String chatId;
  String lastMessage;
  int timestamp;
  bool seen;
  String lastMessageSenderId;

  Match(
      {this.peerId,
      this.chatId,
      this.lastMessage,
      this.timestamp,
      this.seen,
      this.lastMessageSenderId});
}

Future<List<dynamic>> fetchMyLikes() async {
  var mydb = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU')
      .child(FIR_UID)
      .child('matches');
  DataSnapshot snap = await mydb.once();
  var likes = [];
  if (snap.value != null) {
    Map<dynamic, dynamic> values = snap.value;
    for (var key in values.keys) {
      likes.add(key);
    }
    return likes;
  }
  return likes;
}

Future<bool> removeChat(String peerId) async {
  var userdb = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU')
      .child(FIR_UID)
      .child('chats')
      .child(peerId);
  await userdb.remove().catchError((onError) {
    return false;
  });
  return true;
}

Future<List<Match>> fetchChatList() async {
  var userdb = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU')
      .child(FIR_UID)
      .child('chats');
  DataSnapshot snap = await userdb.once();
  List<Match> chats = [];

  if (snap.value != null) {
    Map<dynamic, dynamic> values = snap.value;
    for (var key in values.keys) {
      String peerId = key;
      String lastMessage = values[key]['lastMessage'];
      int timestamp = values[key]['timestamp'];
      String chatId = '';
      if (FIR_UID.hashCode <= peerId.hashCode) {
        chatId = '$FIR_UID-$peerId';
      } else {
        chatId = '$peerId-$FIR_UID';
      }
      Match match = Match(
          peerId: peerId,
          chatId: chatId,
          lastMessage: lastMessage,
          timestamp: timestamp);
      chats.add(match);
    }
  }
  chats.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return chats;
}
