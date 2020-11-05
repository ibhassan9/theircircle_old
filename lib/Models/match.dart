import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/message.dart';
import 'package:unify/Models/user.dart';

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

FirebaseAuth firebaseAuth = FirebaseAuth.instance;

// Future<bool> swipeRight(String otherUID) async {
//   var uniKey = Constants.checkUniversity();
//   var myUID = firebaseAuth.currentUser.uid;
//   var uniqueId = myUID + otherUID;
//   var mydb = FirebaseDatabase.instance
//       .reference()
//       .child('users')
//       .child(uniKey == 0 ? 'UofT' : 'YorkU')
//       .child(myUID)
//       .child('matches');
//   var otherdb = FirebaseDatabase.instance
//       .reference()
//       .child('users')
//       .child(uniKey == 0 ? 'UofT' : 'YorkU')
//       .child(otherUID)
//       .child('matches')
//       .child(myUID);

//   //TODO:- update my match list with uniqueId;

//   // add user to my match list
//   await mydb.child(otherUID).set(otherUID);

//   // checking if my id is available in that users match list
//   // var isMatched = await checkIfMatched(otherUID);

//   if (isMatched == false) {
//     //TODO:- update my match list with uniqueId;
//     await mydb.child(otherUID).set(uniqueId);
//   } else {
//     //TODO:- check that users chatId and set it in my matches
//     DataSnapshot s = await otherdb.once();
//     String value = s.value;
//     await mydb.child(otherUID).set(value);
//   }

//   return isMatched;
// }

Future<List<dynamic>> fetchMyLikes() async {
  var uniKey = Constants.checkUniversity();
  var myUID = firebaseAuth.currentUser.uid;
  var mydb = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uniKey == 0 ? 'UofT' : 'YorkU')
      .child(myUID)
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
  var uniKey = Constants.checkUniversity();
  var myID = firebaseAuth.currentUser.uid;
  var userdb = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uniKey == 0 ? 'UofT' : 'YorkU')
      .child(myID)
      .child('chats')
      .child(peerId);
  await userdb.remove().catchError((onError) {
    return false;
  });
  return true;
}

// Future<List<Match>> fetchMatches() async {
//   var uniKey = Constants.checkUniversity();
//   var myUID = firebaseAuth.currentUser.uid;
//   List<Match> matches = [];
//   var mydb = FirebaseDatabase.instance
//       .reference()
//       .child('users')
//       .child(uniKey == 0 ? 'UofT' : 'YorkU')
//       .child(myUID)
//       .child('matches');

//   DataSnapshot snap = await mydb.once();
//   if (snap.value != null) {
//     Map<dynamic, dynamic> values = snap.value;
//     for (var key in values.keys) {
//       var user = await getUser(key);
//       var isMatched = await checkIfMatched(key);
//       if (isMatched) {
//         Match m = Match(user: user, chatId: values[key]);
//         matches.add(m);
//       }
//     }
//     return matches;
//   } else {
//     return matches;
//   }
// }

// Future<bool> checkIfMatched(String uid) async {
//   var uniKey = Constants.checkUniversity();
//   var myUID = firebaseAuth.currentUser.uid;
//   var db = FirebaseDatabase.instance
//       .reference()
//       .child('users')
//       .child(uniKey == 0 ? 'UofT' : 'YorkU')
//       .child(uid)
//       .child('matches')
//       .child(myUID);
//   DataSnapshot snap = await db.once();
//   if (snap.value == null) {
//     // not matched
//     return false;
//   } else {
//     // matched
//     return true;
//   }
// }

// Future<List<Match>> getConvoList() async {
//   var matches = await fetchMatches();
//   List<Match> convos = [];
//   for (var match in matches) {
//     PostUser user = match.user;
//     String chatId = match.chatId;
//     var messages = await fetchMessages(chatId);
//     var lastMessage = messages.last.messageText;
//     if (user.id != chatId) {
//       match.lastMessage = lastMessage;
//       convos.add(match);
//     }
//   }
//   return convos;
// }

Future<List<Match>> fetchChatList() async {
  var uniKey = Constants.checkUniversity();
  var myID = firebaseAuth.currentUser.uid;
  var userdb = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uniKey == 0 ? 'UofT' : 'YorkU')
      .child(myID)
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
      if (myID.hashCode <= peerId.hashCode) {
        chatId = '$myID-$peerId';
      } else {
        chatId = '$peerId-$myID';
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
