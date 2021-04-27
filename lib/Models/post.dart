import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/OHS.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/comment.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/user.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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
  Map<dynamic, dynamic> comments;
  String imgUrl;
  String questionOne;
  String questionTwo;
  int questionOneLikeCount;
  int questionTwoLikeCount;
  bool isLiked;
  Map<dynamic, dynamic> votes;
  bool isVoted;
  int whichOption;
  String tcQuestion;
  String university; // only used by OHS
  String type;
  String typeId;
  String title;
  String feeling;

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
      this.isLiked,
      this.votes,
      this.isVoted,
      this.whichOption,
      this.tcQuestion,
      this.university,
      this.type,
      this.typeId,
      this.title,
      this.feeling});
}

class Video {
  String id;
  String userId;
  String caption;
  String videoUrl;
  String thumbnailUrl;
  int commentCount;
  int likeCount;
  bool isLiked;
  String name;
  int timeStamp;
  bool allowComments;
  String university;

  Video(
      {this.id,
      this.userId,
      this.caption,
      this.videoUrl,
      this.thumbnailUrl,
      this.commentCount,
      this.likeCount,
      this.isLiked,
      this.name,
      this.timeStamp,
      this.allowComments,
      this.university});
}

FirebaseAuth firebaseAuth = FirebaseAuth.instance;

var postsDB = FirebaseDatabase.instance.reference().child('posts');
var videoDB = FirebaseDatabase.instance.reference().child('videos');

// var postDBrefUofT =
//     FirebaseDatabase.instance.reference().child('posts').child('UofT');
// var postDBrefYork =
//     FirebaseDatabase.instance.reference().child('posts').child('YorkU');
// var coursepostDBrefUofT =
//     FirebaseDatabase.instance.reference().child('courseposts').child('UofT');
// var coursepostDBrefYork =
//     FirebaseDatabase.instance.reference().child('courseposts').child('YorkU');
// var courseDBUofT =
//     FirebaseDatabase.instance.reference().child('courses').child('UofT');
// var courseDBYorkU =
//     FirebaseDatabase.instance.reference().child('courses').child('YorkU');

// var clubpostDBrefUofT =
//     FirebaseDatabase.instance.reference().child('clubposts').child('UofT');
// var clubpostDBrefYork =
//     FirebaseDatabase.instance.reference().child('clubposts').child('YorkU');
// var clubDBUofT =
//     FirebaseDatabase.instance.reference().child('clubs').child('UofT');
// var clubDBYorkU =
//     FirebaseDatabase.instance.reference().child('clubs').child('YorkU');

// 0 - University of Toronto | 1 - York University

Future<bool> createPost(Post post) async {
  PostUser user = await getUser(firebaseAuth.currentUser.uid);
  var uniKey = Constants.checkUniversity();

  var db = postsDB.child(uniKey == 0
      ? 'UofT'
      : uniKey == 1
          ? 'YorkU'
          : 'WesternU');
  var userDB = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU')
      .child(user.id)
      .child('myposts');
  var key = db.push();
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

  if (post.title != null) {
    data['title'] = post.title;
  }

  if (post.questionOne != null && post.questionTwo != null) {
    data['questionOne'] = post.questionOne;
    data['questionTwo'] = post.questionTwo;
    data['questionOneLikeCount'] = 0;
    data['questionTwoLikeCount'] = 0;
  }

  if (post.feeling != null) {
    data['feeling'] = post.feeling;
  }

  if (post.tcQuestion != null) {
    data['tcQuestion'] = post.tcQuestion;
  }

  await key.set(data);
  await userDB.child(key.key).set({'type': 'post'});
  DataSnapshot ds = await key.once();
  if (ds.value != null) {
    return true;
  } else {
    return false;
  }
}

Future<String> fetchQuestion() async {
  var db = FirebaseDatabase.instance.reference().child("question");
  var snapshot = await db.once().catchError((onError) {});
  return snapshot.value;
}

