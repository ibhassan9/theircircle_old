import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart' as c;
import 'package:unify/Models/post.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/DB.dart';

class Comment {
  String content;
  String username;
  String userId;
  int timeStamp;
  String university;
  Map<dynamic, dynamic> tags;

  Comment(
      {this.content,
      this.username,
      this.userId,
      this.timeStamp,
      this.university,
      this.tags});
}

Future<List<Comment>> fetchComments(
    Post post, c.Course course, Club club, String uni) async {
  List<Comment> c = [];
  var db = club == null && course == null
      ? POSTS_DB.child(uni).child(post.id).child('comments')
      : club != null
          ? CLUB_POSTS_DB
              .child(Constants.uniString(uniKey))
              .child(club.id)
              .child(post.id)
              .child('comments')
          : COURSE_POSTS_DB
              .child(Constants.uniString(uniKey))
              .child(course.id)
              .child(post.id)
              .child('comments');

  var snapshot = await db.once();

  Map<dynamic, dynamic> values = snapshot.value;

  if (snapshot.value != null) {
    values.forEach((key, value) {
      var comment = Comment(
          content: value['content'],
          username: value['username'],
          userId: value['userId'],
          timeStamp: value['timeStamp']);
      if (value['tags'] != null) {
        comment.tags = value['tags'];
      }
      c.add(comment);
    });
    c.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
  }
  return c;
}

Future<Null> deleteComment(Post post, c.Course course, Club club) async {}

Future<bool> postComment(Comment comment, Post post, c.Course course, Club club,
    Map<String, dynamic> tags) async {
  PostUser user = await getUser(FIR_UID);
  var db = club == null && course == null
      ? POSTS_DB
          .child(Constants.uniString(uniKey))
          .child(post.id)
          .child('comments')
      : club != null
          ? CLUB_POSTS_DB
              .child(Constants.uniString(uniKey))
              .child(club.id)
              .child(post.id)
              .child('comments')
          : COURSE_POSTS_DB
              .child(Constants.uniString(uniKey))
              .child(course.id)
              .child(post.id)
              .child('comments');
  var key = db.push();
  final Map<String, dynamic> data = {
    "content": comment.content,
    "username": user.name,
    "userId": FIR_UID,
    "timeStamp": DateTime.now().millisecondsSinceEpoch,
  };

  if (tags != null) {
    data["tags"] = tags;
  }

  await key.set(data).catchError((err) {
    return false;
  });

  return true;
}
