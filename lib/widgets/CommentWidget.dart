import 'package:bubble/bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/comment.dart';
import 'package:unify/Models/user.dart' as u;

class CommentWidget extends StatefulWidget {
  final Comment comment;
  final Function respond;
  final String timeAgo;
  final bool isVideo;
  final String uni;

  CommentWidget(
      {Key key,
      @required this.comment,
      this.timeAgo,
      this.respond,
      this.isVideo = false,
      this.uni})
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
                      style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).accentColor),
                    ),
                    message: Text(
                      "Are you sure you want to delete this comment?",
                      style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).accentColor),
                    ),
                    actions: [
                      CupertinoActionSheetAction(
                          child: Text(
                            "YES",
                            style: GoogleFonts.quicksand(
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: imgUrl == null || imgUrl == ''
                  ? CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey[300],
                      child: Text(widget.comment.username.substring(0, 1),
                          style: GoogleFonts.quicksand(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black)))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.network(
                        imgUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            height: 50,
                            width: 50,
                            child: Center(
                              child: SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: LoadingIndicator(
                                    indicatorType: Indicator.ballClipRotate,
                                    color: Theme.of(context).accentColor,
                                  )),
                            ),
                          );
                        },
                      ),
                    ),
            ),
            SizedBox(width: 0.0),
            Flexible(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Bubble(
                        margin: BubbleEdges.fromLTRB(0.0, 0.0, 10.0, 0.0),
                        shadowColor: Colors.transparent,
                        alignment: Alignment.centerLeft,
                        nip: BubbleNip.no,
                        nipWidth: 1,
                        nipHeight: 1,
                        nipRadius: 0.5,
                        stick: true,
                        radius: Radius.circular(20.0),
                        color: Colors.transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 0.0, left: 5.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    widget.comment.userId ==
                                            firebaseAuth.currentUser.uid
                                        ? "You"
                                        : widget.comment.username,
                                    style: GoogleFonts.quicksand(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: widget.comment.userId ==
                                                firebaseAuth.currentUser.uid
                                            ? Theme.of(context).accentColor
                                            : Theme.of(context).accentColor),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 3.0),
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Text(
                                widget.comment.content,
                                maxLines: null,
                                style: GoogleFonts.quicksand(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).accentColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, top: 5.0),
                      child: Row(
                        children: [
                          Text(
                            widget.timeAgo,
                            style: GoogleFonts.quicksand(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .accentColor
                                    .withOpacity(0.5)),
                          ),
                          Visibility(
                            visible: widget.isVideo == false,
                            child: Text(
                              ' • ',
                              style: GoogleFonts.quicksand(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .accentColor
                                      .withOpacity(0.9)),
                            ),
                          ),
                          Visibility(
                            visible: widget.isVideo == false,
                            child: InkWell(
                              onTap: () {
                                widget.respond();
                              },
                              child: Text(
                                'Reply',
                                style: GoogleFonts.quicksand(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .accentColor
                                        .withOpacity(0.9)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                  ],
                ),
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
    print('this is uni');
    if (widget.comment.university != null) {
      u
          .getUserWithUniversity(
              widget.comment.userId, widget.comment.university)
          .then((value) {
        setState(() {
          imgUrl = value.profileImgUrl;
        });
      });
    } else if (widget.uni != null) {
      u.getUserWithUniversity(widget.comment.userId, widget.uni).then((value) {
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
