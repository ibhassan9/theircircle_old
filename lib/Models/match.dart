import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/user.dart';

FirebaseAuth firebaseAuth = FirebaseAuth.instance;

Future<bool> swipeRight(String otherUID) async {
  var uniKey = Constants.checkUniversity();
  var myUID = firebaseAuth.currentUser.uid;
  var mydb = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uniKey == 0 ? 'UofT' : 'YorkU')
      .child(myUID)
      .child('matches');

  // add user to my match list
  await mydb.child(otherUID).set(otherUID);

  // checking if my id is available in that users match list
  var isMatched = await checkIfMatched(otherUID);
  return isMatched;
}

Future<List<PostUser>> fetchMatches() async {
  var uniKey = Constants.checkUniversity();
  var myUID = firebaseAuth.currentUser.uid;
  List<PostUser> matches = [];
  var mydb = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uniKey == 0 ? 'UofT' : 'YorkU')
      .child(myUID)
      .child('matches');

  DataSnapshot snap = await mydb.once();
  if (snap.value != null) {
    Map<dynamic, dynamic> values = snap.value;
    for (var key in values.keys) {
      var user = await getUser(key);
      var isMatched = await checkIfMatched(key);
      if (isMatched) {
        matches.add(user);
      }
    }
    return matches;
  } else {
    return matches;
  }
}

Future<bool> checkIfMatched(String uid) async {
  var uniKey = Constants.checkUniversity();
  var myUID = firebaseAuth.currentUser.uid;
  var db = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uniKey == 0 ? 'UofT' : 'YorkU')
      .child(uid)
      .child('matches')
      .child(myUID);
  DataSnapshot snap = await db.once();
  if (snap.value == null) {
    // not matched
    return false;
  } else {
    // matched
    return true;
  }
}
