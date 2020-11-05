import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/comment.dart';
import 'package:unify/pages/course_page.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/notification.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/pages/post_detail_page.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/WebPage.dart';
import 'package:url_launcher/url_launcher.dart';

class PostWidget extends StatefulWidget {
  final Post post;
  final String timeAgo;
  final Course course;
  final Club club;
  final Function deletePost;
  final Function block;
  final Function hide;

  PostWidget(
      {Key key,
      @required this.post,
      this.timeAgo,
      this.course,
      this.club,
      this.deletePost,
      this.block,
      this.hide})
      : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isLiked = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  TextEditingController bioC = TextEditingController();
  TextEditingController sC = TextEditingController();
  TextEditingController igC = TextEditingController();
  TextEditingController lC = TextEditingController();
  String imgUrl = '';
  Comment comment;

  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PostDetailPage(
                    post: widget.post,
                    course: widget.course,
                    club: widget.club)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      child: Row(children: [
                    InkWell(
                      onTap: () async {
                        var user = await getUser(widget.post.userId);
                        if (widget.post.userId != fAuth.currentUser.uid) {
                          if (widget.post.isAnonymous == false) {
                            showProfile(
                                user, context, bioC, sC, igC, lC, null, null);
                          }
                        } else {
                          showProfile(
                              user, context, bioC, sC, igC, lC, null, null);
                        }
                      },
                      child: widget.post.isAnonymous
                          ? CircleAvatar(
                              child: Icon(AntDesign.ellipsis1,
                                  color: Colors.white),
                              backgroundColor: Colors.purple)
                          : imgUrl == null || imgUrl == ''
                              ? CircleAvatar(
                                  backgroundColor: Colors.purple,
                                  child: Text(
                                      widget.post.username.substring(0, 1),
                                      style: TextStyle(color: Colors.white)))
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.network(
                                    imgUrl,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            valueColor:
                                                new AlwaysStoppedAnimation<
                                                        Color>(
                                                    Colors.grey.shade600),
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                    ),
                    SizedBox(width: 10.0),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.userId == firebaseAuth.currentUser.uid
                                ? "YOU"
                                : widget.post.isAnonymous
                                    ? "Anonymous"
                                    : widget.post.username,
                            style: GoogleFonts.quicksand(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: widget.post.userId ==
                                        firebaseAuth.currentUser.uid
                                    ? Colors.purple
                                    : Colors.black),
                          ),
                          SizedBox(height: 2.5),
                          Text(
                            "${widget.timeAgo}",
                            style: GoogleFonts.quicksand(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey),
                          ),
                        ])
                  ])),
                  InkWell(
                    onTap: () {
                      final act = CupertinoActionSheet(
                        title: Text(
                          widget.post.userId == firebaseAuth.currentUser.uid
                              ? "OPTIONS"
                              : "REPORT",
                          style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                        message: Text(
                          widget.post.userId == firebaseAuth.currentUser.uid
                              ? "What would you like to do?"
                              : "What is the issue?",
                          style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                        actions: widget.post.userId ==
                                firebaseAuth.currentUser.uid
                            ? [
                                CupertinoActionSheetAction(
                                    child: Text(
                                      "Delete Post",
                                      style: GoogleFonts.quicksand(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                    ),
                                    onPressed: () {
                                      final act = CupertinoActionSheet(
                                          title: Text(
                                            'Delete Post',
                                            style: GoogleFonts.quicksand(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black),
                                          ),
                                          message: Text(
                                            'Are you sure you want to delete this post?',
                                            style: GoogleFonts.quicksand(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black),
                                          ),
                                          actions: [
                                            CupertinoActionSheetAction(
                                                child: Text(
                                                  "YES",
                                                  style: GoogleFonts.quicksand(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black),
                                                ),
                                                onPressed: () {
                                                  widget.deletePost();
                                                  Navigator.pop(context);
                                                }),
                                            CupertinoActionSheetAction(
                                                child: Text(
                                                  "Cancel",
                                                  style: GoogleFonts.quicksand(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.red),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                }),
                                          ]);
                                      showCupertinoModalPopup(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              act);
                                    }),
                                CupertinoActionSheetAction(
                                    child: Text(
                                      "Cancel",
                                      style: GoogleFonts.quicksand(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                              ]
                            : [
                                CupertinoActionSheetAction(
                                    child: Text(
                                      "It's suspicious or spam",
                                      style: GoogleFonts.quicksand(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      showSnackBar();
                                    }),
                                CupertinoActionSheetAction(
                                    child: Text(
                                      "It's abusive or harmful",
                                      style: GoogleFonts.quicksand(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      showSnackBar();
                                    }),
                                CupertinoActionSheetAction(
                                    child: Text(
                                      "It expresses intentions of self-harm or suicide",
                                      style: GoogleFonts.quicksand(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      showSnackBar();
                                    }),
                                CupertinoActionSheetAction(
                                    child: Text(
                                      "It promotes sexual/inappropriate content",
                                      style: GoogleFonts.quicksand(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      showSnackBar();
                                    }),
                                CupertinoActionSheetAction(
                                    child: Text(
                                      "Hide this post.",
                                      style: GoogleFonts.quicksand(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      final act = CupertinoActionSheet(
                                        title: Text(
                                          "PROCEED?",
                                          style: GoogleFonts.quicksand(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black),
                                        ),
                                        message: Text(
                                          "Are you sure you want to hide this post?",
                                          style: GoogleFonts.quicksand(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black),
                                        ),
                                        actions: [
                                          CupertinoActionSheetAction(
                                              child: Text(
                                                "YES",
                                                style: GoogleFonts.quicksand(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black),
                                              ),
                                              onPressed: () async {
                                                await widget.hide();
                                              }),
                                          CupertinoActionSheetAction(
                                              child: Text(
                                                "Cancel",
                                                style: GoogleFonts.quicksand(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.red),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              }),
                                        ],
                                      );
                                      showCupertinoModalPopup(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              act);
                                    }),
                                CupertinoActionSheetAction(
                                    child: Text(
                                      "Block this user",
                                      style: GoogleFonts.quicksand(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      final act = CupertinoActionSheet(
                                        title: Text(
                                          "PROCEED?",
                                          style: GoogleFonts.quicksand(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black),
                                        ),
                                        message: Text(
                                          "Are you sure you want to block this user?",
                                          style: GoogleFonts.quicksand(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black),
                                        ),
                                        actions: [
                                          CupertinoActionSheetAction(
                                              child: Text(
                                                "YES",
                                                style: GoogleFonts.quicksand(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black),
                                              ),
                                              onPressed: () async {
                                                await widget.block();
                                              }),
                                          CupertinoActionSheetAction(
                                              child: Text(
                                                "Cancel",
                                                style: GoogleFonts.quicksand(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.red),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              }),
                                        ],
                                      );
                                      showCupertinoModalPopup(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              act);
                                    }),
                                CupertinoActionSheetAction(
                                    child: Text(
                                      "Cancel",
                                      style: GoogleFonts.quicksand(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                              ],
                      );
                      showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) => act);
                    },
                    child:
                        Icon(FlutterIcons.more_horiz_mdi, color: Colors.black),
                  ),
                ],
              ),
            ),
            Wrap(children: [_postContent()]),
            Container(
              height: 10.0,
              width: MediaQuery.of(context).size.width,
              color: Colors.blueGrey.shade50,
            )
          ],
        ),
      ),
    );
  }

  Widget _postContent() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(left: 10.0, right: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // ends here
              Container(
                  margin: EdgeInsets.only(top: 5.0),
                  child: SelectableLinkify(
                    onOpen: (link) async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WebPage(
                                  title: link.text, selectedUrl: link.url)));
                    },
                    text: widget.post.content,
                    style: GoogleFonts.quicksand(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                    linkStyle: TextStyle(color: Colors.red),
                  )),
              widget.post.imgUrl != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          color: Colors.grey.shade300,
                          child: FullScreenWidget(
                            backgroundColor: Colors.brown,
                            child: Center(
                              child: Hero(
                                tag: widget.post.id,
                                child: Image.network(
                                  widget.post.imgUrl,
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height / 2,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return SizedBox(
                                      height: 200,
                                      width: MediaQuery.of(context).size.width,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  Colors.grey.shade600),
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(),
              SizedBox(height: 7.5),
              Divider(),
              SizedBox(height: 7.5),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        InkWell(
                            onTap: () async {
                              if (widget.post.isLiked) {
                                widget.post.isLiked = false;
                                widget.post.likeCount -= 1;
                                var res = await unlike(
                                    widget.post, widget.club, widget.course);
                                if (res) {
                                  if (this.mounted) {
                                    setState(() {});
                                  }
                                }
                              } else {
                                var user = await getUser(widget.post.userId);
                                var token = user.device_token;
                                if (user.id != firebaseAuth.currentUser.uid) {
                                  if (widget.club == null &&
                                      widget.course == null) {
                                    await sendPush(
                                        0, token, widget.post.content);
                                  } else if (widget.club != null) {
                                    await sendPushClub(widget.club, 0, token,
                                        widget.post.content);
                                  } else {
                                    await sendPushCourse(widget.course, 0,
                                        token, widget.post.content);
                                  }
                                }
                                widget.post.isLiked = true;
                                widget.post.likeCount += 1;
                                var res = await like(
                                    widget.post, widget.club, widget.course);
                                if (res) {
                                  if (this.mounted) {
                                    setState(() {});
                                  }
                                }
                              }
                            },
                            child: Icon(FlutterIcons.like_sli,
                                color: widget.post.isLiked
                                    ? Colors.red
                                    : Colors.grey,
                                size: 20)),
                        SizedBox(width: 10.0),
                        Container(
                          margin: EdgeInsets.only(left: 3.0),
                          child: Text(
                            widget.post.likeCount == 0
                                ? "No Likes"
                                : widget.post.likeCount == 1
                                    ? widget.post.likeCount.toString() + " Like"
                                    : widget.post.likeCount.toString() +
                                        " Likes",
                            style: GoogleFonts.quicksand(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey),
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Icon(AntDesign.message1,
                            color: Colors.grey.shade400, size: 20),
                        SizedBox(width: 10.0),
                        Container(
                          margin: EdgeInsets.only(left: 3.0),
                          child: Text(
                            widget.post.commentCount == 0
                                ? "No Comments"
                                : widget.post.commentCount == 1
                                    ? widget.post.commentCount.toString() +
                                        " Comment"
                                    : widget.post.commentCount.toString() +
                                        " Comments",
                            style: GoogleFonts.quicksand(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey),
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Icon(AntDesign.sharealt,
                            color: Colors.grey.shade400, size: 20),
                        SizedBox(width: 10.0),
                        Container(
                          margin: EdgeInsets.only(left: 3.0),
                          child: Text(
                            "Share",
                            style: GoogleFonts.quicksand(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15.0),
              comment != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        comment.userId == firebaseAuth.currentUser.uid
                            ? "YOU"
                            : comment.username,
                        style: GoogleFonts.quicksand(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.purple),
                      ),
                    )
                  : SizedBox(),
              comment != null
                  ? Container(
                      height: 50.0,
                      child: Row(
                        children: [
                          SizedBox(width: 20.0),
                          Container(
                            height: 20.0,
                            width: 3.0,
                            color: Colors.purple,
                          ),
                          SizedBox(width: 10.0),
                          Text(comment.content,
                              style: GoogleFonts.quicksand(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black))
                        ],
                      ),
                    )
                  : SizedBox()
            ],
          ),
        ),
      ],
    );
  }

  Future<PostUser> user() async {
    return await getUser(widget.post.userId);
  }

  showSnackBar() {
    final snackBar = SnackBar(
        content: Text('Your report has been received.',
            style: GoogleFonts.quicksand(
              textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            )));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser(widget.post.userId).then((value) {
      imgUrl = value.profileImgUrl;
      fetchComments(widget.post, widget.course, widget.club).then((value) {
        if (value.length > 0 && value != null) {
          Comment c = value.last;
          if (this.mounted) {
            setState(() {
              comment = c;
            });
          }
        }
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    bioC.dispose();
    sC.dispose();
    igC.dispose();
    lC.dispose();
  }
}
