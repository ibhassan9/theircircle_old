import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share/share.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/comment.dart';
import 'package:unify/pages/MyProfilePage.dart';
import 'package:unify/pages/PollResultsPage.dart';
import 'package:unify/pages/ProfilePage.dart';
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
  final bool fromComments;

  PostWidget(
      {Key key,
      @required this.post,
      this.timeAgo,
      this.course,
      this.club,
      this.deletePost,
      this.block,
      this.hide,
      this.fromComments = false})
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
  String token = '';
  Comment comment;
  double containerWidth = 50.0;
  Color textColor;
  Color option1Color = Colors.deepPurpleAccent;
  Color option2Color = Colors.blueAccent;
  Color outsideOptionColor = Colors.transparent;
  double width1;
  double width2;
  PostUser _user;

  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.fromComments) {
          return;
        }
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PostDetailPage(
                    post: widget.post,
                    course: widget.course,
                    club: widget.club,
                    timeAgo: widget.timeAgo)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
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
                          // if (widget.post.isAnonymous == false) {
                          //   showProfile(
                          //       user, context, bioC, sC, igC, lC, null, null);
                          // }
                          if (widget.post.isAnonymous == false) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfilePage(
                                        user: user, heroTag: widget.post.id)));
                          }
                        } else {
                          // showProfile(
                          //     user, context, bioC, sC, igC, lC, null, null);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfilePage(
                                        user: user,
                                        heroTag: widget.post.id,
                                        isMyProfile: true,
                                      )));
                        }
                      },
                      child: widget.post.isAnonymous
                          ? CircleAvatar(
                              child: Icon(AntDesign.ellipsis1,
                                  color: Colors.white),
                              backgroundColor: Colors.blue)
                          : imgUrl == null || imgUrl == ''
                              ? CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                      widget.post.username.substring(0, 1),
                                      style: TextStyle(color: Colors.white)))
                              : Hero(
                                  tag: widget.post.id,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.network(
                                      imgUrl,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return SizedBox(
                                          height: 40,
                                          width: 40,
                                          child: Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.0,
                                                valueColor:
                                                    new AlwaysStoppedAnimation<
                                                            Color>(
                                                        Colors.grey[500]),
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
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                    ),
                    SizedBox(width: 10.0),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    widget.post.userId ==
                                            firebaseAuth.currentUser.uid
                                        ? "You"
                                        : widget.post.isAnonymous
                                            ? "Anonymous"
                                            : widget.post.username,
                                    style: GoogleFonts.questrial(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: widget.post.userId ==
                                                firebaseAuth.currentUser.uid
                                            ? Colors.blue
                                            : Theme.of(context).accentColor),
                                  ),
                                ],
                              ),
                              Visibility(
                                visible: widget.post.tcQuestion != null,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 3.0, bottom: 3.0),
                                  child: Text(
                                    'answered a question!',
                                    style: GoogleFonts.questrial(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue),
                                  ),
                                ),
                              ),
                              // Visibility(
                              //   visible: _user.about != null,
                              //   child: Text(
                              //     _user.about != null
                              //         ? _user.about
                              //         : 'No bio available',
                              //     style: GoogleFonts.questrial(
                              //         fontSize: 12,
                              //         fontWeight: FontWeight.w600,
                              //         color: Colors.grey[500]),
                              //   ),
                              // )
                            ],
                          ),
                          SizedBox(height: 2.5),
                          Text(
                            "${widget.timeAgo}",
                            style: GoogleFonts.questrial(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).buttonColor),
                          ),
                        ])
                  ])),
                  Visibility(
                    visible: !widget.fromComments,
                    child: InkWell(
                      onTap: () {
                        final act = CupertinoActionSheet(
                          title: Text(
                            widget.post.userId == firebaseAuth.currentUser.uid
                                ? "OPTIONS"
                                : "REPORT",
                            style: GoogleFonts.questrial(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).accentColor),
                          ),
                          message: Text(
                            widget.post.userId == firebaseAuth.currentUser.uid
                                ? "What would you like to do?"
                                : "What is the issue?",
                            style: GoogleFonts.questrial(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).accentColor),
                          ),
                          actions: widget.post.userId ==
                                  firebaseAuth.currentUser.uid
                              ? [
                                  CupertinoActionSheetAction(
                                      child: Text(
                                        "Delete Post",
                                        style: GoogleFonts.questrial(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                Theme.of(context).accentColor),
                                      ),
                                      onPressed: () {
                                        final act = CupertinoActionSheet(
                                            title: Text(
                                              'Delete Post',
                                              style: GoogleFonts.questrial(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context)
                                                      .accentColor),
                                            ),
                                            message: Text(
                                              'Are you sure you want to delete this post?',
                                              style: GoogleFonts.questrial(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context)
                                                      .accentColor),
                                            ),
                                            actions: [
                                              CupertinoActionSheetAction(
                                                  child: Text(
                                                    "YES",
                                                    style:
                                                        GoogleFonts.questrial(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Theme.of(
                                                                    context)
                                                                .accentColor),
                                                  ),
                                                  onPressed: () {
                                                    widget.deletePost();
                                                    Navigator.pop(context);
                                                  }),
                                              CupertinoActionSheetAction(
                                                  child: Text(
                                                    "Cancel",
                                                    style:
                                                        GoogleFonts.questrial(
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
                                        style: GoogleFonts.questrial(
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
                                        style: GoogleFonts.questrial(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                Theme.of(context).accentColor),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        showSnackBar();
                                      }),
                                  CupertinoActionSheetAction(
                                      child: Text(
                                        "It's abusive or harmful",
                                        style: GoogleFonts.questrial(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                Theme.of(context).accentColor),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        showSnackBar();
                                      }),
                                  CupertinoActionSheetAction(
                                      child: Text(
                                        "It expresses intentions of self-harm or suicide",
                                        style: GoogleFonts.questrial(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                Theme.of(context).accentColor),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        showSnackBar();
                                      }),
                                  CupertinoActionSheetAction(
                                      child: Text(
                                        "It promotes sexual/inappropriate content",
                                        style: GoogleFonts.questrial(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                Theme.of(context).accentColor),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        showSnackBar();
                                      }),
                                  CupertinoActionSheetAction(
                                      child: Text(
                                        "Hide this post.",
                                        style: GoogleFonts.questrial(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.red),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        final act = CupertinoActionSheet(
                                          title: Text(
                                            "PROCEED?",
                                            style: GoogleFonts.questrial(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context)
                                                    .accentColor),
                                          ),
                                          message: Text(
                                            "Are you sure you want to hide this post?",
                                            style: GoogleFonts.questrial(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context)
                                                    .accentColor),
                                          ),
                                          actions: [
                                            CupertinoActionSheetAction(
                                                child: Text(
                                                  "YES",
                                                  style: GoogleFonts.questrial(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Theme.of(context)
                                                          .accentColor),
                                                ),
                                                onPressed: () async {
                                                  await widget.hide();
                                                }),
                                            CupertinoActionSheetAction(
                                                child: Text(
                                                  "Cancel",
                                                  style: GoogleFonts.questrial(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                        style: GoogleFonts.questrial(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.red),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        final act = CupertinoActionSheet(
                                          title: Text(
                                            "PROCEED?",
                                            style: GoogleFonts.questrial(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context)
                                                    .accentColor),
                                          ),
                                          message: Text(
                                            "Are you sure you want to block this user?",
                                            style: GoogleFonts.questrial(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context)
                                                    .accentColor),
                                          ),
                                          actions: [
                                            CupertinoActionSheetAction(
                                                child: Text(
                                                  "YES",
                                                  style: GoogleFonts.questrial(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Theme.of(context)
                                                          .accentColor),
                                                ),
                                                onPressed: () async {
                                                  await widget.block();
                                                }),
                                            CupertinoActionSheetAction(
                                                child: Text(
                                                  "Cancel",
                                                  style: GoogleFonts.questrial(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                        style: GoogleFonts.questrial(
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
                      child: Icon(FlutterIcons.more_horiz_mdi,
                          color: Theme.of(context).accentColor),
                    ),
                  ),
                ],
              ),
            ),
            Wrap(children: [_postContent()]),
            Container(
              height: 10.0,
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).dividerColor,
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
          margin: EdgeInsets.only(left: 0.0, right: 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // ends here
              Container(
                  margin: EdgeInsets.only(
                      top: 10.0, left: 10.0, right: 10.0, bottom: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.post.tcQuestion != null
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Text(
                                widget.post.tcQuestion,
                                style: GoogleFonts.questrial(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).accentColor,
                                ),
                              ))
                          : Container(),
                      SelectableLinkify(
                        onOpen: (link) async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WebPage(
                                      title: link.text,
                                      selectedUrl: link.url)));
                        },
                        text: widget.post.content,
                        style: GoogleFonts.questrial(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).accentColor),
                        linkStyle: TextStyle(color: Colors.blue),
                      ),
                      widget.club != null
                          ? widget.post.userId == widget.club.adminId &&
                                  widget.post.isAnonymous == false &&
                                  widget.club != null
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 15.0),
                                  child: Container(
                                    color: Colors.grey,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          8.0, 3.0, 8.0, 3.0),
                                      child: Text(
                                        "Admin",
                                        style: GoogleFonts.questrial(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                )
                              : Container()
                          : Container(),
                      widget.post.questionOne != null &&
                              widget.post.questionTwo != null
                          ? Container(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                children: [
                                  SizedBox(height: 10.0),
                                  InkWell(
                                    onTap: () async {
                                      if (widget.post.isVoted) {
                                        return;
                                      }
                                      sendPushPoll(
                                          token,
                                          "Voted: ${widget.post.questionOne} on your question: ${widget.post.content}",
                                          widget.club,
                                          widget.course,
                                          widget.post.id,
                                          widget.post.userId);
                                      setState(() {
                                        widget.post.isVoted = true;
                                        widget.post.whichOption = 1;
                                        widget.post.questionOneLikeCount += 1;
                                      });
                                      width1 =
                                          MediaQuery.of(context).size.width *
                                              widthPercentage(1);
                                      width2 =
                                          MediaQuery.of(context).size.width *
                                              widthPercentage(2);
                                      await vote(widget.post, widget.club,
                                          widget.course, 1);
                                    },
                                    child: Stack(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      children: [
                                        Container(
                                          height: containerWidth,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                              color: outsideOptionColor,
                                              borderRadius:
                                                  BorderRadius.circular(5.0)),
                                        ),
                                        AnimatedContainer(
                                          duration: Duration(seconds: 1),
                                          height: containerWidth,
                                          width: widget.post.isVoted
                                              ? width1 != null
                                                  ? width1
                                                  : MediaQuery.of(context)
                                                      .size
                                                      .width
                                              : MediaQuery.of(context)
                                                  .size
                                                  .width,
                                          decoration: BoxDecoration(
                                              color:
                                                  Theme.of(context).shadowColor,
                                              borderRadius: widthPercentage(
                                                          1) ==
                                                      1.0
                                                  ? BorderRadius.circular(5.0)
                                                  : BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(5.0),
                                                      bottomLeft:
                                                          Radius.circular(
                                                              5.0))),
                                        ),
                                        Center(
                                          child: Text(
                                            widget.post.isVoted
                                                ? widget.post.questionOne +
                                                    " (" +
                                                    (widthPercentage(1) * 100)
                                                        .toInt()
                                                        .toString() +
                                                    "%)"
                                                : widget.post.questionOne,
                                            style: GoogleFonts.questrial(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context)
                                                    .accentColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5.0),
                                  InkWell(
                                    onTap: () async {
                                      if (widget.post.isVoted) {
                                        return;
                                      }

                                      sendPushPoll(
                                          token,
                                          "Voted: ${widget.post.questionTwo} on your question: ${widget.post.content}",
                                          widget.club,
                                          widget.course,
                                          widget.post.id,
                                          widget.post.userId);
                                      // TODO: - Vote second option
                                      setState(() {
                                        widget.post.isVoted = true;
                                        widget.post.whichOption = 2;
                                        widget.post.questionTwoLikeCount += 1;
                                      });
                                      width1 =
                                          MediaQuery.of(context).size.width *
                                              widthPercentage(1);
                                      width2 =
                                          MediaQuery.of(context).size.width *
                                              widthPercentage(2);
                                      await vote(widget.post, widget.club,
                                          widget.course, 2);
                                    },
                                    child: Stack(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      children: [
                                        Container(
                                          height: containerWidth,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                              color: outsideOptionColor,
                                              borderRadius:
                                                  BorderRadius.circular(5.0)),
                                        ),
                                        AnimatedContainer(
                                          duration: Duration(seconds: 1),
                                          height: containerWidth,
                                          width: widget.post.isVoted
                                              ? width2 != null
                                                  ? width2
                                                  : MediaQuery.of(context)
                                                      .size
                                                      .width
                                              : MediaQuery.of(context)
                                                  .size
                                                  .width,
                                          decoration: BoxDecoration(
                                              color: option2Color,
                                              borderRadius: widthPercentage(
                                                          2) ==
                                                      1.0
                                                  ? BorderRadius.circular(5.0)
                                                  : BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(5.0),
                                                      bottomLeft:
                                                          Radius.circular(
                                                              5.0))),
                                        ),
                                        Center(
                                          child: Text(
                                            widget.post.isVoted
                                                ? widget.post.questionTwo +
                                                    " (" +
                                                    (widthPercentage(2) * 100)
                                                        .toInt()
                                                        .toString() +
                                                    "%)"
                                                : widget.post.questionTwo,
                                            style: GoogleFonts.questrial(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context)
                                                    .accentColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                          : Container()
                    ],
                  )),
              Visibility(
                visible: widget.post.isVoted && widget.post.whichOption != 0,
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                  child: Row(
                    children: [
                      Icon(FlutterIcons.vote_mco,
                          color: Theme.of(context).buttonColor),
                      SizedBox(width: 5.0),
                      Text(
                        widget.post.whichOption == 1
                            ? 'You voted: ${widget.post.questionOne}'
                            : 'You voted: ${widget.post.questionTwo}',
                        style: GoogleFonts.questrial(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).buttonColor),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: widget.post.userId == firebaseAuth.currentUser.uid &&
                    widget.post.questionOne != null &&
                    widget.post.questionTwo != null &&
                    widget.post.questionOneLikeCount != null &&
                    widget.post.questionTwoLikeCount != null &&
                    (widget.post.questionOneLikeCount +
                            widget.post.questionTwoLikeCount) >
                        0,
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PollResultsPage(
                                  votes: widget.post.votes,
                                  questionOne: widget.post.questionOne,
                                  questionTwo: widget.post.questionTwo)));
                    },
                    child: Row(
                      children: [
                        Icon(FlutterIcons.poll_faw5s,
                            color: Theme.of(context).buttonColor),
                        SizedBox(width: 5.0),
                        Text(
                          pollCount() == 1
                              ? 'View Poll Results (' +
                                  pollCount().toString() +
                                  ' vote)'
                              : 'View Poll Results (' +
                                  pollCount().toString() +
                                  ' votes)',
                          style: GoogleFonts.questrial(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).buttonColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              widget.post.imgUrl != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(0.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          color: Colors.grey[300],
                          child: FullScreenWidget(
                            backgroundColor: Colors.brown,
                            child: Center(
                              child: Hero(
                                tag: widget.post.imgUrl,
                                child: Image.network(
                                  widget.post.imgUrl,
                                  width: MediaQuery.of(context).size.width,
                                  //height:
                                  //MediaQuery.of(context).size.height / 2,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return SizedBox(
                                      height: 200,
                                      width: MediaQuery.of(context).size.width,
                                      child: Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            valueColor:
                                                new AlwaysStoppedAnimation<
                                                    Color>(Colors.grey[500]),
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
              // SizedBox(height: 15.0),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       widget.post.likeCount == 0
              //           ? "No Likes"
              //           : widget.post.likeCount == 1
              //               ? widget.post.likeCount.toString() + " Like"
              //               : widget.post.likeCount.toString() + " Likes",
              //       style: GoogleFonts.questrial(
              //           fontSize: 13,
              //           fontWeight: FontWeight.w500,
              //           color: Colors.grey[700]),
              //     ),
              //     Text(
              //       widget.post.commentCount == 0
              //           ? "No Comments"
              //           : widget.post.commentCount == 1
              //               ? widget.post.commentCount.toString() + " Comment"
              //               : widget.post.commentCount.toString() + " Comments",
              //       style: GoogleFonts.questrial(
              //           fontSize: 13,
              //           fontWeight: FontWeight.w500,
              //           color: Colors.grey[700]),
              //     ),
              //   ],
              // ),
              Divider(thickness: 2.0, color: Theme.of(context).dividerColor),
              SizedBox(height: 7.5),
              Container(
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
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
                                        0,
                                        token,
                                        widget.post.content,
                                        widget.post.id,
                                        user.id);
                                  } else if (widget.club != null) {
                                    await sendPushClub(
                                        widget.club,
                                        0,
                                        token,
                                        widget.post.content,
                                        widget.post.id,
                                        user.id);
                                  } else {
                                    await sendPushCourse(
                                        widget.course,
                                        0,
                                        token,
                                        widget.post.content,
                                        widget.post.id,
                                        user.id);
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
                                    : Theme.of(context).buttonColor,
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
                            style: GoogleFonts.questrial(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).buttonColor),
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Icon(AntDesign.message1,
                            color: Theme.of(context).buttonColor, size: 20),
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
                            style: GoogleFonts.questrial(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).buttonColor),
                          ),
                        )
                      ],
                    ),
                    InkWell(
                      onTap: () async {
                        final RenderBox box = context.findRenderObject();
                        var title = widget.post.isAnonymous
                            ? "Anonymous: "
                            : "${widget.post.username}: ";
                        var content =
                            title + widget.post.content + " - TheirCircle";
                        await Share.share(content,
                            subject: "TheirCircle",
                            sharePositionOrigin:
                                box.localToGlobal(Offset.zero) & box.size);
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(AntDesign.sharealt,
                              color: Theme.of(context).buttonColor, size: 20),
                          SizedBox(width: 10.0),
                          Container(
                            margin: EdgeInsets.only(left: 3.0),
                            child: Text(
                              "Share",
                              style: GoogleFonts.questrial(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).buttonColor),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15.0),
              // comment != null && !widget.fromComments
              //     ? Padding(
              //         padding: const EdgeInsets.only(left: 0.0),
              //         child: Text(
              //           comment.userId == firebaseAuth.currentUser.uid
              //               ? "You"
              //               : comment.username,
              //           style: GoogleFonts.questrial(
              //               fontSize: 13,
              //               fontWeight: FontWeight.w500,
              //               color: Colors.deepPurpleAccent),
              //         ),
              //       )
              //     : SizedBox(),
              // comment != null && !widget.fromComments
              //     ? Container(
              //         height: 50,
              //         child: Row(
              //           children: [
              //             Container(
              //               height: 20.0,
              //               width: 3.0,
              //               color: Colors.deepPurpleAccent,
              //             ),
              //             SizedBox(width: 10.0),
              //             Flexible(
              //               child: Text(comment.content,
              //                   maxLines: null,
              //                   overflow: TextOverflow.ellipsis,
              //                   style: GoogleFonts.questrial(
              //                       fontSize: 13,
              //                       fontWeight: FontWeight.w500,
              //                       color: Theme.of(context).accentColor)),
              //             )
              //           ],
              //         ),
              //       )
              //     : SizedBox()
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
        backgroundColor: Theme.of(context).backgroundColor,
        content: Text('Your report has been received.',
            style: GoogleFonts.questrial(
              textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).accentColor),
            )));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser(widget.post.userId).then((value) {
      imgUrl = value.profileImgUrl;
      token = value.device_token;
      _user = value;
      setState(() {
        if (widget.post.isVoted) {
          width1 = MediaQuery.of(context).size.width * widthPercentage(1);
          width2 = MediaQuery.of(context).size.width * widthPercentage(2);
        } else {
          width1 = MediaQuery.of(context).size.width;
          width2 = MediaQuery.of(context).size.width;
        }
      });
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
    // setState(() {
    //   width1 = MediaQuery.of(context).size.width;
    //   width2 = MediaQuery.of(context).size.width;
    // });
  }

  double widthPercentage(int option) {
    int q1Count = widget.post.questionOneLikeCount;
    int q2Count = widget.post.questionTwoLikeCount;

    int val = option == 1 ? q1Count : q2Count;
    double percentage = val / (q1Count + q2Count);
    return percentage;
  }

  int pollCount() {
    if (widget.post.questionOneLikeCount == null ||
        widget.post.questionTwoLikeCount == null) {
      return 0;
    }
    return widget.post.questionOneLikeCount + widget.post.questionTwoLikeCount;
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
