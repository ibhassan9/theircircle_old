import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_unicons/unicons.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share/share.dart';
import 'package:toast/toast.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/comment.dart';
import 'package:unify/pages/DB.dart';
import 'package:unify/pages/PollResultsPage.dart';
import 'package:unify/pages/ProfilePage.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/notification.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/pages/post_detail_page.dart';
import 'package:unify/Models/user.dart';

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

  TextEditingController bioC = TextEditingController();
  TextEditingController sC = TextEditingController();
  TextEditingController igC = TextEditingController();
  TextEditingController lC = TextEditingController();
  String imgUrl = '';
  String token = '';
  Comment comment;
  double containerWidth = 50.0;
  Color color;
  Color textColor;
  Color option1Color = Colors.pink;
  Color option2Color = Colors.pink;
  Color outsideOptionColor = Colors.transparent;
  double width1;
  double width2;
  PostUser _user;
  Gradient gradient =
      LinearGradient(colors: [Colors.blue, Colors.deepPurpleAccent]);
  Gradient gradient2 = LinearGradient(
      colors: [Colors.deepOrangeAccent, Colors.deepPurpleAccent]);
  Gradient transparent =
      LinearGradient(colors: [Colors.transparent, Colors.transparent]);
  Color color1, color2, color3;

  Widget build(BuildContext context) {
    return _user != null
        ? GestureDetector(
            onDoubleTap: () async {
              if (widget.post.isLiked) {
                widget.post.isLiked = false;
                widget.post.likeCount -= 1;
                var res = await unlike(widget.post, widget.club, widget.course);
                if (res) {
                  if (this.mounted) {
                    setState(() {});
                  }
                }
              } else {
                var user = await getUser(widget.post.userId);
                var token = user.deviceToken;
                if (user.id != FIR_UID) {
                  if (widget.club == null && widget.course == null) {
                    await sendPush(
                        0, token, widget.post.content, widget.post.id, user.id);
                  } else if (widget.club != null) {
                    await sendPushClub(widget.club, 0, token,
                        widget.post.content, widget.post.id, user.id);
                  } else {
                    await sendPushCourse(widget.course, 0, token,
                        widget.post.content, widget.post.id, user.id);
                  }
                }
                widget.post.isLiked = true;
                widget.post.likeCount += 1;
                var res = await like(widget.post, widget.club, widget.course);
                if (res) {
                  if (this.mounted) {
                    setState(() {});
                  }
                }
              }
            },
            child: InkWell(
              onTap: () {
                print(widget.post.id);
                if (widget.fromComments) {
                  return;
                }
                showMaterialModalBottomSheet(
                  context: context,
                  expand: true,
                  builder: (context) => PostDetailPage(
                    post: widget.post,
                    course: widget.course,
                    club: widget.club,
                    timeAgo: widget.timeAgo,
                    isDiffUni: widget.post.university != null &&
                        (widget.post.university !=
                            (Constants.checkUniversity() == 0
                                ? 'UofT'
                                : Constants.checkUniversity() == 1
                                    ? 'YorkU'
                                    : 'WesternU')),
                  ),
                );
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => PostDetailPage(
                //             post: widget.post,
                //             course: widget.course,
                //             club: widget.club,
                //             timeAgo: widget.timeAgo)));
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 0.0, right: 0.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Container(
                                          child: Row(children: [
                                        InkWell(
                                          onTap: () async {
                                            var user = await getUser(
                                                widget.post.userId);
                                            if (widget.post.userId !=
                                                fAuth.currentUser.uid) {
                                              // if (widget.post.isAnonymous == false) {
                                              //   showProfile(
                                              //       user, context, bioC, sC, igC, lC, null, null);
                                              // }
                                              if (widget.post.isAnonymous ==
                                                  false) {
                                                showBarModalBottomSheet(
                                                    context: context,
                                                    expand: true,
                                                    builder: (context) =>
                                                        ProfilePage(
                                                            user: user,
                                                            heroTag: null));

                                                // Navigator.push(
                                                //     context,
                                                //     MaterialPageRoute(
                                                //         builder: (context) => ProfilePage(
                                                //             user: user, heroTag: widget.post.id)));
                                              }
                                            } else {
                                              // showProfile(
                                              //     user, context, bioC, sC, igC, lC, null, null);
                                              showBarModalBottomSheet(
                                                  context: context,
                                                  expand: true,
                                                  builder: (context) =>
                                                      ProfilePage(
                                                        user: user,
                                                        heroTag: null,
                                                        isMyProfile: true,
                                                      ));

                                              // Navigator.push(
                                              //     context,
                                              //     MaterialPageRoute(
                                              //         builder: (context) => ProfilePage(
                                              //               user: user,
                                              //               heroTag: widget.post.id,
                                              //               isMyProfile: true,
                                              //             )));
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                10.0, 0.0, 0.0, 5.0),
                                            child: widget.post.isAnonymous
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 5.0),
                                                    child: Container(
                                                      height: 40.0,
                                                      width: 40.0,
                                                      child: Center(
                                                        child: Text('A',
                                                            style: GoogleFonts
                                                                .quicksand(
                                                                    fontSize:
                                                                        17.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                        .white)),
                                                      ),
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          gradient: LinearGradient(
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomRight,
                                                              colors: [
                                                                color1,
                                                                color2,
                                                              ])),
                                                    ),
                                                  )
                                                : imgUrl == null || imgUrl == ''
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        child: Container(
                                                            width: 40,
                                                            height: 40,
                                                            decoration:
                                                                BoxDecoration(
                                                                    gradient: LinearGradient(
                                                                        begin: Alignment
                                                                            .topLeft,
                                                                        end: Alignment
                                                                            .bottomRight,
                                                                        colors: [
                                                                  color1,
                                                                  color2,
                                                                ])),
                                                            child: Center(
                                                              child: Text(
                                                                  widget.post
                                                                      .username
                                                                      .substring(
                                                                          0, 1),
                                                                  style: GoogleFonts.quicksand(
                                                                      fontSize:
                                                                          17.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: Colors
                                                                          .white)),
                                                            )),
                                                      )
                                                    : ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl: imgUrl,
                                                          width: 40,
                                                          height: 40,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                          ),
                                        ),
                                        widget.post.isAnonymous
                                            ? Container()
                                            : SizedBox(width: 8.0),
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                widget.post.userId == FIR_UID
                                                    ? ("You" +
                                                        (widget.post.feeling !=
                                                                null
                                                            ? " are feeling ${widget.post.feeling.toLowerCase()} ${Constants.feelings[widget.post.feeling]}"
                                                            : widget.post
                                                                        .tcQuestion !=
                                                                    null
                                                                ? " answered a question 🤔"
                                                                : ""))
                                                    : widget.post.isAnonymous
                                                        ? ("Anon" +
                                                            (widget.post.feeling !=
                                                                    null
                                                                ? " is feeling ${widget.post.feeling.toLowerCase()} ${Constants.feelings[widget.post.feeling]}"
                                                                : widget.post
                                                                            .tcQuestion !=
                                                                        null
                                                                    ? " answered a question 🤔"
                                                                    : ""))
                                                        : widget.post.username,
                                                style: GoogleFonts.quicksand(
                                                    fontSize:
                                                        widget.post.feeling !=
                                                                null
                                                            ? 13.0
                                                            : 13.0,
                                                    letterSpacing: 0,
                                                    fontWeight: FontWeight.w500,
                                                    color: widget.post.userId ==
                                                            FIR_UID
                                                        ? Colors.indigo
                                                        : Theme.of(context)
                                                            .accentColor),
                                              ),
                                              _user != null
                                                  ? _user.createdAt != null &&
                                                          DateTime.now()
                                                                  .difference(DateTime
                                                                      .fromMillisecondsSinceEpoch(
                                                                          _user
                                                                              .createdAt))
                                                                  .inDays <
                                                              5
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  bottom: 2.0),
                                                          child: Text(
                                                            DateTime.now()
                                                                        .difference(
                                                                            DateTime.fromMillisecondsSinceEpoch(_user.createdAt))
                                                                        .inDays <
                                                                    5
                                                                ? '🎈 Recently Joined'
                                                                : '',
                                                            style: GoogleFonts
                                                                .quicksand(
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    color: Colors
                                                                        .red
                                                                        .shade600),
                                                          ),
                                                        )
                                                      : Visibility(
                                                          visible: _user.about !=
                                                                  null &&
                                                              _user.about
                                                                  .isNotEmpty &&
                                                              widget.post
                                                                      .isAnonymous ==
                                                                  false,
                                                          child: Text(
                                                            _user.about != null
                                                                ? _user.about
                                                                : 'No bio available',
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts.quicksand(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Color(
                                                                    0xFF1777F2)),
                                                          ),
                                                        )
                                                  : Container(),
                                              Row(
                                                children: [
                                                  Text(
                                                    '${widget.timeAgo.replaceAll('~', '')} • ',
                                                    style: GoogleFonts.openSans(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.grey[600],
                                                      fontSize: 12.0,
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.public,
                                                    color: Colors.grey[600],
                                                    size: 12.0,
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 0.0)
                                      ])),
                                    ),
                                    Visibility(
                                      visible: !widget.fromComments,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10.0),
                                        child: InkWell(
                                          onTap: () {
                                            final act = CupertinoActionSheet(
                                              title: Text(
                                                widget.post.userId == FIR_UID
                                                    ? "OPTIONS"
                                                    : "REPORT",
                                                style: GoogleFonts.quicksand(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Theme.of(context)
                                                        .accentColor),
                                              ),
                                              message: Text(
                                                widget.post.userId == FIR_UID
                                                    ? "What would you like to do?"
                                                    : "What is the issue?",
                                                style: GoogleFonts.quicksand(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Theme.of(context)
                                                        .accentColor),
                                              ),
                                              actions:
                                                  widget.post.userId == FIR_UID
                                                      ? [
                                                          CupertinoActionSheetAction(
                                                              child: Text(
                                                                "Delete Post",
                                                                style: GoogleFonts.quicksand(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .accentColor),
                                                              ),
                                                              onPressed: () {
                                                                final act =
                                                                    CupertinoActionSheet(
                                                                        title:
                                                                            Text(
                                                                          'Delete Post',
                                                                          style: GoogleFonts.quicksand(
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.w500,
                                                                              color: Theme.of(context).accentColor),
                                                                        ),
                                                                        message:
                                                                            Text(
                                                                          'Are you sure you want to delete this post?',
                                                                          style: GoogleFonts.quicksand(
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.w500,
                                                                              color: Theme.of(context).accentColor),
                                                                        ),
                                                                        actions: [
                                                                      CupertinoActionSheetAction(
                                                                          child:
                                                                              Text(
                                                                            "YES",
                                                                            style: GoogleFonts.quicksand(
                                                                                fontSize: 13,
                                                                                fontWeight: FontWeight.w500,
                                                                                color: Theme.of(context).accentColor),
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            widget.deletePost();
                                                                            Navigator.pop(context);
                                                                          }),
                                                                      CupertinoActionSheetAction(
                                                                          child:
                                                                              Text(
                                                                            "Cancel",
                                                                            style: GoogleFonts.quicksand(
                                                                                fontSize: 13,
                                                                                fontWeight: FontWeight.w500,
                                                                                color: Colors.red),
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                          }),
                                                                    ]);
                                                                showCupertinoModalPopup(
                                                                    context:
                                                                        context,
                                                                    builder: (BuildContext
                                                                            context) =>
                                                                        act);
                                                              }),
                                                          CupertinoActionSheetAction(
                                                              child: Text(
                                                                "Cancel",
                                                                style: GoogleFonts.quicksand(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .red),
                                                              ),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              }),
                                                        ]
                                                      : [
                                                          CupertinoActionSheetAction(
                                                              child: Text(
                                                                "It's suspicious or spam",
                                                                style: GoogleFonts.quicksand(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .accentColor),
                                                              ),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                                showSnackBar();
                                                              }),
                                                          CupertinoActionSheetAction(
                                                              child: Text(
                                                                "It's abusive or harmful",
                                                                style: GoogleFonts.quicksand(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .accentColor),
                                                              ),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                                showSnackBar();
                                                              }),
                                                          CupertinoActionSheetAction(
                                                              child: Text(
                                                                "It expresses intentions of self-harm or suicide",
                                                                style: GoogleFonts.quicksand(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .accentColor),
                                                              ),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                                showSnackBar();
                                                              }),
                                                          CupertinoActionSheetAction(
                                                              child: Text(
                                                                "It promotes sexual/inappropriate content",
                                                                style: GoogleFonts.quicksand(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .accentColor),
                                                              ),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                                showSnackBar();
                                                              }),
                                                          CupertinoActionSheetAction(
                                                              child: Text(
                                                                "Hide this post.",
                                                                style: GoogleFonts.quicksand(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .red),
                                                              ),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                                final act =
                                                                    CupertinoActionSheet(
                                                                  title: Text(
                                                                    "PROCEED?",
                                                                    style: GoogleFonts.quicksand(
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Theme.of(context)
                                                                            .accentColor),
                                                                  ),
                                                                  message: Text(
                                                                    "Are you sure you want to hide this post?",
                                                                    style: GoogleFonts.quicksand(
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Theme.of(context)
                                                                            .accentColor),
                                                                  ),
                                                                  actions: [
                                                                    CupertinoActionSheetAction(
                                                                        child:
                                                                            Text(
                                                                          "YES",
                                                                          style: GoogleFonts.quicksand(
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.w500,
                                                                              color: Theme.of(context).accentColor),
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          await widget
                                                                              .hide();
                                                                        }),
                                                                    CupertinoActionSheetAction(
                                                                        child:
                                                                            Text(
                                                                          "Cancel",
                                                                          style: GoogleFonts.quicksand(
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.w500,
                                                                              color: Colors.red),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        }),
                                                                  ],
                                                                );
                                                                showCupertinoModalPopup(
                                                                    context:
                                                                        context,
                                                                    builder: (BuildContext
                                                                            context) =>
                                                                        act);
                                                              }),
                                                          CupertinoActionSheetAction(
                                                              child: Text(
                                                                "Block this user",
                                                                style: GoogleFonts.quicksand(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .red),
                                                              ),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                                final act =
                                                                    CupertinoActionSheet(
                                                                  title: Text(
                                                                    "PROCEED?",
                                                                    style: GoogleFonts.quicksand(
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Theme.of(context)
                                                                            .accentColor),
                                                                  ),
                                                                  message: Text(
                                                                    "Are you sure you want to block this user?",
                                                                    style: GoogleFonts.quicksand(
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        color: Theme.of(context)
                                                                            .accentColor),
                                                                  ),
                                                                  actions: [
                                                                    CupertinoActionSheetAction(
                                                                        child:
                                                                            Text(
                                                                          "YES",
                                                                          style: GoogleFonts.quicksand(
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.w500,
                                                                              color: Theme.of(context).accentColor),
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          await widget
                                                                              .block();
                                                                        }),
                                                                    CupertinoActionSheetAction(
                                                                        child:
                                                                            Text(
                                                                          "Cancel",
                                                                          style: GoogleFonts.quicksand(
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.w500,
                                                                              color: Colors.red),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        }),
                                                                  ],
                                                                );
                                                                showCupertinoModalPopup(
                                                                    context:
                                                                        context,
                                                                    builder: (BuildContext
                                                                            context) =>
                                                                        act);
                                                              }),
                                                          CupertinoActionSheetAction(
                                                              child: Text(
                                                                "Cancel",
                                                                style: GoogleFonts.quicksand(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .red),
                                                              ),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              }),
                                                        ],
                                            );
                                            showCupertinoModalPopup(
                                                context: context,
                                                builder:
                                                    (BuildContext context) =>
                                                        act);
                                          },
                                          child: Icon(
                                              FlutterIcons.more_horiz_mdi,
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Wrap(children: [_postContent()]),
                                // Container(
                                //   height: 10,
                                //   width: MediaQuery.of(context).size.width,
                                //   color: Theme.of(context).dividerColor,
                                // )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Divider(thickness: 1.0),
                ],
              ),
            ),
          )
        : Container();
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
                      top: widget.fromComments ? 0.0 : 7.0,
                      left: 0.0,
                      right: 0.0,
                      bottom: 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.post.tcQuestion != null
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 4.0, left: 10.0, right: 10.0),
                              // child: ShaderMask(
                              //   shaderCallback: (bounds) =>
                              //       LinearGradient(colors: [color1, color2])
                              //           .createShader(
                              //     Rect.fromLTWH(
                              //         0, 0, bounds.width, bounds.height),
                              //   ),
                              child: Text(
                                widget.post.tcQuestion,

                                style: GoogleFonts.quicksand(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).accentColor,
                                ),
                                // ),
                              ))
                          : Container(),
                      widget.post.title != null
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 10.0,
                                  top: 5.0,
                                  left: 10.0,
                                  right: 10.0),
                              child: Text(
                                widget.post.title,
                                style: GoogleFonts.quicksand(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).accentColor),
                              ),
                            )
                          : Container(),
                      widget.post.feeling != null &&
                              (widget.post.content.trim().toLowerCase() ==
                                  'is feeling ' +
                                      widget.post.feeling.toLowerCase())
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 0.0, left: 10.0, right: 10.0),
                              child: Text(widget.post.content.trimRight(),
                                  style: GoogleFonts.quicksand(
                                      fontSize: widget.fromComments ? 15 : 15,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).accentColor))
                              // child: SelectableLinkify(
                              //   onOpen: (link) async {
                              //     Navigator.push(
                              //         context,
                              //         MaterialPageRoute(
                              //             builder: (context) => WebPage(
                              //                 title: link.text,
                              //                 selectedUrl: link.url)));
                              //   },
                              //   text: widget.post.content.trimRight(),
                              //   style:  GoogleFonts. lato(
                              //
                              //       fontSize: widget.fromComments ? 15.5 : 15.5,
                              //       fontWeight: FontWeight.w500,
                              //       color: Theme.of(context).accentColor),
                              //   linkStyle:
                              //        GoogleFonts. lato(
                              // color: Colors.indigo),
                              // ),
                              ),
                      // grabUrls(content: widget.post.content.trimRight())
                      //             .length >
                      //         0
                      //     ? SizedBox(
                      //         height: 100,
                      //         width: 100,
                      //         child: SimpleUrlPreview(
                      //             url: grabUrls(
                      //                     content:
                      //                         widget.post.content.trimRight())
                      //                 .first),
                      //       )
                      //     : Container(),
                      widget.club != null
                          ? widget.post.userId == widget.club.adminId &&
                                  widget.post.isAnonymous == false &&
                                  widget.club != null
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15.0, left: 10.0, right: 10.0),
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
                              : Container()
                          : Container(),
                      widget.post.questionOne != null &&
                              widget.post.questionTwo != null
                          ? Container(
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 10.0, left: 10.0, right: 10.0),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10.0),
                                    InkWell(
                                      onTap: () async {
                                        if (widget.post.isVoted) {
                                          return;
                                        }
                                        if (widget.post.userId != FIR_UID) {
                                          sendPushPoll(
                                              token,
                                              "Voted: ${widget.post.questionOne} on your question.",
                                              widget.club,
                                              widget.course,
                                              widget.post.id,
                                              widget.post.userId);
                                        }

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
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .dividerColor,
                                                borderRadius:
                                                    BorderRadius.circular(5.0)),
                                          ),
                                          AnimatedContainer(
                                            duration: Duration(seconds: 1),
                                            height: containerWidth,
                                            width: widget.post.isVoted
                                                ? width1 != null
                                                    ? width1
                                                    : 0
                                                : 0,
                                            decoration: BoxDecoration(
                                                color: option1Color,
                                                borderRadius:
                                                    widthPercentage(1) == 1.0
                                                        ? BorderRadius.circular(
                                                            5.0)
                                                        : BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    5.0),
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
                                        if (widget.post.userId != FIR_UID) {
                                          sendPushPoll(
                                              token,
                                              "Voted: ${widget.post.questionTwo} on your question.",
                                              widget.club,
                                              widget.course,
                                              widget.post.id,
                                              widget.post.userId);
                                        }

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
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .dividerColor,
                                                borderRadius:
                                                    BorderRadius.circular(5.0)),
                                          ),
                                          AnimatedContainer(
                                            duration: Duration(seconds: 1),
                                            height: containerWidth,
                                            width: widget.post.isVoted
                                                ? width2 != null
                                                    ? width2
                                                    : 0
                                                : 0,
                                            decoration: BoxDecoration(
                                                color: option2Color,
                                                borderRadius:
                                                    widthPercentage(2) == 1.0
                                                        ? BorderRadius.circular(
                                                            5.0)
                                                        : BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    5.0),
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
                visible: widget.post.userId == FIR_UID &&
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
                          top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          color: Theme.of(context).buttonColor.withOpacity(0.1),
                          child: FullScreenWidget(
                            backgroundColor: Colors.brown,
                            child: Center(
                              child: Hero(
                                tag: widget.post.imgUrl,
                                child: CachedNetworkImage(
                                  imageUrl: widget.post.imgUrl,
                                  width: MediaQuery.of(context).size.width,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(),
              SizedBox(height: 15.0),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () async {
                              if (widget.post.university != null) {
                                if (widget.post.university !=
                                    (Constants.checkUniversity() == 0
                                        ? 'UofT'
                                        : Constants.checkUniversity() == 1
                                            ? 'YorkU'
                                            : 'WesternU')) {
                                  Toast.show(
                                      'Cannot like content from other universities :(',
                                      context);
                                  return false;
                                } else {
                                  if (widget.post.isLiked) {
                                    widget.post.isLiked = false;
                                    widget.post.likeCount -= 1;
                                    var res = await unlike(widget.post,
                                        widget.club, widget.course);
                                    if (res) {
                                      if (this.mounted) {
                                        setState(() {});
                                      }
                                    }
                                  } else {
                                    var user =
                                        await getUser(widget.post.userId);
                                    var token = user.deviceToken;
                                    if (user.id != FIR_UID) {
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
                                    var res = await like(widget.post,
                                        widget.club, widget.course);
                                    if (res) {
                                      if (this.mounted) {
                                        setState(() {});
                                      }
                                    }
                                  }
                                  return widget.post.isLiked;
                                }
                              } else {
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
                                  var token = user.deviceToken;
                                  if (user.id != FIR_UID) {
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
                              }
                            },
                            child: Row(
                              children: [
                                Icon(
                                  widget.post.isLiked
                                      ? AntDesign.heart
                                      : AntDesign.hearto,
                                  color: widget.post.isLiked
                                      ? Colors.purple
                                      : Theme.of(context).buttonColor,
                                  size: 20.0,
                                ),
                                SizedBox(width: 5.0),
                                Text(
                                  'Like',
                                  style: GoogleFonts.quicksand(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).accentColor),
                                )
                              ],
                            ),
                          ),
                          SizedBox(width: 15.0),
                          Row(
                            children: <Widget>[
                              Unicon(UniconData.uniChat,
                                  color: Theme.of(context).buttonColor,
                                  size: 20),
                              Container(
                                margin: EdgeInsets.only(left: 3.0),
                                child: Text(
                                  widget.post.commentCount.toString(),
                                  style: GoogleFonts.quicksand(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).accentColor),
                                ),
                              )
                            ],
                          ),
                          SizedBox(width: 15.0),
                          InkWell(
                            onTap: () async {
                              final RenderBox box = context.findRenderObject();
                              var title = widget.post.isAnonymous
                                  ? "Anonymous: "
                                  : "${widget.post.username}: ";
                              var content = title +
                                  widget.post.content +
                                  " - TheirCircle";
                              await Share.share(content,
                                  subject: "TheirCircle",
                                  sharePositionOrigin:
                                      box.localToGlobal(Offset.zero) &
                                          box.size);
                            },
                            child: Row(
                              children: <Widget>[
                                Icon(FlutterIcons.share_mco,
                                    size: 20.0,
                                    color: Theme.of(context).buttonColor),
                                SizedBox(width: 5.0),
                                // Container(
                                //   margin: EdgeInsets.only(left: 3.0),
                                //   child: Text("Share",
                                //       style: GoogleFonts.quicksand(
                                //           fontSize: 15,
                                //           fontWeight: FontWeight.w500,
                                //           color: Colors.pink)),
                                // )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: Colors.deepOrangeAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            FlutterIcons.heart_ant,
                            size: 10.0,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          widget.post.isLiked
                              ? widget.post.likeCount == 1
                                  ? 'You like this'
                                  : 'You and ' +
                                      (widget.post.likeCount - 1).toString() +
                                      ' like this'
                              : '${widget.post.likeCount}',
                          style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).accentColor),
                        )
                      ],
                    )
                  ],
                ),
              ),
              // SizedBox(height: 15.0),
              // comment != null && !widget.fromComments
              //     ? Padding(
              //         padding: const EdgeInsets.only(left: 0.0, bottom: 5.0),
              //         child: Text(
              //           comment.userId == firebaseAuth.currentUser.uid
              //               ? "You"
              //               : comment.username,
              //           style:  GoogleFonts. lato(
              //
              //               fontSize: 13,
              //               fontWeight: FontWeight.w500,
              //               color: Theme.of(context).accentColor),
              //         ),
              //       )
              //     : SizedBox(),
              // comment != null && !widget.fromComments
              //     ? Container(
              //         child: Row(
              //           children: [
              //             SizedBox(width: 15.0),
              //             Flexible(
              //               child: Padding(
              //                 padding: const EdgeInsets.only(right: 15.0),
              //                 child: Text(comment.content,
              //                     maxLines: null,
              //                     overflow: TextOverflow.ellipsis,
              //                     style:  GoogleFonts. lato(
              //
              //                         fontSize: 13,
              //                         fontWeight: FontWeight.w500,
              //                         color: Theme.of(context).accentColor)),
              //               ),
              //             )
              //           ],
              //         ),
              //       )
              //     : SizedBox(),
              // comment != null && !widget.fromComments
              //     ? SizedBox(
              //         height: 10.0,
              //       )
              //     : SizedBox()
            ],
          ),
        ),
        SizedBox(height: 10.0),
        Container(
            height: 3.0, color: Theme.of(context).dividerColor.withOpacity(0.3))
      ],
    );
  }

  Future<PostUser> user() async {
    return await getUser(widget.post.userId);
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
    color = Constants.color();
    color1 = Constants.color();
    color2 = Constants.color();
    color3 = Constants.color();
    if (widget.post.university != null) {
      getUserWithUniversity(widget.post.userId, widget.post.university)
          .then((value) {
        imgUrl = value.profileImgUrl;
        token = value.deviceToken;
        _user = value;
        if (this.mounted) {
          setState(() {
            if (widget.post.isVoted) {
              width1 = MediaQuery.of(context).size.width * widthPercentage(1);
              width2 = MediaQuery.of(context).size.width * widthPercentage(2);
            } else {
              width1 = MediaQuery.of(context).size.width;
              width2 = MediaQuery.of(context).size.width;
            }
          });
        }
        fetchComments(
                widget.post,
                widget.course,
                widget.club,
                widget.post.university != null
                    ? widget.post.university
                    : Constants.checkUniversity() == 0
                        ? 'UofT'
                        : Constants.checkUniversity() == 1
                            ? 'YorkU'
                            : 'WesternU')
            .then((value) {
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
    } else {
      getUser(widget.post.userId).then((value) {
        imgUrl = value.profileImgUrl;
        token = value.deviceToken;
        _user = value;
        if (this.mounted) {
          setState(() {
            if (widget.post.isVoted) {
              width1 = MediaQuery.of(context).size.width * widthPercentage(1);
              width2 = MediaQuery.of(context).size.width * widthPercentage(2);
            } else {
              width1 = MediaQuery.of(context).size.width;
              width2 = MediaQuery.of(context).size.width;
            }
          });
        }

        fetchComments(
                widget.post,
                widget.course,
                widget.club,
                widget.post.university != null
                    ? widget.post.university
                    : Constants.checkUniversity() == 0
                        ? 'UofT'
                        : Constants.checkUniversity() == 1
                            ? 'YorkU'
                            : 'WesternU')
            .then((value) {
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

    // setState(() {
    //   width1 = MediaQuery.of(context).size.width;
    //   width2 = MediaQuery.of(context).size.width;
    // });
  }

  List<String> grabUrls({String content}) {
    List<String> urls = [];
    RegExp exp =
        new RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    Iterable<RegExpMatch> matches = exp.allMatches(content);

    matches.forEach((match) {
      urls.add(content.substring(match.start, match.end));
    });
    return urls;
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
