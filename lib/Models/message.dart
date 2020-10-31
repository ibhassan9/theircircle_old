import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/user.dart';

class Message {
  String id;
  String messageText;
  String receiverId;
  String senderId;
  int timestamp;

  Message(
      {this.id,
      this.messageText,
      this.receiverId,
      this.senderId,
      this.timestamp});
}

Future<List<Message>> fetchMessages(String chatId) async {
  var uniKey = Constants.checkUniversity();
  //var myID = firebaseAuth.currentUser.uid;
  var db = FirebaseDatabase.instance
      .reference()
      .child('chats')
      .child(uniKey == 0 ? 'UofT' : 'YorkU')
      .child(chatId);

  print('chat id');
  print(chatId);

  DataSnapshot snap = await db.once();
  List<Message> messages = [];

  if (snap.value != null) {
    print('snap isnt empty');
    Map<dynamic, dynamic> values = snap.value;
    for (var key in values.keys) {
      Message msg = Message(
          id: key,
          messageText: values[key]['messageText'],
          receiverId: values[key]['receiverId'],
          senderId: values[key]['senderId'],
          timestamp: values[key]['timeStamp']);
      print(msg);
      messages.add(msg);
    }
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
  return messages;
}

Future<bool> sendMessage(
    String messageText, String receiverId, String chatId) async {
  var uniKey = Constants.checkUniversity();
  var myID = firebaseAuth.currentUser.uid;
  var db = FirebaseDatabase.instance
      .reference()
      .child('chats')
      .child(uniKey == 0 ? 'UofT' : 'YorkU')
      .child(chatId);
  var key = db.push();
  final Map<String, dynamic> data = {
    "messageText": messageText,
    "receiverId": receiverId,
    "senderId": myID,
    "timeStamp": DateTime.now().millisecondsSinceEpoch
  };
  await key.set(data).catchError((err) {
    return false;
  });
  return true;
}
