import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart' as c;
import 'package:unify/Models/post.dart';
import 'package:unify/Models/user.dart';

class Comment {
  String content;
  String username;
  String userId;
  int timeStamp;

  Comment({this.content, this.username, this.userId, this.timeStamp});
}

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
var commentsDB = FirebaseDatabase.instance.reference().child('comments');
var postDBUofT =
    FirebaseDatabase.instance.reference().child('posts').child('UofT');
var postDBYorkU =
    FirebaseDatabase.instance.reference().child('posts').child('YorkU');
var coursepostDBUofT =
    FirebaseDatabase.instance.reference().child('courseposts').child('UofT');
var coursepostDBYorkU =
    FirebaseDatabase.instance.reference().child('courseposts').child('YorkU');
var clubpostDBUofT =
    FirebaseDatabase.instance.reference().child('clubposts').child('UofT');
var clubpostDBYorkU =
    FirebaseDatabase.instance.reference().child('clubposts').child('YorkU');

Future<List<Comment>> fetchComments(Post post) async {
  List<Comment> c = List<Comment>();
  var db =
      FirebaseDatabase.instance.reference().child("comments").child(post.id);

  var snapshot = await db.once();

  Map<dynamic, dynamic> values = snapshot.value;

  values.forEach((key, value) {
    var comment = Comment(
        content: value['content'],
        username: value['username'],
        userId: value['userId'],
        timeStamp: value['timeStamp']);
    c.add(comment);
  });
  c.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
  return c;
}

Future<bool> postComment(
    Comment comment, Post post, c.Course course, Club club) async {
  PostUser user = await getUser(firebaseAuth.currentUser.uid);
  var uniKey = Constants.checkUniversity();
  var key = commentsDB.child(post.id).push();
  final Map<String, dynamic> data = {
    "content": comment.content,
    "username": user.name,
    "userId": firebaseAuth.currentUser.uid,
    "timeStamp": DateTime.now().millisecondsSinceEpoch
  };

  await key.set(data);
  DataSnapshot snap;

  club != null
      ? uniKey == 0
          ? snap = await clubpostDBUofT
              .child(club.id)
              .child(post.id)
              .child("commentCount")
              .once()
          : snap = await clubpostDBYorkU
              .child(club.id)
              .child(post.id)
              .child("commentCount")
              .once()
      : course != null
          ? uniKey == 0
              ? snap = await coursepostDBUofT
                  .child(course.id)
                  .child(post.id)
                  .child("commentCount")
                  .once()
              : snap = await coursepostDBYorkU
                  .child(course.id)
                  .child(post.id)
                  .child("commentCount")
                  .once()
          : uniKey == 0
              ? snap =
                  await postDBUofT.child(post.id).child("commentCount").once()
              : snap =
                  await postDBYorkU.child(post.id).child("commentCount").once();

  var countValue = snap.value + 1;

  final Map<String, dynamic> commentCount = {
    "commentCount": countValue,
  };

  club != null
      ? uniKey == 0
          ? await clubpostDBUofT
              .child(club.id)
              .child(post.id)
              .update(commentCount)
          : await clubpostDBYorkU
              .child(club.id)
              .child(post.id)
              .update(commentCount)
      : course != null
          ? uniKey == 0
              ? await coursepostDBUofT
                  .child(course.id)
                  .child(post.id)
                  .update(commentCount)
              : await coursepostDBYorkU
                  .child(course.id)
                  .child(post.id)
                  .update(commentCount)
          : uniKey == 0
              ? await postDBUofT.child(post.id).update(commentCount)
              : await postDBYorkU.child(post.id).update(commentCount);

  DataSnapshot ds = await key.once();
  if (ds.value != null) {
    return true;
  } else {
    return false;
  }
}
