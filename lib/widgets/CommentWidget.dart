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
                      style: GoogleFonts.manjari(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).accentColor),
                    ),
                    message: Text(
                      "Are you sure you want to delete this comment?",
                      style: GoogleFonts.manjari(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).accentColor),
                    ),
                    actions: [
                      CupertinoActionSheetAction(
                          child: Text(
                            "YES",
                            style: GoogleFonts.manjari(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).accentColor),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      CupertinoActionSheetAction(
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.manjari(
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
                          style: GoogleFonts.manjari(
                            textStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: widget.comment.userId ==
                                        firebaseAuth.currentUser.uid
                                    ? Theme.of(context).accentColor
                                    : Constants.color()),
                          ),
                        )
                      ],
                    ),
                  ),
                  Text(
                    widget.timeAgo,
                    style: GoogleFonts.manjari(
                      textStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color:
                              Theme.of(context).accentColor.withOpacity(0.5)),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0, top: 7.0),
              child: Text(
                widget.comment.content,
                style: GoogleFonts.manjari(
                  textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor),
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
