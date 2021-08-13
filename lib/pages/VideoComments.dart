import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Widgets/CommentWidget.dart';
import 'package:unify/Models/comment.dart';
import 'package:unify/Models/notification.dart';
import 'package:unify/Models/post.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:unify/Models/user.dart';
import 'package:unify/pages/DB.dart';

class VideoComments extends StatefulWidget {
  final Video video;

  VideoComments({Key key, this.video}) : super(key: key);
  @override
  _VideoCommentsState createState() => _VideoCommentsState();
}

class _VideoCommentsState extends State<VideoComments> {
  TextEditingController commentController = TextEditingController();
  Future<List<Comment>> commentFuture;

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
                style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              )),
              IconButton(
                icon: Icon(
                  AntDesign.arrowright,
                  color: Theme.of(context).accentColor,
                ),
                onPressed: () async {
                  if (commentController.text.isEmpty) {
                    return;
                  }
                  Comment comment = Comment(content: commentController.text);
                  commentController.clear();
                  var res =
                      await VideoApi.postComment(comment.content, widget.video);
                  if (res) {
                    var user = await getUserWithUniversity(
                        widget.video.userId, widget.video.university);
                    var token = user.deviceToken;
                    if (user.id != FIR_UID) {
                      await sendPushVideo(1, token, comment.content,
                          widget.video.id, widget.video.userId);
                    }
                  } else {}
                  if (this.mounted) {
                    setState(() {
                      commentFuture = VideoApi.fetchComments(widget.video);
                    });
                  }
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
        centerTitle: true,
        leading: IconButton(
          icon: Icon(FlutterIcons.close_ant,
              color: Theme.of(context).accentColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Comments",
          style: GoogleFonts.quicksand(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).accentColor),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Theme.of(context).accentColor),
      ),
      body: widget.video.allowComments
          ? RefreshIndicator(
              onRefresh: refresh,
              child: Stack(
                children: <Widget>[
                  ListView(
                    children: <Widget>[
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
                                itemCount: snapshot.data != null
                                    ? snapshot.data.length
                                    : 0,
                                itemBuilder: (BuildContext context, int index) {
                                  Comment comment = snapshot.data[index];
                                  var timeAgo =
                                      new DateTime.fromMillisecondsSinceEpoch(
                                          comment.timeStamp);
                                  return CommentWidget(
                                      comment: comment,
                                      timeAgo: timeago.format(timeAgo),
                                      isVideo: true);
                                },
                              );
                            } else {
                              return Center(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.face,
                                      color: Theme.of(context).accentColor,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "There are no comments :(",
                                      style: GoogleFonts.quicksand(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).accentColor),
                                    ),
                                  ],
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
            )
          : Center(
              child: Text(
                "Comments are disabled",
                style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              ),
            ),
      bottomNavigationBar: widget.video.allowComments
          ? Padding(
              padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
              child: commentBox)
          : Container(),
    );
  }

  Future<Null> refresh() async {
    this.setState(() {
      commentFuture = VideoApi.fetchComments(widget.video);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    commentFuture = VideoApi.fetchComments(widget.video);
  }
}
