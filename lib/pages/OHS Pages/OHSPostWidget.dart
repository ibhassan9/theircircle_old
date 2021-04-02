import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:like_button/like_button.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:share/share.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Components/app_icons.dart';
import 'package:unify/Models/OHS.dart';
import 'package:unify/Models/comment.dart';
import 'package:unify/pages/MyProfilePage.dart';
import 'package:unify/pages/OHS%20Pages/OHSComments.dart';
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

class OHSPostWidget extends StatefulWidget {
  final Post post;
  final String timeAgo;
  final Club club;
  final Function deletePost;
  final Function block;
  final Function hide;
  final bool fromComments;
  final Function deleteAsAdmin;

  OHSPostWidget(
      {Key key,
      @required this.post,
      this.timeAgo,
      this.club,
      this.deletePost,
      this.block,
      this.hide,
      this.fromComments = false,
      this.deleteAsAdmin})
      : super(key: key);

  @override
  _OHSPostWidgetState createState() => _OHSPostWidgetState();
}

class _OHSPostWidgetState extends State<OHSPostWidget> {
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
  Gradient gradient = LinearGradient(colors: [Colors.purple, Colors.blue]);

  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.fromComments) {
          return;
        }
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OHSPostDetail(
                    post: widget.post,
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
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      child: Row(children: [
                    InkWell(
                      onTap: () async {
                        var user = await getUserWithUniversity(
                            widget.post.userId, widget.post.university);
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
                          ? Container(
                              width: 30,
                              height: 30,
                              child: Center(
                                child: Icon(Feather.feather,
                                    color: Theme.of(context).backgroundColor,
                                    size: 15.0),
                              ),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).buttonColor,
                                  borderRadius: BorderRadius.circular(25.0)),
                            )
                          : imgUrl == null || imgUrl == ''
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: Container(
                                      width: 30,
                                      height: 30,
                                      color: Theme.of(context).dividerColor,
                                      child: Center(
                                        child: Text(
                                            widget.post.username
                                                .substring(0, 1),
                                            style: GoogleFonts.quicksand(
                                                color: Colors.white)),
                                      )),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: Image.network(
                                    imgUrl,
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: Center(
                                          child: SizedBox(
                                              width: 10,
                                              height: 10,
                                              child: LoadingIndicator(
                                                indicatorType:
                                                    Indicator.ballClipRotate,
                                                color: Theme.of(context)
                                                    .accentColor,
                                              )),
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
                                            ? "Anon"
                                            : widget.post.username,
                                    style: GoogleFonts.quicksand(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: widget.post.userId ==
                                                firebaseAuth.currentUser.uid
                                            ? Colors.indigo
                                            : Theme.of(context).accentColor),
                                  ),
                                  Text(
                                    " • ${widget.timeAgo}",
                                    style: GoogleFonts.quicksand(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).buttonColor),
                                  ),
                                ],
                              ),

                              _user != null
                                  ? _user.createdAt != null &&
                                          DateTime.now()
                                                  .difference(DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          _user.createdAt))
                                                  .inDays <
                                              5
                                      ? Text(
                                          DateTime.now()
                                                      .difference(DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              _user.createdAt))
                                                      .inDays <
                                                  5
                                              ? 'Recently Joined'
                                              : '',
                                          style: GoogleFonts.quicksand(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.red),
                                        )
                                      : Visibility(
                                          visible: _user.about != null &&
                                              _user.about.isNotEmpty &&
                                              widget.post.isAnonymous == false,
                                          child: Text(
                                            _user.about != null
                                                ? _user.about
                                                : 'No bio available',
                                            maxLines: 1,
                                            style: GoogleFonts.quicksand(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.red),
                                          ),
                                        )
                                  : Container(),
                              // Visibility(
                              //   visible: widget.post.tcQuestion != null,
                              //   child: Padding(
                              //     padding: const EdgeInsets.only(
                              //         top: 3.0, bottom: 3.0),
                              //     child: Text(
                              //       'answered a question!',
                              //       style: TextStyle(
                              //    fontFamily: Constants.fontFamily,
                              //           fontSize: 12,
                              //           fontWeight: FontWeight.w500,
                              //           color: Colors.blue),
                              //     ),
                              //   ),
                              // ),

                              // Visibility(
                              //   visible: _user.about != null,
                              //   child: Text(
                              //     _user.about != null
                              //         ? _user.about
                              //         : 'No bio available',
                              //     style: TextStyle(
                              //   fontFamily: Constants.fontFamily,
                              //         fontSize: 12,
                              //         fontWeight: FontWeight.w600,
                              //         color: Colors.grey[500]),
                              //   ),
                              // )
                            ],
                          ),
                          // SizedBox(height: 2.5),
                          // Text(
                          //   "${widget.timeAgo}",
                          //   style: TextStyle(
                          //     fontFamily: Constants.fontFamily,
                          //       fontSize: 12,
                          //       fontWeight: FontWeight.w500,
                          //       color: Theme.of(context).buttonColor),
                          // ),
                        ]),
                  ])),
                  Visibility(
                    visible: !widget.fromComments,
                    child: InkWell(
                      onTap: () {
                        final act = CupertinoActionSheet(
                          title: Text(
                            widget.post.userId ==
                                        firebaseAuth.currentUser.uid ||
                                    widget.club.adminId ==
                                        firebaseAuth.currentUser.uid
                                ? "OPTIONS"
                                : "REPORT",
                            style: GoogleFonts.quicksand(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).accentColor),
                          ),
                          message: Text(
                            widget.post.userId ==
                                        firebaseAuth.currentUser.uid ||
                                    widget.club.adminId ==
                                        firebaseAuth.currentUser.uid
                                ? "What would you like to do?"
                                : "What is the issue?",
                            style: GoogleFonts.quicksand(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).accentColor),
                          ),
                          actions: widget.post.userId ==
                                      firebaseAuth.currentUser.uid ||
                                  widget.club.adminId ==
                                      firebaseAuth.currentUser.uid
                              ? [
                                  CupertinoActionSheetAction(
                                      child: Text(
                                        "Delete Post",
                                        style: GoogleFonts.quicksand(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                Theme.of(context).accentColor),
                                      ),
                                      onPressed: () {
                                        final act = CupertinoActionSheet(
                                            title: Text(
                                              'Delete Post',
                                              style: GoogleFonts.quicksand(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context)
                                                      .accentColor),
                                            ),
                                            message: Text(
                                              'Are you sure you want to delete this post?',
                                              style: GoogleFonts.quicksand(
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
                                                        GoogleFonts.quicksand(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Theme.of(
                                                                    context)
                                                                .accentColor),
                                                  ),
                                                  onPressed: () {
                                                    if (widget.club.adminId ==
                                                        firebaseAuth
                                                            .currentUser.uid) {
                                                      widget.deleteAsAdmin();
                                                    } else {
                                                      widget.deletePost();
                                                    }
                                                    Navigator.pop(context);
                                                  }),
                                              CupertinoActionSheetAction(
                                                  child: Text(
                                                    "Cancel",
                                                    style:
                                                        GoogleFonts.quicksand(
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
                                        style: GoogleFonts.quicksand(
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
                                        style: GoogleFonts.quicksand(
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
                                        style: GoogleFonts.quicksand(
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
                                                color: Theme.of(context)
                                                    .accentColor),
                                          ),
                                          message: Text(
                                            "Are you sure you want to hide this post?",
                                            style: GoogleFonts.quicksand(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context)
                                                    .accentColor),
                                          ),
                                          actions: [
                                            CupertinoActionSheetAction(
                                                child: Text(
                                                  "YES",
                                                  style: GoogleFonts.quicksand(
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
                                                  style: GoogleFonts.quicksand(
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
                                                color: Theme.of(context)
                                                    .accentColor),
                                          ),
                                          message: Text(
                                            "Are you sure you want to block this user?",
                                            style: GoogleFonts.quicksand(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context)
                                                    .accentColor),
                                          ),
                                          actions: [
                                            CupertinoActionSheetAction(
                                                child: Text(
                                                  "YES",
                                                  style: GoogleFonts.quicksand(
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
                                                  style: GoogleFonts.quicksand(
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
                      child: Icon(FlutterIcons.more_horiz_mdi,
                          color: Theme.of(context).accentColor),
                    ),
                  ),
                ],
              ),
            ),
            Wrap(children: [_postContent()]),
            // Container(
            //   height: 10.0,
            //   width: MediaQuery.of(context).size.width,
            //   color: Theme.of(context).dividerColor,
            // )
            Divider(
              thickness: 1.0,
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
                      top: 0.0, left: 10.0, right: 10.0, bottom: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.post.tcQuestion != null
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: ShaderMask(
                                shaderCallback: (bounds) =>
                                    gradient.createShader(
                                  Rect.fromLTWH(
                                      0, 0, bounds.width, bounds.height),
                                ),
                                child: Text(
                                  widget.post.tcQuestion,
                                  style: GoogleFonts.quicksand(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ))
                          : Container(),

                      Text(widget.post.content.trimRight(),
                          style: GoogleFonts.quicksand(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).accentColor)),
                      // SelectableLinkify(
                      //   onOpen: (link) async {
                      //     Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (context) => WebPage(
                      //                 title: link.text,
                      //                 selectedUrl: link.url)));
                      //   },
                      //   text: widget.post.content,
                      //   style: TextStyle(
                      //     fontFamily: Constants.fontFamily,
                      //       fontSize: 16,
                      //       fontWeight: FontWeight.w500,
                      //       color: Theme.of(context).accentColor),
                      //   linkStyle: TextStyle(
                      //fontFamily: Constants.fontFamily,color: Colors.blue),
                      // ),
                      widget.post.userId == widget.club.adminId &&
                              widget.post.isAnonymous == false
                          ? Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Container(
                                color: Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      8.0, 3.0, 8.0, 3.0),
                                  child: Text(
                                    "Admin",
                                    style: GoogleFonts.quicksand(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            )
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
                                      //TODO: PUSH NOTIFICATION
                                      // sendPushPoll(
                                      //     token,
                                      //     "Voted: ${widget.post.questionOne} on your question: ${widget.post.content}",
                                      //     widget.club,
                                      //     null,
                                      //     widget.post.id);
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
                                      await OneHealingSpace.vote(
                                          widget.post, 1);
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
                                            style: GoogleFonts.quicksand(
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
                                      // TODO: PUSH NOTIFICATION
                                      // sendPushPoll(
                                      //     token,
                                      //     "Voted: ${widget.post.questionTwo} on your question: ${widget.post.content}",
                                      //     widget.club,
                                      //     null,
                                      //     widget.post.id);
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
                                      await OneHealingSpace.vote(
                                          widget.post, 2);
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
                                            style: GoogleFonts.quicksand(
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
                        style: GoogleFonts.quicksand(
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
                          style: GoogleFonts.quicksand(
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
                      padding: const EdgeInsets.only(
                          top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
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
                                      width: MediaQuery.of(context).size.width,
                                      child: Center(
                                        child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: LoadingIndicator(
                                              indicatorType:
                                                  Indicator.ballClipRotate,
                                              color: Colors.white,
                                            )),
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
              //       style: TextStyle(
              //fontFamily: Constants.fontFamily,
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
              //       style: TextStyle(
              //fontFamily: Constants.fontFamily,
              //           fontSize: 13,
              //           fontWeight: FontWeight.w500,
              //           color: Colors.grey[700]),
              //     ),
              //   ],
              // ),
              SizedBox(height: 5.0),
              Container(
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    // Row(
                    //   children: <Widget>[
                    //     InkWell(
                    //         onTap: () async {
                    //           if (widget.post.isLiked) {
                    //             widget.post.isLiked = false;
                    //             widget.post.likeCount -= 1;
                    //             var res =
                    //                 await OneHealingSpace.unlike(widget.post);
                    //             if (res) {
                    //               if (this.mounted) {
                    //                 setState(() {});
                    //               }
                    //             }
                    //           } else {
                    //             var user = await getUserWithUniversity(
                    //                 widget.post.userId, widget.post.university);
                    //             var token = user.device_token;
                    //             if (user.id != firebaseAuth.currentUser.uid) {
                    //               // TODO:- send push notification

                    //               // if (widget.club == null &&
                    //               //     widget.course == null) {
                    //               //   await sendPush(0, token,
                    //               //       widget.post.content, widget.post.id);
                    //               // } else if (widget.club != null) {
                    //               //   await sendPushClub(widget.club, 0, token,
                    //               //       widget.post.content, widget.post.id);
                    //               // } else {
                    //               //   await sendPushCourse(
                    //               //       widget.course,
                    //               //       0,
                    //               //       token,
                    //               //       widget.post.content,
                    //               //       widget.post.id);
                    //               // }
                    //             }
                    //             widget.post.isLiked = true;
                    //             widget.post.likeCount += 1;
                    //             var res =
                    //                 await OneHealingSpace.like(widget.post);
                    //             if (res) {
                    //               if (this.mounted) {
                    //                 setState(() {});
                    //               }
                    //             }
                    //           }
                    //         },
                    //         child: Icon(FlutterIcons.like_sli,
                    //             color: widget.post.isLiked
                    //                 ? Colors.red
                    //                 : Theme.of(context).buttonColor,
                    //             size: 20)),
                    //     SizedBox(width: 10.0),
                    //     Container(
                    //       margin: EdgeInsets.only(left: 3.0),
                    //       child: Text(
                    //         widget.post.likeCount == 0
                    //             ? "No Likes"
                    //             : widget.post.likeCount == 1
                    //                 ? widget.post.likeCount.toString() + " Like"
                    //                 : widget.post.likeCount.toString() +
                    //                     " Likes",
                    //         style: TextStyle(
                    //fontFamily: Constants.fontFamily,
                    //             fontSize: 13,
                    //             fontWeight: FontWeight.w500,
                    //             color: Theme.of(context).buttonColor),
                    //       ),
                    //     )
                    //   ],
                    // ),
                    // Row(
                    //   children: <Widget>[
                    //     Icon(AntDesign.message1,
                    //         color: Theme.of(context).buttonColor, size: 20),
                    //     SizedBox(width: 10.0),
                    //     Container(
                    //       margin: EdgeInsets.only(left: 3.0),
                    //       child: Text(
                    //         widget.post.commentCount == 0
                    //             ? "No Comments"
                    //             : widget.post.commentCount == 1
                    //                 ? widget.post.commentCount.toString() +
                    //                     " Comment"
                    //                 : widget.post.commentCount.toString() +
                    //                     " Comments",
                    //         style: TextStyle(
                    // fontFamily: Constants.fontFamily,
                    //             fontSize: 13,
                    //             fontWeight: FontWeight.w500,
                    //             color: Theme.of(context).buttonColor),
                    //       ),
                    //     )
                    //   ],
                    // ),
                    // InkWell(
                    //   onTap: () async {
                    //     final RenderBox box = context.findRenderObject();
                    //     var title = widget.post.isAnonymous
                    //         ? "Anonymous: "
                    //         : "${widget.post.username}: ";
                    //     var content =
                    //         title + widget.post.content + " - TheirCircle";
                    //     await Share.share(content,
                    //         subject: "TheirCircle",
                    //         sharePositionOrigin:
                    //             box.localToGlobal(Offset.zero) & box.size);
                    //   },
                    //   child: Row(
                    //     children: <Widget>[
                    //       Icon(AntDesign.sharealt,
                    //           color: Theme.of(context).buttonColor, size: 20),
                    //       SizedBox(width: 10.0),
                    //       Container(
                    //         margin: EdgeInsets.only(left: 3.0),
                    //         child: Text(
                    //           "Share",
                    //           style: TextStyle(
                    //fontFamily: Constants.fontFamily,
                    //               fontSize: 13,
                    //               fontWeight: FontWeight.w500,
                    //               color: Theme.of(context).buttonColor),
                    //         ),
                    //       )
                    //     ],
                    //   ),
                    // ),
                    LikeButton(
                      likeCountAnimationType: LikeCountAnimationType.all,
                      isLiked: widget.post.isLiked,
                      likeCount: widget.post.likeCount,
                      size: 20.0,
                      circleColor: CircleColor(
                          start: Color(0xff00ddff), end: Color(0xff0099cc)),
                      bubblesColor: BubblesColor(
                          dotPrimaryColor: Color(0xff33b5e5),
                          dotSecondaryColor: Color(0xff0099cc)),
                      onTap: (_) async {
                        if (widget.post.isLiked) {
                          widget.post.isLiked = false;
                          widget.post.likeCount -= 1;
                          var res = await OneHealingSpace.unlike(widget.post);
                          if (res) {
                            if (this.mounted) {
                              setState(() {});
                            }
                          }
                        } else {
                          var user = await getUserWithUniversity(
                              widget.post.userId, widget.post.university);
                          var token = user.device_token;
                          if (user.id != firebaseAuth.currentUser.uid) {
                            // TODO:- send push notification

                            // if (widget.club == null &&
                            //     widget.course == null) {
                            //   await sendPush(0, token,
                            //       widget.post.content, widget.post.id);
                            // } else if (widget.club != null) {
                            //   await sendPushClub(widget.club, 0, token,
                            //       widget.post.content, widget.post.id);
                            // } else {
                            //   await sendPushCourse(
                            //       widget.course,
                            //       0,
                            //       token,
                            //       widget.post.content,
                            //       widget.post.id);
                            // }
                          }
                          widget.post.isLiked = true;
                          widget.post.likeCount += 1;
                          var res = await OneHealingSpace.like(widget.post);
                          if (res) {
                            if (this.mounted) {
                              setState(() {});
                            }
                          }
                        }
                        return widget.post.isLiked;
                      },
                    ),
                    SizedBox(width: 30.0),
                    Row(
                      children: <Widget>[
                        Icon(FlutterIcons.comments_faw5s,
                            color:
                                Theme.of(context).buttonColor.withOpacity(0.2),
                            size: 20),
                        SizedBox(width: 5.0),
                        Container(
                          margin: EdgeInsets.only(left: 3.0),
                          child: Text(
                            widget.post.commentCount == 0
                                ? 0.toString()
                                : widget.post.commentCount == 1
                                    ? widget.post.commentCount.toString()
                                    : widget.post.commentCount.toString(),
                            style: GoogleFonts.quicksand(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .buttonColor
                                    .withOpacity(0.8)),
                          ),
                        )
                      ],
                    ),
                    SizedBox(width: 30.0),
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
                          Icon(FlutterIcons.share_alt_faw5s,
                              color: Colors.indigo, size: 15),
                          SizedBox(width: 5.0),
                          Container(
                            margin: EdgeInsets.only(left: 3.0),
                            child: Text("Share",
                                style: GoogleFonts.quicksand(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.indigo)),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.0),
              // comment != null && !widget.fromComments
              //     ? Padding(
              //         padding: const EdgeInsets.only(left: 0.0),
              //         child: Text(
              //           comment.userId == firebaseAuth.currentUser.uid
              //               ? "You"
              //               : comment.username,
              //           style: TextStyle(
              // fontFamily: Constants.fontFamily,
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
              //                   style: TextStyle(
              //  fontFamily: Constants.fontFamily,
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
    return await getUserWithUniversity(
        widget.post.userId, widget.post.university);
  }

  showSnackBar() {
    final snackBar = SnackBar(
        backgroundColor: Theme.of(context).backgroundColor,
        content: Text(
          'Your report has been received.',
          style: GoogleFonts.quicksand(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).accentColor),
        ));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserWithUniversity(widget.post.userId, widget.post.university)
        .then((value) {
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
      // fetchComments(widget.post, widget.course, widget.club).then((value) {
      //   if (value.length > 0 && value != null) {
      //     Comment c = value.last;
      //     if (this.mounted) {
      //       setState(() {
      //         comment = c;
      //       });
      //     }
      //   }
      // });
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