Future<Post> fetchPost(String postId) async {
  var uniKey = Constants.checkUniversity();
  var db =
      FirebaseDatabase.instance.reference().child("posts").child(uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU');
  var snapshot = await db.child(postId).once().catchError((e) {
    return null;
  });

  Map<dynamic, dynamic> value = snapshot.value;

  if (value == null) {
    return null;
  }
  var post = Post(
      id: postId,
      userId: value['userId'],
      username: value['name'],
      content: value['content'],
      timeStamp: value['timeStamp'],
      isAnonymous: value['isAnonymous'] != null ? value['isAnonymous'] : false,
      courseId: value['courseId'],
      likeCount: value['likes'] != null ? value['likes'].length : 0,
      imgUrl: value['imgUrl']);

  if (value['comments'] != null) {
    post.commentCount = value['comments'].length;
  } else {
    post.commentCount = 0;
  }

  if (value['title'] != null) {
    post.title = value['title'];
  }

  if (value['feeling'] != null) {
    post.feeling = value['feeling'];
  }

  if (value['questionOne'] != null && value['questionTwo'] != null) {
    if (value['votes'] != null) {
      List<int> voteCounts = getVotes(value['votes']);
      post.questionOneLikeCount = voteCounts[0];
      post.questionTwoLikeCount = voteCounts[1];
    } else {
      post.questionOneLikeCount = 0;
      post.questionTwoLikeCount = 0;
    }
    post.questionOne = value['questionOne'];
    post.questionTwo = value['questionTwo'];
  }

  if (value['votes'] != null) {
    var voted = checkIsVoted(value['votes']);
    post.votes = value['votes'];
    post.isVoted = voted;
    if (voted) {
      int option = whichOption(value['votes']);
      if (option != 0) {
        post.whichOption = option;
      }
    }
  } else {
    post.isVoted = false;
  }

  if (value['likes'] != null) {
    var liked = checkIsLiked(value['likes']);
    post.isLiked = liked;
  } else {
    post.isLiked = false;
  }

  if (value['tcQuestion'] != null) {
    post.tcQuestion = value['tcQuestion'];
  }

  return post;
}

Future<Post> fetchCoursePost(String postId, String id) async {
  var uniKey = Constants.checkUniversity();
  var db = FirebaseDatabase.instance
      .reference()
      .child("courseposts")
      .child(uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU');
  var snapshot = await db.child(id).child(postId).once().catchError((e) {
    return null;
  });

  Map<dynamic, dynamic> value = snapshot.value;

  if (value == null) {
    return null;
  }
  var post = Post(
      id: postId,
      userId: value['userId'],
      username: value['name'],
      content: value['content'],
      timeStamp: value['timeStamp'],
      isAnonymous: value['isAnonymous'] != null ? value['isAnonymous'] : false,
      courseId: value['courseId'],
      likeCount: value['likes'] != null ? value['likes'].length : 0,
      imgUrl: value['imgUrl']);

  if (value['comments'] != null) {
    post.commentCount = value['comments'].length;
  } else {
    post.commentCount = 0;
  }

  if (value['title'] != null) {
    post.title = value['title'];
  }

  if (value['feeling'] != null) {
    post.feeling = value['feeling'];
  }

  if (value['questionOne'] != null && value['questionTwo'] != null) {
    if (value['votes'] != null) {
      List<int> voteCounts = getVotes(value['votes']);
      post.questionOneLikeCount = voteCounts[0];
      post.questionTwoLikeCount = voteCounts[1];
    } else {
      post.questionOneLikeCount = 0;
      post.questionTwoLikeCount = 0;
    }
    post.questionOne = value['questionOne'];
    post.questionTwo = value['questionTwo'];
  }

  if (value['votes'] != null) {
    var voted = checkIsVoted(value['votes']);
    post.votes = value['votes'];
    post.isVoted = voted;
    if (voted) {
      int option = whichOption(value['votes']);
      if (option != 0) {
        post.whichOption = option;
      }
    }
  } else {
    post.isVoted = false;
  }

  if (value['likes'] != null) {
    var liked = checkIsLiked(value['likes']);
    post.isLiked = liked;
  } else {
    post.isLiked = false;
  }

  if (value['tcQuestion'] != null) {
    post.tcQuestion = value['tcQuestion'];
  }

  return post;
}

Future<Post> fetchClubPost(String postId, String id) async {
  var uniKey = Constants.checkUniversity();
  var db =
      FirebaseDatabase.instance.reference().child("clubposts").child(uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU');
  var snapshot = await db.child(id).child(postId).once().catchError((e) {
    return null;
  });

  Map<dynamic, dynamic> value = snapshot.value;

  if (value == null) {
    return null;
  }
  var post = Post(
      id: postId,
      userId: value['userId'],
      username: value['name'],
      content: value['content'],
      timeStamp: value['timeStamp'],
      isAnonymous: value['isAnonymous'] != null ? value['isAnonymous'] : false,
      courseId: value['courseId'],
      likeCount: value['likes'] != null ? value['likes'].length : 0,
      imgUrl: value['imgUrl']);

  if (value['comments'] != null) {
    post.commentCount = value['comments'].length;
  } else {
    post.commentCount = 0;
  }

  if (value['title'] != null) {
    post.title = value['title'];
  }

  if (value['feeling'] != null) {
    post.feeling = value['feeling'];
  }

  if (value['questionOne'] != null && value['questionTwo'] != null) {
    if (value['votes'] != null) {
      List<int> voteCounts = getVotes(value['votes']);
      post.questionOneLikeCount = voteCounts[0];
      post.questionTwoLikeCount = voteCounts[1];
    } else {
      post.questionOneLikeCount = 0;
      post.questionTwoLikeCount = 0;
    }
    post.questionOne = value['questionOne'];
    post.questionTwo = value['questionTwo'];
  }

  if (value['votes'] != null) {
    var voted = checkIsVoted(value['votes']);
    post.votes = value['votes'];
    post.isVoted = voted;
    if (voted) {
      int option = whichOption(value['votes']);
      if (option != 0) {
        post.whichOption = option;
      }
    }
  } else {
    post.isVoted = false;
  }

  if (value['likes'] != null) {
    var liked = checkIsLiked(value['likes']);
    post.isLiked = liked;
  } else {
    post.isLiked = false;
  }

  if (value['tcQuestion'] != null) {
    post.tcQuestion = value['tcQuestion'];
  }

  return post;
}

Future<List<Post>> fetchUserPost(PostUser user) async {
  var uni = user.university;
  print(uni);
  List<Post> p = [];
  var db = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uni)
      .child(user.id)
      .child('myposts');
  var snapshot = await db.once();

  Map<dynamic, dynamic> values = snapshot.value;

  if (values != null) {
    for (var key in values.keys) {
      var postId = key;
      var type = values[key]['type'];
      var typeId = values[key]['id'];

      print(type);

      switch (type) {
        case 'post':
          Post post = await fetchPost(postId);
          if (post != null) {
            if (post.isAnonymous == false ||
                post.userId == firebaseAuth.currentUser.uid) {
              post.type = 'post';
              p.add(post);
            }
          }
          break;
        case 'club':
          Post post = await fetchClubPost(postId, typeId);
          if (post != null) {
            if (post.isAnonymous == false ||
                post.userId == firebaseAuth.currentUser.uid) {
              post.type = 'club';
              post.typeId = typeId;
              p.add(post);
            }
          }
          break;
        case 'course':
          Post post = await fetchCoursePost(postId, typeId);
          if (post != null) {
            if (post.isAnonymous == false ||
                post.userId == firebaseAuth.currentUser.uid) {
              post.type = 'course';
              post.typeId = typeId;
              p.add(post);
            }
          }
          break;
        case 'onehealingspace':
          print('getting post');
          Post post = await OneHealingSpace.fetchPost(postId);
          print(post);
          if (post != null) {
            if (post.isAnonymous == false ||
                post.userId == firebaseAuth.currentUser.uid) {
              post.type = 'onehealingspace';
              p.add(post);
            }
          }
          break;
        default:
          break;
      }
    }
    p.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
  }

  return p;
}

Future<List<Post>> fetchPosts(int sortBy,
    {String lastPostID = '', int lastPostTimeStamp = 0}) async {
  var uniKeys = [
    Constants.checkUniversity() == 0
        ? 'UofT'
        : Constants.checkUniversity() == 1
            ? 'YorkU'
            : 'WesternU'
  ];
  List<Post> p = List<Post>();
  var blockList = await getBlocks();
  var hiddenList = await getHiddenList();

  for (var uniKey in uniKeys) {
    print(uniKey);
    var db = FirebaseDatabase.instance.reference().child("posts").child(uniKey);
    var snapshot;

    if (lastPostID == '' && lastPostTimeStamp == 0) {
      snapshot = await db.orderByChild('timeStamp').limitToLast(10).once();
    } else {
      print("LIMITING");
      snapshot = await db
          .orderByChild('timeStamp')
          .endAt(lastPostTimeStamp, key: lastPostID)
          .limitToLast(10)
          .once();
    }

    Map<dynamic, dynamic> values = snapshot.value;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var filters = prefs.getStringList('filters');

    if (values != null) {
      print(values);
      values.forEach((key, value) {
        var post = Post(
            id: key,
            userId: value['userId'],
            username: value['name'],
            content: value['content'],
            timeStamp: value['timeStamp'],
            isAnonymous:
                value['isAnonymous'] != null ? value['isAnonymous'] : false,
            courseId: value['courseId'],
            likeCount: value['likes'] != null ? value['likes'].length : 0,
            imgUrl: value['imgUrl'],
            university: uniKey);

        if (value['comments'] != null) {
          post.commentCount = value['comments'].length;
        } else {
          post.commentCount = 0;
        }

        if (value['title'] != null) {
          post.title = value['title'];
        }

        if (value['feeling'] != null) {
          post.feeling = value['feeling'];
        }

        if (value['questionOne'] != null && value['questionTwo'] != null) {
          if (value['votes'] != null) {
            List<int> voteCounts = getVotes(value['votes']);
            post.questionOneLikeCount = voteCounts[0];
            post.questionTwoLikeCount = voteCounts[1];
          } else {
            post.questionOneLikeCount = 0;
            post.questionTwoLikeCount = 0;
          }
          post.questionOne = value['questionOne'];
          post.questionTwo = value['questionTwo'];
        }

        if (value['votes'] != null) {
          var voted = checkIsVoted(value['votes']);
          post.votes = value['votes'];
          post.isVoted = voted;
          if (voted) {
            int option = whichOption(value['votes']);
            if (option != 0) {
              post.whichOption = option;
            }
          }
        } else {
          post.isVoted = false;
        }

        if (value['likes'] != null) {
          var liked = checkIsLiked(value['likes']);
          post.isLiked = liked;
        } else {
          post.isLiked = false;
        }

        if (value['tcQuestion'] != null) {
          post.tcQuestion = value['tcQuestion'];
        }

        var i = 0;

        if (post.userId != firebaseAuth.currentUser.uid) {
          if (filters != null) {
            for (var filter in filters) {
              if (post.content.toLowerCase().contains(filter.toLowerCase())) {
                i += 1;
              }
            }
          }
        }

        if (i == 0 &&
            blockList.containsKey(post.userId) == false &&
            hiddenList.contains(post.id) == false) {
          p.add(post);
        }
      });
    }
  }

  if (sortBy == 0) {
    p.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
  } else if (sortBy == 1) {
    p.sort((a, b) => (b.userId == firebaseAuth.currentUser.uid)
        .toString()
        .compareTo((a.userId == firebaseAuth.currentUser.uid).toString()));
  } else if (sortBy == 2) {
    p.sort((a, b) => (b.questionOne != null)
        .toString()
        .compareTo((a.questionOne != null).toString()));
  } else {
    p.sort((a, b) => (b.tcQuestion != null)
        .toString()
        .compareTo((a.tcQuestion != null).toString()));
  }
  return p;
}

List<int> getVotes(Map<dynamic, dynamic> votes) {
  int questionOneLikeCount = 0;
  int questionTwoLikeCount = 0;
  for (var value in votes.values) {
    if (value == 1) {
      questionOneLikeCount += 1;
    } else {
      questionTwoLikeCount += 1;
    }
  }
  return [questionOneLikeCount, questionTwoLikeCount];
}

int whichOption(Map<dynamic, dynamic> votes) {
  int val = 0;
  for (var value in votes.keys) {
    if (value == firebaseAuth.currentUser.uid) {
      val = votes[value];
    }
  }
  return val;
}

bool checkIsLiked(Map<dynamic, dynamic> likes) {
  for (var value in likes.values) {
    if (value == firebaseAuth.currentUser.uid) {
      return true;
    }
  }
  return false;
}

bool checkIsVoted(Map<dynamic, dynamic> votes) {
  for (var value in votes.keys) {
    if (value == firebaseAuth.currentUser.uid) {
      return true;
    }
  }
  return false;
}

Future<bool> createCoursePost(Post post, Course course) async {
  PostUser user = await getUser(firebaseAuth.currentUser.uid);
  var uniKey = Constants.checkUniversity();
  var coursePostDB = FirebaseDatabase.instance
      .reference()
      .child('courseposts')
      .child(uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU');
  var courseDB =
      FirebaseDatabase.instance.reference().child('courses').child(uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU');
  var key = coursePostDB.child(course.id).push();

  var userDB = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU')
      .child(user.id)
      .child('myposts');

  final Map<String, dynamic> data = {
    "userId": firebaseAuth.currentUser.uid,
    "name": user.name,
    "content": post.content,
    "timeStamp": DateTime.now().millisecondsSinceEpoch,
    "isAnonymous": post.isAnonymous,
    "courseId": post.courseId,
    "commentCount": 0,
    "imgUrl": post.imgUrl,
  };

  if (post.title != null) {
    data['title'] = post.title;
  }

  if (post.feeling != null) {
    data['feeling'] = post.feeling;
  }

  if (post.questionOne != null && post.questionTwo != null) {
    data['questionOne'] = post.questionOne;
    data['questionTwo'] = post.questionTwo;
    data['questionOneLikeCount'] = 0;
    data['questionTwoLikeCount'] = 0;
  }

  if (post.tcQuestion != null) {
    data['tcQuestion'] = post.tcQuestion;
  }

  await key.set(data);

  await userDB.child(key.key).set({'type': 'course', 'id': course.id});

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

Future<bool> createClubPost(Post post, Club club) async {
  PostUser user = await getUser(firebaseAuth.currentUser.uid);
  var uniKey = Constants.checkUniversity();
  var clubPostDB =
      FirebaseDatabase.instance.reference().child('clubposts').child(uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU');
  var clubDB =
      FirebaseDatabase.instance.reference().child('clubs').child(uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU');
  var key = clubPostDB.child(club.id).push();

  var userDB = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU')
      .child(user.id)
      .child('myposts');

  final Map<String, dynamic> data = {
    "userId": firebaseAuth.currentUser.uid,
    "name": user.name,
    "content": post.content,
    "timeStamp": DateTime.now().millisecondsSinceEpoch,
    "isAnonymous": post.isAnonymous,
    "courseId": post.courseId,
    "commentCount": 0,
    "imgUrl": post.imgUrl
  };

  if (post.title != null) {
    data['title'] = post.title;
  }

  if (post.feeling != null) {
    data['feeling'] = post.feeling;
  }

  if (post.questionOne != null && post.questionTwo != null) {
    data['questionOne'] = post.questionOne;
    data['questionTwo'] = post.questionTwo;
    data['questionOneLikeCount'] = 0;
    data['questionTwoLikeCount'] = 0;
  }

  if (post.tcQuestion != null) {
    data['tcQuestion'] = post.tcQuestion;
  }

  await key.set(data);

  await userDB.child(key.key).set({'type': 'club', 'id': club.id});

  DataSnapshot snap;

  snap = await clubDB.child(club.id).child("postCount").once();

  var countValue = snap.value + 1;

  final Map<String, dynamic> postCount = {
    "postCount": countValue,
  };

  await clubDB.child(club.id).update(postCount);

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

void previewMessage(String msg, BuildContext context) {
  Toast.show(msg, context, duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
}

Future<bool> imageApproved(File file) async {
  try {
    var headers = {'api-key': 'e23ce550-b3cd-4e91-85c4-9cbc49c4dce4'};
    var url = "https://api.deepai.org/api/nsfw-detector";
    var uri = Uri.parse(url);
    var request = new http.MultipartRequest("POST", uri);
    request.headers.addAll(headers);

    var multipartFile =
        await http.MultipartFile.fromPath("image", file.path.toString());
    request.files.add(multipartFile);

    http.Response response =
        await http.Response.fromStream(await request.send());
    var res = json.decode(response.body);
    var nsfw_score = res['output']['nsfw_score'];
    var confidence = res['output']['detections'][0]['confidence'];

    if (nsfw_score < 0.75 && confidence > 0.80) {
      return true;
    } else {
      return false;
    }
  } catch (err) {
    return true;
  }
}

Future<String> uploadImageToStorage(File file) async {
  String urlString;
  try {
    final DateTime now = DateTime.now();
    final int millSeconds = now.millisecondsSinceEpoch;
    final String month = now.month.toString();
    final String date = now.day.toString();
    final String storageId = (millSeconds.toString());
    final String today = ('$month-$date');

    FirebaseStorage storage = FirebaseStorage.instance;

    Reference ref = storage.ref().child('files').child(today).child(storageId);
    UploadTask uploadTask = ref.putFile(file);
    await uploadTask.then((res) async {
      await res.ref.getDownloadURL().then((value) {
        urlString = value;
      });
    });

    // StorageReference ref = FirebaseStorage.instance
    //     .ref()
    //     .child("files")
    //     .child(today)
    //     .child(storageId);
    // StorageUploadTask uploadTask = ref.putFile(file);

    // var snapShot = await uploadTask.onComplete;

    // var url = await snapShot.ref.getDownloadURL();
    // var urlString = url.toString();

    return urlString;
  } catch (error) {
    return "error";
  }
}

Future<List> getImageString() async {
  var urlString;
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

    FirebaseStorage storage = FirebaseStorage.instance;

    Reference ref = storage.ref().child('files').child(today).child(storageId);
    UploadTask uploadTask = ref.putFile(File(f.path));
    await uploadTask.then((res) async {
      await res.ref.getDownloadURL().then((value) {
        urlString = value;
      });
    });

    // StorageReference ref = FirebaseStorage.instance
    //     .ref()
    //     .child("files")
    //     .child(today)
    //     .child(storageId);
    // var file = File(f.path);
    // StorageUploadTask uploadTask = ref.putFile(file);

    // var snapShot = await uploadTask.onComplete;

    // var url = await snapShot.ref.getDownloadURL();

    List lst = [urlString, image];

    return lst;
  } catch (error) {
    return [];
  }
}

Future<bool> deletePost(String postId, Course course, Club club) async {
  var uniKey = Constants.checkUniversity();
  var myDB = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU')
      .child('myposts')
      .child(postId);
  var postdb = FirebaseDatabase.instance
      .reference()
      .child('posts')
      .child(uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU')
      .child(postId);
  var coursedb = course != null
      ? FirebaseDatabase.instance
          .reference()
          .child('courseposts')
          .child(uniKey == 0
              ? 'UofT'
              : uniKey == 1
                  ? 'YorkU'
                  : 'WesternU')
          .child(course.id)
          .child(postId)
      : null;
  var clubdb = club != null
      ? FirebaseDatabase.instance
          .reference()
          .child('clubposts')
          .child(uniKey == 0
              ? 'UofT'
              : uniKey == 1
                  ? 'YorkU'
                  : 'WesternU')
          .child(club.id)
          .child(postId)
      : null;
  // var db = FirebaseDatabase.instance
  //     .reference()
  //     .child(course == null && club == null
  //         ? 'posts'
  //         : course == null
  //             ? 'clubposts'
  //             : 'courseposts')
  //     .child(uniKey == 0 ? 'UofT' : 'YorkU')
  //     .child(postId);
  // await db.remove().catchError((err) {
  //   return false;
  // });
  course == null && club == null
      ? await postdb.remove().catchError((onError) {
          return false;
        })
      : course == null
          ? await clubdb.remove().catchError((onError) {
              return false;
            })
          : await coursedb.remove().catchError((onError) {
              return false;
            });

  await myDB.remove().catchError((e) {
    return false;
  });
  return true;
}

Future<List<Post>> fetchCoursePosts(Course course, int sortBy) async {
  var uniKey = Constants.checkUniversity();
  List<Post> p = List<Post>();
  var db = FirebaseDatabase.instance
      .reference()
      .child("courseposts")
      .child(uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU')
      .child(course.id);

  var snapshot = await db.once();
  var blockList = await getBlocks();
  var hiddenList = await getHiddenList();

  Map<dynamic, dynamic> values = snapshot.value;

  SharedPreferences prefs = await SharedPreferences.getInstance();
  var filters = prefs.getStringList('filters');

  values.forEach((key, value) {
    var post = Post(
        id: key,
        userId: value['userId'],
        username: value['name'],
        content: value['content'],
        timeStamp: value['timeStamp'],
        isAnonymous:
            value['isAnonymous'] != null ? value['isAnonymous'] : false,
        courseId: value['courseId'],
        likeCount: value['likes'] != null ? value['likes'].length : 0,
        imgUrl: value['imgUrl']);

    if (value['comments'] != null) {
      post.commentCount = value['comments'].length;
    } else {
      post.commentCount = 0;
    }

    if (value['title'] != null) {
      post.title = value['title'];
    }

    if (value['questionOne'] != null && value['questionTwo'] != null) {
      if (value['votes'] != null) {
        List<int> voteCounts = getVotes(value['votes']);
        post.questionOneLikeCount = voteCounts[0];
        post.questionTwoLikeCount = voteCounts[1];
      } else {
        post.questionOneLikeCount = 0;
        post.questionTwoLikeCount = 0;
      }
      post.questionOne = value['questionOne'];
      post.questionTwo = value['questionTwo'];
    }

    if (value['votes'] != null) {
      var voted = checkIsVoted(value['votes']);
      post.votes = value['votes'];
      post.isVoted = voted;
      if (voted) {
        int option = whichOption(value['votes']);
        if (option != 0) {
          post.whichOption = option;
        }
      }
    } else {
      post.isVoted = false;
    }

    if (value['likes'] != null) {
      var liked = checkIsLiked(value['likes']);
      post.isLiked = liked;
    } else {
      post.isLiked = false;
    }

    if (value['tcQuestion'] != null) {
      post.tcQuestion = value['tcQuestion'];
    }

    var i = 0;

    if (filters != null) {
      if (post.userId != firebaseAuth.currentUser.uid) {
        for (var filter in filters) {
          if (post.content.toLowerCase().contains(filter.toLowerCase())) {
            i += 1;
          }
        }
      }
    }

    if (i == 0 &&
        blockList.containsKey(post.userId) == false &&
        hiddenList.contains(post.id) == false) {
      p.add(post);
    }
  });
  if (sortBy == 0) {
    p.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
  } else if (sortBy == 1) {
    p.sort((a, b) => (b.userId == firebaseAuth.currentUser.uid)
        .toString()
        .compareTo((a.userId == firebaseAuth.currentUser.uid).toString()));
  } else if (sortBy == 2) {
    p.sort((a, b) => (b.questionOne != null)
        .toString()
        .compareTo((a.questionOne != null).toString()));
  } else {
    p.sort((a, b) => (b.tcQuestion != null)
        .toString()
        .compareTo((a.tcQuestion != null).toString()));
  }
  return p;
}

Future<List<String>> getHiddenList() async {
  var uniKey = Constants.checkUniversity();
  var uid = firebaseAuth.currentUser.uid;
  var db = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU')
      .child(uid)
      .child('hiddenposts');
  var snapshot = await db.once();

  List<String> hiddenList = [];

  if (snapshot.value != null) {
    Map<dynamic, dynamic> values = snapshot.value;

    for (var key in values.keys) {
      hiddenList.add(key);
    }
  }

  return hiddenList;
}

Future<bool> hidePost(String postId) async {
  var uniKey = Constants.checkUniversity();
  var uid = firebaseAuth.currentUser.uid;
  var db = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU')
      .child(uid)
      .child('hiddenposts')
      .child(postId);
  await db.set(postId).catchError((onError) {
    return false;
  });
  return true;
}

Future<bool> unhidePost(String postId) async {
  var uniKey = Constants.checkUniversity();
  var uid = firebaseAuth.currentUser.uid;
  var db = FirebaseDatabase.instance
      .reference()
      .child('users')
      .child(uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU')
      .child(uid)
      .child('hiddenposts')
      .child(postId);
  await db.remove().catchError((err) {
    return false;
  });
  return true;
}

Future<bool> like(Post post, Club club, Course course) async {
  var uniKey = Constants.checkUniversity();

  club == null && course == null
      ? await FirebaseDatabase.instance
          .reference()
          .child('posts')
          .child(uniKey == 0
              ? 'UofT'
              : uniKey == 1
                  ? 'YorkU'
                  : 'WesternU')
          .child(post.id)
          .child('likes')
          .child(firebaseAuth.currentUser.uid)
          .set(firebaseAuth.currentUser.uid)
          .catchError((err) {
          return false;
        })
      : club != null
          ? await FirebaseDatabase.instance
              .reference()
              .child('clubposts')
              .child(uniKey == 0
                  ? 'UofT'
                  : uniKey == 1
                      ? 'YorkU'
                      : 'WesternU')
              .child(club.id)
              .child(post.id)
              .child('likes')
              .child(firebaseAuth.currentUser.uid)
              .set(firebaseAuth.currentUser.uid)
              .catchError((err) {
              return false;
            })
          : await FirebaseDatabase.instance
              .reference()
              .child('courseposts')
              .child(uniKey == 0
                  ? 'UofT'
                  : uniKey == 1
                      ? 'YorkU'
                      : 'WesternU')
              .child(course.id)
              .child(post.id)
              .child('likes')
              .child(firebaseAuth.currentUser.uid)
              .set(firebaseAuth.currentUser.uid)
              .catchError((err) {
              return false;
            });
  return true;
}

Future<bool> vote(Post post, Club club, Course course, int option) async {
  var uniKey = Constants.checkUniversity();

  club == null && course == null
      ? await FirebaseDatabase.instance
          .reference()
          .child('posts')
          .child(uniKey == 0
              ? 'UofT'
              : uniKey == 1
                  ? 'YorkU'
                  : 'WesternU')
          .child(post.id)
          .child('votes')
          .child(firebaseAuth.currentUser.uid)
          .set(option)
          .catchError((err) {
          return false;
        })
      : club != null
          ? await FirebaseDatabase.instance
              .reference()
              .child('clubposts')
              .child(uniKey == 0
                  ? 'UofT'
                  : uniKey == 1
                      ? 'YorkU'
                      : 'WesternU')
              .child(club.id)
              .child(post.id)
              .child('votes')
              .child(firebaseAuth.currentUser.uid)
              .set(option)
              .catchError((err) {
              return false;
            })
          : await FirebaseDatabase.instance
              .reference()
              .child('courseposts')
              .child(uniKey == 0
                  ? 'UofT'
                  : uniKey == 1
                      ? 'YorkU'
                      : 'WesternU')
              .child(course.id)
              .child(post.id)
              .child('votes')
              .child(firebaseAuth.currentUser.uid)
              .set(option)
              .catchError((err) {
              return false;
            });
  return true;
}

Future<bool> unlike(Post post, Club club, Course course) async {
  var uniKey = Constants.checkUniversity();

  club == null && course == null
      ? await FirebaseDatabase.instance
          .reference()
          .child('posts')
          .child(uniKey == 0
              ? 'UofT'
              : uniKey == 1
                  ? 'YorkU'
                  : 'WesternU')
          .child(post.id)
          .child('likes')
          .child(firebaseAuth.currentUser.uid)
          .remove()
          .catchError((err) {
          return false;
        })
      : club != null
          ? await FirebaseDatabase.instance
              .reference()
              .child('clubposts')
              .child(uniKey == 0
                  ? 'UofT'
                  : uniKey == 1
                      ? 'YorkU'
                      : 'WesternU')
              .child(club.id)
              .child(post.id)
              .child('likes')
              .child(firebaseAuth.currentUser.uid)
              .remove()
              .catchError((err) {
              return false;
            })
          : await FirebaseDatabase.instance
              .reference()
              .child('courseposts')
              .child(uniKey == 0
                  ? 'UofT'
                  : uniKey == 1
                      ? 'YorkU'
                      : 'WesternU')
              .child(course.id)
              .child(post.id)
              .child('likes')
              .child(firebaseAuth.currentUser.uid)
              .remove()
              .catchError((err) {
              return false;
            });
  return true;
}

Future<List<Post>> fetchClubPosts(Club club, int sortBy) async {
  var uniKey = Constants.checkUniversity();
  List<Post> p = List<Post>();
  var db = FirebaseDatabase.instance
      .reference()
      .child("clubposts")
      .child(uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU')
      .child(club.id);

  var snapshot = await db.once();
  var blockList = await getBlocks();
  var hiddenList = await getHiddenList();

  Map<dynamic, dynamic> values = snapshot.value;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var filters = prefs.getStringList('filters');

  values.forEach((key, value) {
    var post = Post(
        id: key,
        userId: value['userId'],
        username: value['name'],
        content: value['content'],
        timeStamp: value['timeStamp'],
        isAnonymous:
            value['isAnonymous'] != null ? value['isAnonymous'] : false,
        courseId: value['courseId'],
        likeCount: value['likes'] != null ? value['likes'].length : 0,
        imgUrl: value['imgUrl']);

    if (value['comments'] != null) {
      post.commentCount = value['comments'].length;
    } else {
      post.commentCount = 0;
    }

    if (value['title'] != null) {
      post.title = value['title'];
    }

    if (value['questionOne'] != null && value['questionTwo'] != null) {
      if (value['votes'] != null) {
        List<int> voteCounts = getVotes(value['votes']);
        post.questionOneLikeCount = voteCounts[0];
        post.questionTwoLikeCount = voteCounts[1];
      } else {
        post.questionOneLikeCount = 0;
        post.questionTwoLikeCount = 0;
      }
      post.questionOne = value['questionOne'];
      post.questionTwo = value['questionTwo'];
    }

    if (value['votes'] != null) {
      var voted = checkIsVoted(value['votes']);
      post.votes = value['votes'];
      post.isVoted = voted;
      if (voted) {
        int option = whichOption(value['votes']);
        if (option != 0) {
          post.whichOption = option;
        }
      }
    } else {
      post.isVoted = false;
    }

    if (value['likes'] != null) {
      var liked = checkIsLiked(value['likes']);
      post.isLiked = liked;
    } else {
      post.isLiked = false;
    }

    if (value['tcQuestion'] != null) {
      post.tcQuestion = value['tcQuestion'];
    }

    var i = 0;

    if (filters != null) {
      if (post.userId != firebaseAuth.currentUser.uid) {
        for (var filter in filters) {
          if (post.content.toLowerCase().contains(filter.toLowerCase())) {
            i += 1;
          }
        }
      }
    }

    if (i == 0 &&
        blockList.containsKey(post.userId) == false &&
        hiddenList.contains(post.id) == false) {
      p.add(post);
    }
  });

  if (sortBy == 0) {
    p.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
  } else if (sortBy == 1) {
    p.sort((a, b) => (b.userId == firebaseAuth.currentUser.uid)
        .toString()
        .compareTo((a.userId == firebaseAuth.currentUser.uid).toString()));
  } else if (sortBy == 2) {
    p.sort((a, b) => (b.questionOne != null)
        .toString()
        .compareTo((a.questionOne != null).toString()));
  } else {
    p.sort((a, b) => (b.tcQuestion != null)
        .toString()
        .compareTo((a.tcQuestion != null).toString()));
  }
  return p;
}

Future<String> getPromoImage() async {
  var db = FirebaseDatabase.instance.reference().child('promoImageUrl');
  var snapshot = await db.once();
  if (snapshot.value != null) {
    return snapshot.value;
  } else {
    return '';
  }
}

// VIDEO API

class VideoApi {
  static Future<File> getVideo() async {
    final picker = ImagePicker();

    final f = await picker.getVideo(
        source: ImageSource.gallery, maxDuration: Duration(minutes: 4));
    File _file = File(f.path);
    return _file;
  }

  static Future<List<String>> uploadVideoToStorage(File file) async {
    String urlString;
    String thumbUrlString;
    try {
      var bytes = await VideoThumbnail.thumbnailData(
        video: file.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 0,
        quality: 100,
      );

      final DateTime now = DateTime.now();
      final int millSeconds = now.millisecondsSinceEpoch;
      final String month = now.month.toString();
      final String date = now.day.toString();
      final String storageId = (millSeconds.toString());
      final String today = ('$month-$date');

      FirebaseStorage storage = FirebaseStorage.instance;

      Reference ref =
          storage.ref().child('files').child(today).child(storageId);
      UploadTask uploadTask = ref.putFile(file);
      await uploadTask.then((res) async {
        await res.ref.getDownloadURL().then((value) {
          urlString = value;
        });
      });

      // StorageReference ref = FirebaseStorage.instance
      //     .ref()
      //     .child("files")
      //     .child(today)
      //     .child(storageId);
      // StorageUploadTask uploadTask = ref.putFile(file);

      // var snapShot = await uploadTask.onComplete;

      // var url = await snapShot.ref.getDownloadURL();
      // var urlString = url.toString();

      final DateTime now1 = DateTime.now();
      final int millSeconds1 = now1.millisecondsSinceEpoch;
      final String month1 = now1.month.toString();
      final String date1 = now1.day.toString();
      final String storageId1 = (millSeconds1.toString());
      final String today1 = ('$month1-$date1');

      FirebaseStorage s = FirebaseStorage.instance;

      Reference r = s.ref().child('files').child(today1).child(storageId1);
      UploadTask u = r.putData(bytes);
      await u.then((res) async {
        await res.ref.getDownloadURL().then((value) {
          thumbUrlString = value;
        });
      });

      // StorageReference r = FirebaseStorage.instance
      //     .ref()
      //     .child('files')
      //     .child(today1)
      //     .child(storageId1);
      // StorageUploadTask upTask = r.putData(bytes);

      // var snap = await upTask.onComplete;

      // var thumbUrl = await snap.ref.getDownloadURL();
      // var thumbUrlString = thumbUrl.toString();

      return [urlString, thumbUrlString];
    } catch (error) {
      return [];
    }
  }

  static Future<bool> createVideo(
      {File f, String caption, bool allowComments}) async {
    List<String> urls = await uploadVideoToStorage(f);

    if (urls.isEmpty) {
      return false;
    }

    var thumbUrl = urls[1];
    var vidUrl = urls[0];

    PostUser user = await getUser(firebaseAuth.currentUser.uid);
    var uniKey = Constants.checkUniversity();

    var db = videoDB;
    var userDB = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(uniKey == 0
            ? 'UofT'
            : uniKey == 1
                ? 'YorkU'
                : 'WesternU')
        .child(user.id)
        .child('myvideos');
    var key = db.push();
    final Map<String, dynamic> data = {
      "userId": firebaseAuth.currentUser.uid,
      "name": user.name,
      "videoUrl": vidUrl,
      "timeStamp": DateTime.now().millisecondsSinceEpoch,
      "thumbUrl": thumbUrl,
      "caption": caption,
      "allowComments": allowComments,
      "university": uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU'
    };
    await key.set(data);
    await userDB.child(key.key).set(true);
    DataSnapshot ds = await key.once();
    if (ds.value != null) {
      return true;
    } else {
      return false;
    }
  }

  static Future<List<Video>> fetchUserVideos(PostUser user) async {
    List<Video> videos = [];
    var db = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(user.university)
        .child(user.id)
        .child('myvideos');
    DataSnapshot snap = await db.once();
    Map<dynamic, dynamic> values = snap.value;

    if (snap.value != null) {
      for (var key in values.keys) {
        // key is video id
        Video video = await fetchVideo(key);
        if (video != null) {
          videos.add(video);
        }
      }
    }

    return videos;
  }

  static Future<bool> delete(String id) async {
    var uniKey = Constants.checkUniversity();
    var university = uniKey == 0
        ? 'UofT'
        : uniKey == 1
            ? 'YorkU'
            : 'WesternU';
    var uid = firebaseAuth.currentUser.uid;
    var db = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(university)
        .child(uid)
        .child('myvideos')
        .child(id);
    var videoDB =
        FirebaseDatabase.instance.reference().child('videos').child(id);
    await db.remove().then((value) async {
      await videoDB.remove().catchError((e) {
        return false;
      });
    }).catchError((e) {
      return false;
    });
    return true;
  }

  static Future<List<Video>> fetchMyVideos() async {
    List<Video> videos = [];
    var uniKey = Constants.checkUniversity();
    var university = uniKey == 0
        ? 'UofT'
        : uniKey == 1
            ? 'YorkU'
            : 'WesternU';
    var uid = firebaseAuth.currentUser.uid;
    var db = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(university)
        .child(uid)
        .child('myvideos');
    DataSnapshot snap = await db.once();
    Map<dynamic, dynamic> values = snap.value;

    if (snap.value != null) {
      for (var key in values.keys) {
        // key is video id
        Video video = await fetchVideo(key);
        if (video != null) {
          videos.add(video);
        }
      }
    }

    return videos;
  }

  static Future<Video> fetchVideo(String id) async {
    var db = FirebaseDatabase.instance.reference().child('videos');
    DataSnapshot snap = await db.once();
    Map<dynamic, dynamic> value = snap.value[id];

    if (snap.value == null) {
      return null;
    }

    Video video = Video(
        id: id,
        userId: value['userId'],
        name: value['name'],
        timeStamp: value['timeStamp'],
        videoUrl: value['videoUrl'],
        thumbnailUrl: value['thumbUrl'],
        caption: value['caption'],
        allowComments:
            value['allowComments'] != null ? value['allowComments'] : true,
        university: value['university']);

    if (value['likes'] != null) {
      video.likeCount = value['likes'].length;
      var liked = checkIsLiked(value['likes']);
      video.isLiked = liked;
    } else {
      video.likeCount = 0;
      video.isLiked = false;
    }

    if (value['comments'] != null) {
      video.commentCount = value['comments'].length;
    } else {
      video.commentCount = 0;
    }

    return video;
  }

  static Future<List<Video>> fetchVideos() async {
    Map<String, String> blockedUserIds = await getBlocks();
    List<Video> videos = [];
    var db = FirebaseDatabase.instance.reference().child('videos');
    DataSnapshot snap = await db.once();
    Map<dynamic, dynamic> values = snap.value;

    if (snap.value != null) {
      values.forEach((key, value) {
        if (blockedUserIds.containsKey(value['userId'])) {
        } else {
          Video video = Video(
              id: key,
              userId: value['userId'],
              name: value['name'],
              timeStamp: value['timeStamp'],
              videoUrl: value['videoUrl'],
              thumbnailUrl: value['thumbUrl'],
              caption: value['caption'],
              allowComments: value['allowComments'] != null
                  ? value['allowComments']
                  : true,
              university: value['university']);

          if (value['likes'] != null) {
            video.likeCount = value['likes'].length;
            var liked = checkIsLiked(value['likes']);
            video.isLiked = liked;
          } else {
            video.likeCount = 0;
            video.isLiked = false;
          }

          if (value['comments'] != null) {
            video.commentCount = value['comments'].length;
          } else {
            video.commentCount = 0;
          }

          videos.add(video);
        }
      });

      videos.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
    }

    return videos;
  }

  static Future<bool> like(Video video) async {
    var uniKey = Constants.checkUniversity();

    await FirebaseDatabase.instance
        .reference()
        .child('videos')
        .child(video.id)
        .child('likes')
        .child(firebaseAuth.currentUser.uid)
        .set(uniKey == 0
            ? 'UofT'
            : uniKey == 1
                ? 'YorkU'
                : 'WesternU')
        .catchError((err) {
      return false;
    });
    return true;
  }

  static Future<bool> unlike(Video video) async {
    await FirebaseDatabase.instance
        .reference()
        .child('videos')
        .child(video.id)
        .child('likes')
        .child(firebaseAuth.currentUser.uid)
        .remove()
        .catchError((err) {
      return false;
    });
    return true;
  }

  static bool checkIsLiked(Map<dynamic, dynamic> likes) {
    for (var value in likes.keys) {
      if (value == firebaseAuth.currentUser.uid) {
        return true;
      }
    }
    return false;
  }

  static Future<bool> postComment(String content, Video video) async {
    PostUser user = await getUser(firebaseAuth.currentUser.uid);
    var uniKey = Constants.checkUniversity();
    var videoDB = FirebaseDatabase.instance.reference().child('videos');
    var db = videoDB.child(video.id).child('comments');
    //var key = commentsDB.child(post.id).push();
    var key = db.push();
    final Map<String, dynamic> data = {
      "content": content,
      "username": user.name,
      "userId": firebaseAuth.currentUser.uid,
      "timeStamp": DateTime.now().millisecondsSinceEpoch,
      "university": uniKey == 0
          ? 'UofT'
          : uniKey == 1
              ? 'YorkU'
              : 'WesternU'
    };

    await key.set(data).catchError((err) {
      return false;
    });

    return true;
  }

  static Future<List<Comment>> fetchComments(Video video) async {
    List<Comment> c = List<Comment>();
    var cDB = FirebaseDatabase.instance.reference().child('videos');
    var db = cDB.child(video.id).child('comments');

    var snapshot = await db.once();

    Map<dynamic, dynamic> values = snapshot.value;

    if (snapshot.value != null) {
      values.forEach((key, value) {
        var comment = Comment(
            content: value['content'],
            username: value['username'],
            userId: value['userId'],
            timeStamp: value['timeStamp'],
            university: value['university']);
        c.add(comment);
      });
      c.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
    }
    return c;
  }
}

List<String> postContents = [
  "Hi, I am doing a minor in CS and it says on the academic calendar that I can take 1.5 credits of third and fourth year computer science courses. However, on almost every computer science course in third and fourth year, it says that CSC290 is a prerequisite for that particular course, but I can't take CSC290 right now because I don't have eligibility into the CS major/specialist program. Can someone give me clarification on this?",
  "Can we apply for another program anytime throughout the year or is it during summer only?",
  "I wanted to keep one course (fsc239-Y) but i think i'm gonna have to drop it, i feel really indecisive about what i want to do and i'd rather not end up with what i predict to be a horrible grade in this course. what happens if i drop this being my only course for the year?:(",
  "I am taking BIO207 in the woverpass term and was wondering if anyone had Williams and if she focuses on the lectures or the textbook readings. also if anyone has a list of the reading schedule she had from the summer and could send it to me that would be great!",
  "Heyo, has anyone worked for IEC before? If yes, could u tell me how was the experience? I am thinking about applying.",
  "Does anyone know what the independent research projects ( PSY40XH5) are and how to apply ?",
  "I wonder if there is any chance to nc one of the courses that I took in first year. (I’m in my second yr now) I was not informed about any of cr/ncr thing in my first semester. That’s why I couldn’t nc that course. That course mark is rlly affecting my gpa a lot (in a bad way ofc).",
  "Is anyone majoring in computer science and commerce ?? what is it like? is it a good idea?",
  "Guys I have a question, if I won’t pass post in CS is it possible to transfer to U of Waterloo? What kind of options do I have?",
  "anyone wanna be friends for csc207 next semester!!! :) :P :D",
  "is there any way we can set up some petition or file a complaint or something to the CS department to remove the autofail for this year. I know instructors are having a tough time with online delivery of classes but we students are also struggling as well. We're already in a bad situation because of covid, some of us may be struggling with finances, and sick family members. Putting this additional restriction on us makes it all the more difficult. You may tell us to take less courses next time or simply repeat a course but some of us can't afford to spend the time or money doing so, and that has been amplified by the state of the world right now.",
  "What are some easy courses that fulfill the writing requirement for the commerce program? I suck at writing so trynna find something easy",
  "Do u guys think campus will be closed completely with the new lockdown? I have in person lab courses :(",
  "hey! i’ll be taking 148 in the woverpass semester and i’ve been seeing many posts about how 148 isn’t easy and many people end up retaking it. could someone explain to me what exactly is difficult about the course and leave any advice? how similar is it to 108? Anything i should practice or learn to prepare? thanks (: side note: i just finished 108 and i did pretty good (although that exam dropped my grade like crazy but thankfully passed), i feel like i have a pretty good grasp on the fundamentals taught in 108. and found that the structure of the course was alright, i enjoyed PCRS (except for spatial skills, that killed me). i will admit though, test questions were definitely designed to trick you rather than test your knowledge.",
];

List<String> userIds = [
  "2ZEnF0ToxKM6LkHt4CC6v43yYyB3",
  "P7ATkYSxQiRdL7698piw35V9UFo1",
  "Q2ruHpyLAoMKxXR3raNDnZVdIBE2",
  "36OEYQ36WBenC7x2KieK3xazeRe2",
  "0dwafclC4sYdtvJTeK73Z8mvDvq2"
];

Future<Null> postDummies() async {
  for (var content in postContents) {
    Random rnd;
    int min = 0;
    int max = userIds.length - 1;
    rnd = new Random();
    int r = min + rnd.nextInt(max - min);
    PostUser user = await getUser(userIds[r]);
    var uniKey = Constants.checkUniversity();

    var db = postsDB.child(uniKey == 0
        ? 'UofT'
        : uniKey == 1
            ? 'YorkU'
            : 'WesternU');
    var userDB = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(uniKey == 0
            ? 'UofT'
            : uniKey == 1
                ? 'YorkU'
                : 'WesternU')
        .child(user.id)
        .child('myposts');
    var key = db.push();
    final Map<String, dynamic> data = {
      "userId": firebaseAuth.currentUser.uid,
      "name": user.name,
      "content": content,
      "timeStamp": DateTime.now().millisecondsSinceEpoch,
      "isAnonymous": true,
      "likeCount": 0,
      "commentCount": 0,
    };

    await key.set(data);
    await userDB.child(key.key).set({'type': 'post'});
    await Future.delayed(const Duration(minutes: 2), () {
      print('Posted');
    });
  }
}
