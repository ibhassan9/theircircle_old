import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/user.dart';

class Post {
  String id;
  String userId;
  String username;
  String content;
  int timeStamp;
  bool isAnonymous;
  String courseId;
  int likeCount;
  int commentCount;
  List comments;
  String imgUrl;
  String questionOne;
  String questionTwo;
  int questionOneLikeCount;
  int questionTwoLikeCount;
  bool isLiked;

  Post(
      {this.id,
      this.userId,
      this.username,
      this.content,
      this.timeStamp,
      this.isAnonymous,
      this.courseId,
      this.likeCount,
      this.commentCount,
      this.comments,
      this.imgUrl,
      this.questionOne,
      this.questionTwo,
      this.questionOneLikeCount,
      this.questionTwoLikeCount,
      this.isLiked});
}

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
var postDBrefUofT =
    FirebaseDatabase.instance.reference().child('posts').child('UofT');
var postDBrefYork =
    FirebaseDatabase.instance.reference().child('posts').child('YorkU');
var coursepostDBrefUofT =
    FirebaseDatabase.instance.reference().child('courseposts').child('UofT');
var coursepostDBrefYork =
    FirebaseDatabase.instance.reference().child('courseposts').child('YorkU');
var courseDBUofT =
    FirebaseDatabase.instance.reference().child('courses').child('UofT');
var courseDBYorkU =
    FirebaseDatabase.instance.reference().child('courses').child('YorkU');

// 0 - University of Toronto | 1 - York University

int checkUniversity() {
  var userEmail = firebaseAuth.currentUser.email;
  if (userEmail.contains('utoronto')) {
    return 0;
  } else {
    return 1;
  }
}

Future<bool> createPost(Post post) async {
  PostUser user = await getUser(firebaseAuth.currentUser.uid);
  var uniKey = checkUniversity();
  if (uniKey == 0) {
    var key = postDBrefUofT.push();
    final Map<String, dynamic> data = {
      "userId": firebaseAuth.currentUser.uid,
      "name": user.name,
      "content": post.content,
      "timeStamp": DateTime.now().millisecondsSinceEpoch,
      "isAnonymous": post.isAnonymous,
      "courseId": post.courseId,
      "likeCount": 0,
      "commentCount": 0,
      "imgUrl": post.imgUrl
    };

    await key.set(data);
    DataSnapshot ds = await key.once();
    if (ds.value != null) {
      return true;
    } else {
      return false;
    }
  } else {
    var key = postDBrefYork.push();
    final Map<String, dynamic> data = {
      "userId": firebaseAuth.currentUser.uid,
      "name": user.name,
      "content": post.content,
      "timeStamp": DateTime.now().millisecondsSinceEpoch,
      "isAnonymous": post.isAnonymous,
      "courseId": post.courseId,
      "likeCount": 0,
      "commentCount": 0,
      "imgUrl": post.imgUrl
    };

    //TODO:- Fix Push Random Key

    await key.set(data);
    DataSnapshot ds = await key.once();
    if (ds.value != null) {
      return true;
    } else {
      return false;
    }
  }
}

Future<List<Post>> fetchPosts() async {
  var uniKey = checkUniversity();
  List<Post> p = List<Post>();
  var db = uniKey == 0
      ? FirebaseDatabase.instance.reference().child("posts").child('UofT')
      : FirebaseDatabase.instance.reference().child("posts").child('YorkU');

  var snapshot = await db.once();

  Map<dynamic, dynamic> values = snapshot.value;

  values.forEach((key, value) {
    var post = Post(
        id: key,
        userId: value['userId'],
        username: value['name'],
        content: value['content'],
        timeStamp: value['timeStamp'],
        isAnonymous: value['isAnonymous'],
        courseId: value['courseId'],
        likeCount: value['likeCount'],
        commentCount: value['commentCount'],
        comments: value['comments'],
        imgUrl: value['imgUrl'],
        questionOne: value['questionOne'],
        questionTwo: value['questionTwo'],
        questionOneLikeCount: value['questionOneLikeCount'],
        questionTwoLikeCount: value['questionTwoLikeCount']);
    p.add(post);
  });
  p.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
  return p;
}

