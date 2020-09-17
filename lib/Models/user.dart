import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:unify/Home/main_screen.dart';

class PostUser {
  String id;
  String email;
  String name;

  PostUser({this.id, this.email, this.name});
}

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
DatabaseReference usersDBref =
    FirebaseDatabase.instance.reference().child('users');

Future signInUser(String email, String password, BuildContext context) async {
  await firebaseAuth
      .signInWithEmailAndPassword(email: email, password: password)
      .then((result) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => MainScreen()));
  });
}

Future registerUser(
    String name, String email, String password, BuildContext context) async {
  await firebaseAuth
      .createUserWithEmailAndPassword(email: email, password: password)
      .then((result) {
    usersDBref
        .child(result.user.uid)
        .set({"email": email, "name": name}).then((res) async {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text('done'),
              actions: [
                FlatButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });
  }).catchError((err) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text('error'),
            actions: [
              FlatButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  });
}

Future<PostUser> getUser(String id) async {
  var userDB = FirebaseDatabase.instance.reference().child('users').child(id);
  var snapshot = await userDB.once();
  Map<dynamic, dynamic> value = snapshot.value;
  return PostUser(id: id, name: value['name'], email: value['email']);
}
