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

Future<List<Comment>> fetchComments(
    Post post, c.Course course, Club club) async {
  List<Comment> c = List<Comment>();
  var uniKey = Constants.checkUniversity();
  var cDB = FirebaseDatabase.instance.reference().child('posts');
  var courseCDB = FirebaseDatabase.instance.reference().child('courseposts');
  var clubCDB = FirebaseDatabase.instance.reference().child('clubposts');
  var db = club == null && course == null
      ? cDB
          .child(uniKey == 0
              ? 'UofT'
              : uniKey == 1
                  ? 'YorkU'
                  : 'WesternU')
          .child(post.id)
          .child('comments')
      : club != null
          ? clubCDB
              .child(uniKey == 0
                  ? 'UofT'
                  : uniKey == 1
                      ? 'YorkU'
                      : 'WesternU')
              .child(club.id)
              .child(post.id)
              .child('comments')
          : courseCDB
              .child(uniKey == 0
                  ? 'UofT'
                  : uniKey == 1
                      ? 'YorkU'
                      : 'WesternU')
              .child(course.id)
              .child(post.id)
              .child('comments');

  // var db =
  //     FirebaseDatabase.instance.reference().child("comments").child(post.id);

  var snapshot = await db.once();

  Map<dynamic, dynamic> values = snapshot.value;

  if (snapshot.value != null) {
    values.forEach((key, value) {
      var comment = Comment(
          content: value['content'],
          username: value['username'],
          userId: value['userId'],
          timeStamp: value['timeStamp']);
      c.add(comment);
    });
    c.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
  }
  return c;
}

Future<bool> deleteComment(Post post, c.Course course, Club club) async {}

Future<bool> postComment(
    Comment comment, Post post, c.Course course, Club club) async {
  PostUser user = await getUser(firebaseAuth.currentUser.uid);
  var uniKey = Constants.checkUniversity();
  var cDB = FirebaseDatabase.instance.reference().child('posts');
  var courseCDB = FirebaseDatabase.instance.reference().child('courseposts');
  var clubCDB = FirebaseDatabase.instance.reference().child('clubposts');
  var db = club == null && course == null
      ? cDB
          .child(uniKey == 0
              ? 'UofT'
              : uniKey == 1
                  ? 'YorkU'
                  : 'WesternU')
          .child(post.id)
          .child('comments')
      : club != null
          ? clubCDB
              .child(uniKey == 0
                  ? 'UofT'
                  : uniKey == 1
                      ? 'YorkU'
                      : 'WesternU')
              .child(club.id)
              .child(post.id)
              .child('comments')
          : courseCDB
              .child(uniKey == 0
                  ? 'UofT'
                  : uniKey == 1
                      ? 'YorkU'
                      : 'WesternU')
              .child(course.id)
              .child(post.id)
              .child('comments');
  //var key = commentsDB.child(post.id).push();
  var key = db.push();
  final Map<String, dynamic> data = {
    "content": comment.content,
    "username": user.name,
    "userId": firebaseAuth.currentUser.uid,
    "timeStamp": DateTime.now().millisecondsSinceEpoch
  };

  await key.set(data).catchError((err) {
    return false;
  });

  return true;
}
