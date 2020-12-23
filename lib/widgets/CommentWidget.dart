import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/comment.dart';
import 'package:unify/Models/user.dart' as u;

class CommentWidget extends StatefulWidget {
  final Comment comment;
  final String timeAgo;

  CommentWidget({Key key, @required this.comment, this.timeAgo})
      : super(key: key);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  String imgUrl;
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
                      style: GoogleFonts.questrial(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).accentColor),
                    ),
                    message: Text(
                      "Are you sure you want to delete this comment?",
                      style: GoogleFonts.questrial(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).accentColor),
                    ),
                    actions: [
                      CupertinoActionSheetAction(
                          child: Text(
                            "YES",
                            style: GoogleFonts.questrial(
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
                      context: context, builder: (BuildContext context) => act);
                },
              )
            ]
          : null,
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imgUrl == null || imgUrl == ''
                ? CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.grey[300],
                    child: Text(widget.comment.username.substring(0, 1),
                        style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).backgroundColor)))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network(
                      imgUrl,
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          height: 30,
                          width: 30,
                          child: Center(
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    Colors.grey[500]),
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes
                                    : null,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            SizedBox(width: 10.0),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          widget.comment.userId == firebaseAuth.currentUser.uid
                              ? "You"
                              : widget.comment.username,
                          style: GoogleFonts.questrial(
                            textStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: widget.comment.userId ==
                                        firebaseAuth.currentUser.uid
                                    ? Theme.of(context).accentColor
                                    : Constants.color()),
                          ),
                        ),
                        Text(
                          widget.timeAgo,
                          style: GoogleFonts.questrial(
                            textStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .accentColor
                                    .withOpacity(0.5)),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    widget.comment.content,
                    maxLines: null,
                    style: GoogleFonts.questrial(
                      textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).accentColor),
                    ),
                  ),
                  Divider(
                    color: Theme.of(context).dividerColor,
                    thickness: 1.0,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.comment.university != null) {
      u
          .getUserWithUniversity(
              widget.comment.userId, widget.comment.university)
          .then((value) {
        setState(() {
          imgUrl = value.profileImgUrl;
        });
      });
    } else {
      u.getUser(widget.comment.userId).then((value) {
        setState(() {
          imgUrl = value.profileImgUrl;
        });
      });
    }
  }
}
