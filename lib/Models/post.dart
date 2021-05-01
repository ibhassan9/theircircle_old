import 'dart:convert';
import 'dart:io';

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
import 'package:unify/pages/DB.dart';
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

Future<bool> createPost(Post post) async {
  PostUser user = await getUser(FIR_UID);

  var db = POSTS_DB.child(Constants.uniString(uniKey));
  var userDB = USERS_DB
      .child(Constants.uniString(uniKey))
      .child(user.id)
      .child('myposts');
  var key = db.push();
  final Map<String, dynamic> data = {
    "userId": FIR_UID,
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
  var db = POSTS_DB.child(Constants.uniString(uniKey));
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
  var db = COURSE_POSTS_DB.child(Constants.uniString(uniKey));
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
  var db = CLUB_POSTS_DB.child(Constants.uniString(uniKey));
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
  var db = USERS_DB.child(uni).child(user.id).child('myposts');
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
            if (post.isAnonymous == false || post.userId == FIR_UID) {
              post.type = 'post';
              p.add(post);
            }
          }
          break;
        case 'club':
          Post post = await fetchClubPost(postId, typeId);
          if (post != null) {
            if (post.isAnonymous == false || post.userId == FIR_UID) {
              post.type = 'club';
              post.typeId = typeId;
              p.add(post);
            }
          }
          break;
        case 'course':
          Post post = await fetchCoursePost(postId, typeId);
          if (post != null) {
            if (post.isAnonymous == false || post.userId == FIR_UID) {
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
            if (post.isAnonymous == false || post.userId == FIR_UID) {
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
  List<Post> p = [];
  var blockList = await getBlocks();
  var hiddenList = await getHiddenList();

  for (var uniKey in uniKeys) {
    print(uniKey);
    var db = POSTS_DB.child(uniKey);
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

        if (post.userId != FIR_UID) {
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
    p.sort((a, b) => (b.userId == FIR_UID)
        .toString()
        .compareTo((a.userId == FIR_UID).toString()));
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
    if (value == FIR_UID) {
      val = votes[value];
    }
  }
  return val;
}

bool checkIsLiked(Map<dynamic, dynamic> likes) {
  for (var value in likes.values) {
    if (value == FIR_UID) {
      return true;
    }
  }
  return false;
}

bool checkIsVoted(Map<dynamic, dynamic> votes) {
  for (var value in votes.keys) {
    if (value == FIR_UID) {
      return true;
    }
  }
  return false;
}

Future<bool> createCoursePost(Post post, Course course) async {
  PostUser user = await getUser(FIR_UID);
  var coursePostDB = COURSE_POSTS_DB.child(Constants.uniString(uniKey));
  var courseDB = COURSES_DB.child(Constants.uniString(uniKey));
  var key = coursePostDB.child(course.id).push();

  var userDB = USERS_DB
      .child(Constants.uniString(uniKey))
      .child(user.id)
      .child('myposts');

  final Map<String, dynamic> data = {
    "userId": FIR_UID,
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
  PostUser user = await getUser(FIR_UID);
  var clubPostDB = CLUB_POSTS_DB.child(Constants.uniString(uniKey));
  var clubDB = CLUBS_DB.child(Constants.uniString(uniKey));
  var key = clubPostDB.child(club.id).push();

  var userDB = USERS_DB
      .child(Constants.uniString(uniKey))
      .child(user.id)
      .child('myposts');

  final Map<String, dynamic> data = {
    "userId": FIR_UID,
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
    var nsfwScore = res['output']['nsfw_score'];
    var confidence = res['output']['detections'][0]['confidence'];

    if (nsfwScore < 0.75 && confidence > 0.80) {
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

    List lst = [urlString, image];

    return lst;
  } catch (error) {
    return [];
  }
}

Future<bool> deletePost(String postId, Course course, Club club) async {
  var myDB = USERS_DB
      .child(Constants.uniString(uniKey))
      .child('myposts')
      .child(postId);
  var postdb = POSTS_DB.child(Constants.uniString(uniKey)).child(postId);
  var coursedb = course != null
      ? COURSE_POSTS_DB
          .child(Constants.uniString(uniKey))
          .child(course.id)
          .child(postId)
      : null;
  var clubdb = club != null
      ? CLUB_POSTS_DB
          .child(Constants.uniString(uniKey))
          .child(club.id)
          .child(postId)
      : null;

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
  List<Post> p = [];
  var db = COURSE_POSTS_DB.child(Constants.uniString(uniKey)).child(course.id);

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
      if (post.userId != FIR_UID) {
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
    p.sort((a, b) => (b.userId == FIR_UID)
        .toString()
        .compareTo((a.userId == FIR_UID).toString()));
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
  var db = USERS_DB
      .child(Constants.uniString(uniKey))
      .child(FIR_UID)
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
  var db = USERS_DB
      .child(Constants.uniString(uniKey))
      .child(FIR_UID)
      .child('hiddenposts')
      .child(postId);
  await db.set(postId).catchError((onError) {
    return false;
  });
  return true;
}

Future<bool> unhidePost(String postId) async {
  var db = USERS_DB
      .child(Constants.uniString(uniKey))
      .child(FIR_UID)
      .child('hiddenposts')
      .child(postId);
  await db.remove().catchError((err) {
    return false;
  });
  return true;
}

Future<bool> like(Post post, Club club, Course course) async {
  club == null && course == null
      ? await POSTS_DB
          .child(Constants.uniString(uniKey))
          .child(post.id)
          .child('likes')
          .child(FIR_UID)
          .set(FIR_UID)
          .catchError((err) {
          return false;
        })
      : club != null
          ? await CLUB_POSTS_DB
              .child(Constants.uniString(uniKey))
              .child(club.id)
              .child(post.id)
              .child('likes')
              .child(FIR_UID)
              .set(FIR_UID)
              .catchError((err) {
              return false;
            })
          : await COURSE_POSTS_DB
              .child(Constants.uniString(uniKey))
              .child(course.id)
              .child(post.id)
              .child('likes')
              .child(FIR_UID)
              .set(FIR_UID)
              .catchError((err) {
              return false;
            });
  return true;
}

Future<bool> vote(Post post, Club club, Course course, int option) async {
  club == null && course == null
      ? await POSTS_DB
          .child(Constants.uniString(uniKey))
          .child(post.id)
          .child('votes')
          .child(FIR_UID)
          .set(option)
          .catchError((err) {
          return false;
        })
      : club != null
          ? await CLUB_POSTS_DB
              .child(Constants.uniString(uniKey))
              .child(club.id)
              .child(post.id)
              .child('votes')
              .child(FIR_UID)
              .set(option)
              .catchError((err) {
              return false;
            })
          : await COURSE_POSTS_DB
              .child(Constants.uniString(uniKey))
              .child(course.id)
              .child(post.id)
              .child('votes')
              .child(FIR_UID)
              .set(option)
              .catchError((err) {
              return false;
            });
  return true;
}

Future<bool> unlike(Post post, Club club, Course course) async {
  club == null && course == null
      ? await POSTS_DB
          .child(Constants.uniString(uniKey))
          .child(post.id)
          .child('likes')
          .child(FIR_UID)
          .remove()
          .catchError((err) {
          return false;
        })
      : club != null
          ? await CLUB_POSTS_DB
              .child(Constants.uniString(uniKey))
              .child(club.id)
              .child(post.id)
              .child('likes')
              .child(FIR_UID)
              .remove()
              .catchError((err) {
              return false;
            })
          : await COURSE_POSTS_DB
              .child(Constants.uniString(uniKey))
              .child(course.id)
              .child(post.id)
              .child('likes')
              .child(FIR_UID)
              .remove()
              .catchError((err) {
              return false;
            });
  return true;
}

Future<List<Post>> fetchClubPosts(Club club, int sortBy) async {
  List<Post> p = [];
  var db = CLUB_POSTS_DB.child(Constants.uniString(uniKey)).child(club.id);

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
      if (post.userId != FIR_UID) {
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
    p.sort((a, b) => (b.userId == FIR_UID)
        .toString()
        .compareTo((a.userId == FIR_UID).toString()));
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
  var snapshot = await PROMO_DB.once();
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

    PostUser user = await getUser(FIR_UID);

    var userDB = FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(Constants.uniString(uniKey))
        .child(user.id)
        .child('myvideos');
    var key = VIDEOS_DB.push();
    final Map<String, dynamic> data = {
      "userId": FIR_UID,
      "name": user.name,
      "videoUrl": vidUrl,
      "timeStamp": DateTime.now().millisecondsSinceEpoch,
      "thumbUrl": thumbUrl,
      "caption": caption,
      "allowComments": allowComments,
      "university": Constants.uniString(uniKey)
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
    var db = USERS_DB.child(user.university).child(user.id).child('myvideos');
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
    var university = Constants.uniString(uniKey);

    var db =
        USERS_DB.child(university).child(FIR_UID).child('myvideos').child(id);
    var videoDB = VIDEOS_DB.child(id);
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
    var university = Constants.uniString(uniKey);

    var db = USERS_DB.child(university).child(FIR_UID).child('myvideos');
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
    DataSnapshot snap = await VIDEOS_DB.once();
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
    DataSnapshot snap = await VIDEOS_DB.once();
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
    await VIDEOS_DB
        .child(video.id)
        .child('likes')
        .child(FIR_UID)
        .set(Constants.uniString(uniKey))
        .catchError((err) {
      return false;
    });
    return true;
  }

  static Future<bool> unlike(Video video) async {
    await VIDEOS_DB
        .child(video.id)
        .child('likes')
        .child(FIR_UID)
        .remove()
        .catchError((err) {
      return false;
    });
    return true;
  }

  static bool checkIsLiked(Map<dynamic, dynamic> likes) {
    for (var value in likes.keys) {
      if (value == FIR_UID) {
        return true;
      }
    }
    return false;
  }

  static Future<bool> postComment(String content, Video video) async {
    PostUser user = await getUser(FIR_UID);
    var db = VIDEOS_DB.child(video.id).child('comments');
    //var key = commentsDB.child(post.id).push();
    var key = db.push();
    final Map<String, dynamic> data = {
      "content": content,
      "username": user.name,
      "userId": FIR_UID,
      "timeStamp": DateTime.now().millisecondsSinceEpoch,
      "university": Constants.uniString(uniKey)
    };

    await key.set(data).catchError((err) {
      return false;
    });

    return true;
  }

  static Future<List<Comment>> fetchComments(Video video) async {
    List<Comment> c = [];
    var db = VIDEOS_DB.child(video.id).child('comments');

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
