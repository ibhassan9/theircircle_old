import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/comment.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;
  final String timeAgo;

  CommentWidget({Key key, @required this.comment, this.timeAgo})
      : super(key: key);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      closeOnScroll: true,
      secondaryActions: widget.comment.userId == firebaseAuth.currentUser.uid
          ? <Widget>[
              IconSlideAction(
                caption: '',
                color: Colors.white,
                icon: FlutterIcons.delete_ant,
                closeOnTap: true,
                onTap: () {
                  final act = CupertinoActionSheet(
                    title: Text(
                      "PROCEED?",
                      style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                    message: Text(
                      "Are you sure you want to delete this comment?",
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
                      context: context, builder: (BuildContext context) => act);
                },
              )
            ]
          : null,
      child: Container(
        child: Wrap(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Row(
                      children: <Widget>[
                        Text(
                          widget.comment.userId == firebaseAuth.currentUser.uid
                              ? "You"
                              : widget.comment.username,
                          style: GoogleFonts.quicksand(
                            textStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: widget.comment.userId ==
                                        firebaseAuth.currentUser.uid
                                    ? Colors.black
                                    : Constants.color()),
                          ),
                        )
                      ],
                    ),
                  ),
                  Text(
                    widget.timeAgo,
                    style: GoogleFonts.quicksand(
                      textStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                widget.comment.content,
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
