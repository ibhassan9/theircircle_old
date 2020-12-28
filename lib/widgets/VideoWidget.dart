import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/notification.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/VideoComments.dart';
import 'package:unify/pages/VideosPage.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:chewie/chewie.dart';
import 'dart:ui' as ui;

class VideoWidget extends StatefulWidget {
  final Video video;
  final String timeAgo;
  final Function delete;
  final Function next;
  final Function blockUser;

  VideoWidget(
      {Key key,
      this.video,
      this.timeAgo,
      this.delete,
      this.next,
      this.blockUser})
      : super(key: key);
  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController _controller;
  ChewieController _chewieController;
  String key;
  bool isPaused = false;
  bool initialized = false;
  String imgUrl;
  String token;
  double aspectRatio;

  final FlareControls flareControls = FlareControls();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Widget build(BuildContext context) {
    super.build(context);
    return VisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: (info) {
        if (info.visibleFraction == 0.0) {
          if (initialized && _controller != null) {
            _controller.pause();
          }
        } else if (info.visibleFraction == 1.0) {
          if (initialized && _controller != null) {
            if (_controller.value.position == _controller.value.duration) {}
            _controller.seekTo(Duration());
            _controller.play();
          }
        }
      },
      child: GestureDetector(
        onDoubleTap: () async {
          flareControls.play("like");
          if (!widget.video.isLiked) {
            setState(() {
              widget.video.isLiked = true;
              widget.video.likeCount += 1;
            });
            await VideoApi.like(widget.video);
            await sendPushVideo(0, token, widget.video.caption, widget.video.id,
                widget.video.userId);
          }
        },
        child: InkWell(
          onTap: () {
            if (isPaused) {
              _controller.play();
              isPaused = false;
            } else {
              _controller.pause();
              isPaused = true;
            }
          },
          child: ClipRRect(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.black54,
              child: Stack(
                children: [
                  CustomPaint(
                    foregroundPainter: CustomFadingEffectPainer(),
                    child: Container(
                      child: Stack(
                        children: [
                          aspectRatio != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(0.0),
                                  child: Container(
                                    color: Colors.black54,
                                    child: Hero(
                                      tag: widget.video.id,
                                      child: Image.network(
                                          widget.video.thumbnailUrl,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          fit: aspectRatio < 0.6
                                              ? BoxFit.cover
                                              : BoxFit.contain,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return SizedBox(
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Center(
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
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
                                            ));
                                      }),
                                    ),
                                  ))
                              : Container(),
                          initialized && aspectRatio != null
                              ? _controller.value.aspectRatio < 0.6
                                  ? SizedBox.expand(
                                      child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: SizedBox(
                                          width:
                                              _controller.value.size?.width ??
                                                  0,
                                          height:
                                              _controller.value.size?.height ??
                                                  0,
                                          child: VideoPlayer(_controller),
                                        ),
                                      ),
                                    )
                                  : SizedBox.expand(
                                      child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: SizedBox(
                                            // width: _controller.value.size?.width ?? 0,
                                            // height: _controller.value.size?.height ?? 0,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            child: Chewie(
                                              controller: _chewieController,
                                            )),
                                      ),
                                    )
                              : Container(),
                          Center(
                            child: Container(
                              child: Center(
                                child: SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: FlareActor(
                                    'assets/anim/like.flr',
                                    controller: flareControls,
                                    color: Colors.grey,
                                    animation: 'idle',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0.0,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              userInfo(),
                              SizedBox(height: 15.0),
                              caption(),
                            ],
                          ),
                          SizedBox(height: 15.0),
                          institution(),
                          SizedBox(height: 10.0),
                          bottomBar(context),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget institution() {
    var university = widget.video.university == "UofT"
        ? "University of Toronto"
        : widget.video.university == "YorkU"
            ? "York Univeristy"
            : "Western University";
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.0),
        color: Colors.white.withOpacity(0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          university,
          style: GoogleFonts.questrial(
              fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black),
        ),
      ),
    );
  }

  Widget userInfo() {
    return Row(
      children: [
        imgUrl == null || imgUrl == ''
            ? CircleAvatar(
                radius: 10,
                backgroundColor: Colors.grey.withOpacity(0.7),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  imgUrl,
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: 20,
                      width: 20,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Colors.grey.shade600),
                            value: loadingProgress.expectedTotalBytes != null
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
        Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.video.userId == firebaseAuth.currentUser.uid
                    ? 'Posted by you'
                    : widget.video.name,
                style: GoogleFonts.questrial(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              SizedBox(width: 5.0),
              Text(
                widget.timeAgo,
                style: GoogleFonts.questrial(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[300]),
              ),
              // SizedBox(height: 5.0),
              // institution()
            ])
      ],
    );
  }

  Widget caption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.video.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.questrial(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white)),
        SizedBox(height: 10.0),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.start,
        //   children: [
        //     Icon(FlutterIcons.library_music_mdi, color: Colors.white),
        //     SizedBox(width: 5.0),
        //     Text("DIET_ • Denzel Curry, Kenny Beats",
        //         maxLines: 2,
        //         overflow: TextOverflow.ellipsis,
        //         style: GoogleFonts.questrial(
        //             fontSize: 13,
        //             fontWeight: FontWeight.w500,
        //             color: Colors.white)),
        //   ],
        // ),
      ],
    );
  }

  Widget bottomBar(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
            child: Row(
          children: [
            Icon(AntDesign.heart,
                color: widget.video.isLiked ? Colors.red : Colors.white,
                size: 15.0),
            SizedBox(width: 10.0),
            Text(widget.video.likeCount.toString(),
                style: GoogleFonts.questrial(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
            SizedBox(width: 15.0),
            Icon(AntDesign.message1, color: Colors.white, size: 15.0),
            SizedBox(width: 10.0),
            Text(widget.video.commentCount.toString(),
                style: GoogleFonts.questrial(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white))
          ],
        )),
        Container(
            child: Row(children: [
          InkWell(
            onTap: () {
              if (widget.video.userId == firebaseAuth.currentUser.uid) {
                showDelete(context);
              } else {
                showReport(context);
              }
            },
            child: Icon(Icons.more_horiz,
                size: 30.0, color: Colors.white.withOpacity(0.8)),
          ),
          SizedBox(width: 10.0),
          InkWell(
            onTap: () async {
              if (widget.video.isLiked) {
                setState(() {
                  widget.video.isLiked = false;
                  widget.video.likeCount -= 1;
                });
                await VideoApi.unlike(widget.video);
              } else {
                setState(() {
                  widget.video.isLiked = true;
                  widget.video.likeCount += 1;
                });
                await VideoApi.like(widget.video);
                await sendPushVideo(0, token, widget.video.caption,
                    widget.video.id, widget.video.userId);
              }
            },
            child: Icon(AntDesign.heart,
                size: 30.0,
                color: widget.video.isLiked
                    ? Colors.red
                    : Colors.white.withOpacity(0.8)),
          ),
          SizedBox(width: 10.0),
          InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            VideoComments(video: widget.video)));
              },
              child: Icon(FlutterIcons.comment_fou,
                  size: 30.0, color: Colors.white.withOpacity(0.8))),
        ]))
      ]),
    );
  }

  @override
  void dispose() {
    super.dispose();
    setState(() {
      initialized = false;
    });
    if (_controller != null) {
      _controller.pause();
      _controller.dispose();
    }
    if (_chewieController != null) {
      _chewieController.dispose();
    }
    // _controller = null;
    // _chewieController = null;
  }

  @override
  void initState() {
    super.initState();
    key = getRandString(10);
    getUserWithUniversity(widget.video.userId, widget.video.university)
        .then((value) {
      imgUrl = value.profileImgUrl;
      token = value.device_token;
      getAspectRatio().then((value) {
        _controller = VideoPlayerController.network(widget.video.videoUrl)
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            _chewieController = ChewieController(
              videoPlayerController: _controller,
              // aspectRatio: MediaQuery.of(context).size.width /
              //     MediaQuery.of(context).size.height,
              showControls: false,
              autoPlay: false,
              looping: true,
            );
            setState(() {
              initialized = true;
            });
          });
        _controller.setLooping(false);
        // _controller.play();
      });
    });
  }

  reindex() {
    getAspectRatio().then((value) {
      _controller = VideoPlayerController.network(widget.video.videoUrl)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          _chewieController = ChewieController(
            videoPlayerController: _controller,
            // aspectRatio: MediaQuery.of(context).size.width /
            //     MediaQuery.of(context).size.height,
            showControls: false,
            autoPlay: true,
            looping: true,
          );
          setState(() {
            initialized = true;
          });
        });
      _controller.setLooping(false);
      _controller.play();
    });
  }

  String getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  void checkVideo() {
    // Implement your calls inside these conditions' bodies :
    if (_controller.value.position ==
        Duration(seconds: 0, minutes: 0, hours: 0)) {}

    if (_controller.value.position == _controller.value.duration) {
      widget.next();
    }
  }

  showDelete(BuildContext context) {
    final act = CupertinoActionSheet(
        title: Text(
          'Delete',
          style: GoogleFonts.questrial(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).accentColor),
        ),
        message: Text(
          'Are you sure you want to delete this video?',
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
              onPressed: () async {
                widget.delete();
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
        ]);
    showCupertinoModalPopup(
        context: context, builder: (BuildContext context) => act);
  }

  showReport(BuildContext context) {
    final act = CupertinoActionSheet(
      title: Text(
        "REPORT",
        style: GoogleFonts.questrial(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).accentColor),
      ),
      message: Text(
        "What is the issue?",
        style: GoogleFonts.questrial(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).accentColor),
      ),
      actions: [
        CupertinoActionSheetAction(
            child: Text(
              "It's suspicious or spam",
              style: GoogleFonts.questrial(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).accentColor),
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
                  color: Theme.of(context).accentColor),
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
                  color: Theme.of(context).accentColor),
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
                  color: Theme.of(context).accentColor),
            ),
            onPressed: () {
              Navigator.pop(context);
              showSnackBar();
            }),
        // CupertinoActionSheetAction(
        //     child: Text(
        //       "Hide this video.",
        //       style: GoogleFonts.questrial(
        //           fontSize: 13, fontWeight: FontWeight.w500, color: Colors.red),
        //     ),
        //     onPressed: () {
        //       Navigator.pop(context);
        //       final act = CupertinoActionSheet(
        //         title: Text(
        //           "PROCEED?",
        //           style: GoogleFonts.questrial(
        //               fontSize: 13,
        //               fontWeight: FontWeight.w500,
        //               color: Theme.of(context).accentColor),
        //         ),
        //         message: Text(
        //           "Are you sure you want to hide this video?",
        //           style: GoogleFonts.questrial(
        //               fontSize: 13,
        //               fontWeight: FontWeight.w500,
        //               color: Theme.of(context).accentColor),
        //         ),
        //         actions: [
        //           CupertinoActionSheetAction(
        //               child: Text(
        //                 "YES",
        //                 style: GoogleFonts.questrial(
        //                     fontSize: 13,
        //                     fontWeight: FontWeight.w500,
        //                     color: Theme.of(context).accentColor),
        //               ),
        //               onPressed: () async {}),
        //           CupertinoActionSheetAction(
        //               child: Text(
        //                 "Cancel",
        //                 style: GoogleFonts.questrial(
        //                     fontSize: 13,
        //                     fontWeight: FontWeight.w500,
        //                     color: Colors.red),
        //               ),
        //               onPressed: () {
        //                 Navigator.pop(context);
        //               }),
        //         ],
        //       );
        //       showCupertinoModalPopup(
        //           context: context, builder: (BuildContext context) => act);
        //     }),
        CupertinoActionSheetAction(
            child: Text(
              "Block this user",
              style: GoogleFonts.questrial(
                  fontSize: 13, fontWeight: FontWeight.w500, color: Colors.red),
            ),
            onPressed: () {
              Navigator.pop(context);
              final act = CupertinoActionSheet(
                title: Text(
                  "PROCEED?",
                  style: GoogleFonts.questrial(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor),
                ),
                message: Text(
                  "Are you sure you want to block this user?",
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
                      onPressed: () async {
                        widget.blockUser();
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
            }),
        CupertinoActionSheetAction(
            child: Text(
              "Cancel",
              style: GoogleFonts.questrial(
                  fontSize: 13, fontWeight: FontWeight.w500, color: Colors.red),
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ],
    );
    showCupertinoModalPopup(
        context: context, builder: (BuildContext context) => act);
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

  Future<Null> getAspectRatio() async {
    final Image image =
        Image(image: Image.network(widget.video.thumbnailUrl).image);
    Completer<ui.Image> completer = new Completer<ui.Image>();
    image.image
        .resolve(new ImageConfiguration())
        .addListener(new ImageStreamListener((ImageInfo image, bool _) {
      if (!completer.isCompleted) {
        completer.complete(image.image);
      }
    }));
    ui.Image info = await completer.future;
    int width = info.width;
    int height = info.height;
    setState(() {
      aspectRatio = width / height;
    });
  }

  bool get wantKeepAlive => true;
}
