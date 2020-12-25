import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/OHS.dart';
import 'package:unify/Widgets/CommentWidget.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/comment.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/notification.dart';
import 'package:unify/Models/post.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:unify/Models/user.dart';
import 'package:unify/pages/OHS%20Pages/OHSPostWidget.dart';
import 'package:unify/widgets/CommentPostWidget.dart';
import 'package:unify/widgets/PostWidget.dart';

class OHSPostDetail extends StatefulWidget {
  final Post post;
  final Club club;
  final String timeAgo;

  OHSPostDetail({Key key, this.post, this.club, this.timeAgo})
      : super(key: key);
  @override
  _OHSPostDetailState createState() => _OHSPostDetailState();
}

class _OHSPostDetailState extends State<OHSPostDetail> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  TextEditingController commentController = TextEditingController();
  Future<List<Comment>> commentFuture;
  bool isCommenting = false;

  @override
  Widget build(BuildContext context) {
    @override
    void dispose() {
      super.dispose();
      commentController.dispose();
    }

    Padding commentBox = Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            border:
                Border(top: BorderSide(color: Theme.of(context).dividerColor))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                  child: TextField(
                maxLines: null,
                textInputAction: TextInputAction.done,
                controller: commentController,
                decoration: new InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                        left: 15, bottom: 11, top: 11, right: 15),
                    hintText: "Comment Here"),
                style: GoogleFonts.questrial(
                  textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor),
                ),
              )),
              IconButton(
                icon: Icon(
                  AntDesign.arrowright,
                  color: Theme.of(context).accentColor,
                ),
                onPressed: () async {
                  if (commentController.text.isEmpty || isCommenting) {
                    return;
                  }
                  setState(() {
                    isCommenting = true;
                  });
                  Comment comment = Comment(content: commentController.text);
                  var res =
                      await OneHealingSpace.postComment(comment, widget.post);
                  if (res) {
                    //TODO:- send push notification
                    // var user = await getUser(widget.post.userId);
                    // var token = user.device_token;
                    // if (user.id != firebaseAuth.currentUser.uid) {
                    //   if (widget.club == null && widget.course == null) {
                    //     await sendPush(
                    //         1, token, comment.content, widget.post.id);
                    //   } else if (widget.club != null) {
                    //     await sendPushClub(widget.club, 1, token,
                    //         comment.content, widget.post.id);
                    //   } else {
                    //     await sendPushCourse(widget.course, 1, token,
                    //         comment.content, widget.post.id);
                    //   }
                    // }
                    commentController.clear();
                  } else {}
                  if (this.mounted) {
                    setState(() {
                      commentFuture =
                          OneHealingSpace.fetchComments(widget.post);
                    });
                  }
                  setState(() {
                    isCommenting = false;
                  });
                },
              )
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          "COMMENTS",
          style: GoogleFonts.questrial(
            textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).accentColor),
          ),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Theme.of(context).accentColor),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: Stack(
          children: <Widget>[
            ListView(
              children: <Widget>[
                OHSPostWidget(
                    hide: () async {
                      var res = await hidePost(widget.post.id);
                      Navigator.pop(context);
                      if (res) {
                        previewMessage("Post hidden from feed.", context);
                      }
                    },
                    block: () async {
                      var res = await block(
                          widget.post.userId, widget.post.university);
                      Navigator.pop(context);
                      if (res) {
                        previewMessage("User blocked.", context);
                      }
                    },
                    deletePost: () async {
                      var res =
                          await OneHealingSpace.deletePost(widget.post.id);
                      Navigator.pop(context);
                      if (res) {
                        previewMessage("Post Deleted", context);
                      } else {
                        previewMessage("Error deleting post!", context);
                      }
                    },
                    fromComments: true,
                    post: widget.post,
                    club: widget.club,
                    timeAgo: widget.timeAgo),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: FutureBuilder(
                    future: commentFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount:
                              snapshot.data != null ? snapshot.data.length : 0,
                          itemBuilder: (BuildContext context, int index) {
                            Comment comment = snapshot.data[index];
                            var timeAgo =
                                new DateTime.fromMillisecondsSinceEpoch(
                                    comment.timeStamp);
                            return CommentWidget(
                                comment: comment,
                                timeAgo: timeago.format(timeAgo));
                          },
                        );
                      } else {
                        return Container(
                          height: MediaQuery.of(context).size.height / 1.4,
                          child: Center(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.face,
                                  color: Theme.of(context).accentColor,
                                ),
                                SizedBox(width: 10),
                                Text("There are no comments :(",
                                    style: GoogleFonts.questrial(
                                      textStyle: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).accentColor),
                                    )),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
          child: commentBox),
    );
  }

  Future<Null> refresh() async {
    this.setState(() {
      commentFuture = OneHealingSpace.fetchComments(widget.post);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    commentFuture = OneHealingSpace.fetchComments(widget.post);
  }
}
