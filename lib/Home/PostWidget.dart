import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Courses/course_page.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/Comments/post_detail_page.dart';
import 'package:unify/Models/user.dart';

class PostWidget extends StatefulWidget {
  final Post post;
  final String timeAgo;
  final Course course;
  final Club club;
  final Function deletePost;

  PostWidget(
      {Key key,
      @required this.post,
      this.timeAgo,
      this.course,
      this.club,
      this.deletePost})
      : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isLiked = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

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
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    child: widget.post.isAnonymous
                        ? Icon(AntDesign.ellipsis1)
                        : Text(widget.post.username.substring(0, 1)),
                  ),
                  _postContent(),
                ],
              ),
            ),
            Container(
              height: 10.0,
              width: MediaQuery.of(context).size.width,
              color: Colors.grey.shade50,
            )
          ],
        ),
      ),
    );
  }

  Widget _postContent() {
    return Flexible(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(left: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        child: Row(children: [
                      Text(
                        widget.post.userId == firebaseAuth.currentUser.uid
                            ? "YOU"
                            : widget.post.isAnonymous
                                ? "Anonymous"
                                : widget.post.username,
                        style: GoogleFonts.quicksand(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: widget.post.userId ==
                                    firebaseAuth.currentUser.uid
                                ? Colors.deepOrange
                                : Colors.black),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 5.0),
                        child: Text(
                          " · ${widget.timeAgo}",
                          style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey),
                        ),
                      ),
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
                          actions:
                              widget.post.userId == firebaseAuth.currentUser.uid
                                  ? [
                                      CupertinoActionSheetAction(
                                          child: Text(
                                            "Delete Post",
                                            style: GoogleFonts.quicksand(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black),
                                          ),
                                          onPressed: widget.deletePost),
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
                                          onPressed: () {}),
                                      CupertinoActionSheetAction(
                                          child: Text(
                                            "It's abusive or harmful",
                                            style: GoogleFonts.quicksand(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black),
                                          ),
                                          onPressed: () {}),
                                      CupertinoActionSheetAction(
                                          child: Text(
                                            "It expresses intentions of self-harm or suicide",
                                            style: GoogleFonts.quicksand(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black),
                                          ),
                                          onPressed: () {}),
                                      CupertinoActionSheetAction(
                                          child: Text(
                                            "It promotes sexual/inappropriate content",
                                            style: GoogleFonts.quicksand(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black),
                                          ),
                                          onPressed: () {}),
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
                      child: Text(
                          widget.post.userId == firebaseAuth.currentUser.uid
                              ? "OPTIONS"
                              : "REPORT",
                          style: GoogleFonts.quicksand(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey)),
                    )
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 5.0),
                  child: Text(
                    widget.post.content,
                    style: GoogleFonts.quicksand(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
                widget.post.imgUrl != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            color: Colors.grey.shade300,
                            child: Image.network(
                              widget.post.imgUrl,
                              width: MediaQuery.of(context).size.width,
                              height: 200,
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
                                              loadingProgress.expectedTotalBytes
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(height: 15.0),
                Container(
                  margin: EdgeInsets.only(top: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(AntDesign.hearto, color: Colors.grey, size: 20),
                          SizedBox(width: 10.0),
                          Container(
                            margin: EdgeInsets.only(left: 3.0),
                            child: Text(
                              widget.post.likeCount == 0
                                  ? "No Likes"
                                  : widget.post.likeCount.toString(),
                              style: GoogleFonts.quicksand(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey),
                            ),
                          )
                        ],
                      ),
                      SizedBox(width: 15.0),
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
                                  : widget.post.commentCount.toString(),
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
                SizedBox(height: 5.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<PostUser> user() async {
    return await getUser(widget.post.userId);
  }
}
