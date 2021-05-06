import 'package:firebase_database/firebase_database.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/pages/DB.dart';

class Message {
  String id;
  String messageText;
  String receiverId;
  String senderId;
  int timestamp;
  String productId;
  String imageUrl;

  Message(
      {this.id,
      this.messageText,
      this.receiverId,
      this.senderId,
      this.timestamp,
      this.productId,
      this.imageUrl});
}

Future<List<Message>> fetchMessages(String chatId) async {
  var db = CHATS_DB.child(Constants.uniString(uniKey)).child(chatId);

  DataSnapshot snap = await db.once();
  List<Message> messages = [];

  if (snap.value != null) {
    Map<dynamic, dynamic> values = snap.value;
    for (var key in values.keys) {
      Message msg = Message(
          id: key,
          messageText: values[key]['messageText'],
          receiverId: values[key]['receiverId'],
          senderId: values[key]['senderId'],
          timestamp: values[key]['timeStamp']);

      if (values[key]['imageUrl'] != null) {
        msg.imageUrl = values[key]['imageUrl'];
      }
      messages.add(msg);
    }
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
  return messages;
}

Future<bool> sendMessage(String messageText, String receiverId, String chatId,
    String prodId, String imageUrl) async {
  var db = CHATS_DB.child(Constants.uniString(uniKey)).child(chatId);
  var userdb = USERS_DB
      .child(Constants.uniString(uniKey))
      .child(FIR_UID)
      .child('chats')
      .child(receiverId);
  var peerdb = USERS_DB
      .child(Constants.uniString(uniKey))
      .child(receiverId)
      .child('chats')
      .child(FIR_UID);
  var key = db.push();
  final Map<String, dynamic> data = {
    "messageText": messageText,
    "receiverId": receiverId,
    "senderId": FIR_UID,
    "timeStamp": DateTime.now().millisecondsSinceEpoch
  };
  if (prodId != null) {
    data['prodId'] = prodId;
  }

  if (imageUrl != null) {
    data['imageUrl'] = imageUrl;
  }
  print('sending');
  await key.set(data).catchError((err) {
    return false;
  });
  await userdb.set({
    'lastMessage': messageText,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
    'senderId': FIR_UID,
    'seen': true
  });
  await peerdb.set({
    'lastMessage': messageText,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
    'senderId': FIR_UID,
    'seen': false
  });
  return true;
}

Future<Null> setSeen(String peerId) async {
  var userdb = USERS_DB
      .child(Constants.uniString(uniKey))
      .child(FIR_UID)
      .child('chats')
      .child(peerId);
  await userdb.child('seen').set(true);
}

// Future<List<Message>> fetchChatMessage(String peerId) async {
//   var chatId = '';
//   if (FIR_UID.hashCode <= peerId.hashCode) {
//     chatId = '$FIR_UID-$peerId';
//   } else {
//     chatId = '$peerId-$FIR_UID';
//   }
// }