Future<bool> createCoursePost(Post post, Course course) async {
  PostUser user = await getUser(firebaseAuth.currentUser.uid);
  var uniKey = checkUniversity();
  var coursePostDB = uniKey == 0 ? coursepostDBrefUofT : coursepostDBrefYork;
  var courseDB = uniKey == 0 ? courseDBUofT : courseDBYorkU;
  var key = coursePostDB.child(course.id).push();

  final Map<String, dynamic> data = {
    "userId": firebaseAuth.currentUser.uid,
    "name": user.name,
    "content": post.content,
    "timeStamp": DateTime.now().millisecondsSinceEpoch,
    "isAnonymous": post.isAnonymous,
    "courseId": post.courseId,
    "likeCount": 0,
    "commentCount": 0,
    "imgUrl": post.imgUrl
  };

  await key.set(data);

  DataSnapshot snap;

  snap = await courseDB.child(course.id).child("postCount").once();

  var countValue = snap.value + 1;

  final Map<String, dynamic> postCount = {
    "postCount": countValue,
  };

  await courseDB.child(course.id).update(postCount);

  DataSnapshot ds = await key.once();
  if (ds.value != null) {
    return true;
  } else {
    return false;
  }
}

Future<List> getImage() async {
  final picker = ImagePicker();

  final f =
      await picker.getImage(source: ImageSource.gallery, imageQuality: 50);
  var image = Image.file(File(f.path));
  List lst = [image, File(f.path)];
  return lst;
}

Future<String> uploadImageToStorage(File file) async {
  try {
    final DateTime now = DateTime.now();
    final int millSeconds = now.millisecondsSinceEpoch;
    final String month = now.month.toString();
    final String date = now.day.toString();
    final String storageId = (millSeconds.toString());
    final String today = ('$month-$date');

    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child("files")
        .child(today)
        .child(storageId);
    StorageUploadTask uploadTask = ref.putFile(file);

    var snapShot = await uploadTask.onComplete;

    var url = await snapShot.ref.getDownloadURL();
    var urlString = url.toString();

    return urlString;
  } catch (error) {
    return "error";
  }
}

Future<List> getImageString() async {
  try {
    final DateTime now = DateTime.now();
    final int millSeconds = now.millisecondsSinceEpoch;
    final String month = now.month.toString();
    final String date = now.day.toString();
    final String storageId = (millSeconds.toString());
    final String today = ('$month-$date');

    final picker = ImagePicker();

    final f = await picker.getImage(source: ImageSource.gallery);
    var image = Image.file(File(f.path));

    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child("files")
        .child(today)
        .child(storageId);
    var file = File(f.path);
    StorageUploadTask uploadTask = ref.putFile(file);

    var snapShot = await uploadTask.onComplete;

    var url = await snapShot.ref.getDownloadURL();

    List lst = [url, image];

    return lst;
  } catch (error) {
    return [];
  }
}

Future<List<Post>> fetchCoursePosts(Course course) async {
  var uniKey = checkUniversity();
  List<Post> p = List<Post>();
  var db = uniKey == 0
      ? FirebaseDatabase.instance
          .reference()
          .child("courseposts")
          .child('UofT')
          .child(course.id)
      : FirebaseDatabase.instance
          .reference()
          .child("courseposts")
          .child('YorkU')
          .child(course.id);

  var snapshot = await db.once();

  Map<dynamic, dynamic> values = snapshot.value;

  values.forEach((key, value) {
    var post = Post(
        id: key,
        userId: value['userId'],
        username: value['name'],
        content: value['content'],
        timeStamp: value['timeStamp'],
        isAnonymous: value['isAnonymous'],
        courseId: value['courseId'],
        likeCount: value['likeCount'],
        commentCount: value['commentCount'],
        comments: value['comments'],
        imgUrl: value['imgUrl'],
        questionOne: value['questionOne'],
        questionTwo: value['questionTwo'],
        questionOneLikeCount: value['questionOneLikeCount'],
        questionTwoLikeCount: value['questionTwoLikeCount']);
    p.add(post);
  });
  p.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
  return p;
}
