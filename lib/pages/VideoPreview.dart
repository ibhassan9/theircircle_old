import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unify/Models/notification.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/DB.dart';
import 'package:unify/pages/VideoComments.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:chewie/chewie.dart';
import 'dart:ui' as ui;

class VideoPreview extends StatefulWidget {
  final Video video;
  final String timeAgo;
  final Function delete;

  VideoPreview({Key key, this.video, this.timeAgo, this.delete})
      : super(key: key);
  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview>
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

  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0.0),
      body: VisibilityDetector(
        key: Key(key),
        onVisibilityChanged: (info) {
          if (info.visibleFraction == 0.0) {
            if (initialized) {
              _controller.pause();
            }
          } else if (info.visibleFraction == 1.0) {
            if (initialized) {
              _controller.play();
            }
          }
        },
        child: GestureDetector(
          onDoubleTap: () async {
            flareControls.play("like.flr");
            if (!widget.video.isLiked) {
              setState(() {
                widget.video.isLiked = true;
                widget.video.likeCount += 1;
              });
              await VideoApi.like(widget.video);
              await sendPushVideo(0, token, widget.video.caption,
                  widget.video.id, widget.video.userId);
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
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.black54,
              child: Stack(
                children: [
                  aspectRatio != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(0.0),
                          child: Container(
                              color: Colors.black54,
                              child: CachedNetworkImage(
                                imageUrl: widget.video.thumbnailUrl,
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                fit: aspectRatio < 0.6
                                    ? BoxFit.cover
                                    : BoxFit.contain,
                              )
                              // child: Image.network(
                              //   widget.video.thumbnailUrl,
                              //   width: MediaQuery.of(context).size.width,
                              //   height: MediaQuery.of(context).size.height,
                              //   fit: aspectRatio < 0.6
                              //       ? BoxFit.cover
                              //       : BoxFit.contain,
                              //   loadingBuilder: (BuildContext context,
                              //       Widget child,
                              //       ImageChunkEvent loadingProgress) {
                              //     if (loadingProgress == null) return child;
                              //     return SizedBox(
                              //       height: MediaQuery.of(context).size.height,
                              //       width: MediaQuery.of(context).size.width,
                              //       child: Center(
                              //         child: CircularProgressIndicator(
                              //           strokeWidth: 2.0,
                              //           valueColor:
                              //               new AlwaysStoppedAnimation<Color>(
                              //                   Colors.grey.shade600),
                              //           value: loadingProgress
                              //                       .expectedTotalBytes !=
                              //                   null
                              //               ? loadingProgress
                              //                       .cumulativeBytesLoaded /
                              //                   loadingProgress.expectedTotalBytes
                              //               : null,
                              //         ),
                              //       ),
                              //     );
                              //   },
                              // ),
                              ),
                        )
                      : Container(),
                  initialized
                      ?
                      // ? SizedBox.expand(
                      //     child: FittedBox(
                      //       fit: BoxFit.fill,
                      //       child: SizedBox(
                      //           // width: _controller.value.size?.width ?? 0,
                      //           // height: _controller.value.size?.height ?? 0,
                      //           // width: MediaQuery.of(context).size.width,
                      //           // height: MediaQuery.of(context).size.height,
                      //           child: Chewie(
                      //         controller: _chewieController,
                      //       )),
                      //     ),
                      //   )
                      _controller.value.aspectRatio < 0.6
                          ? Transform.scale(
                              scale: _controller.value.aspectRatio /
                                  (MediaQuery.of(context).size.width /
                                      MediaQuery.of(context).size.height),
                              child: Center(
                                child: AspectRatio(
                                  aspectRatio: _controller.value.aspectRatio,
                                  child: Chewie(controller: _chewieController),
                                ),
                              ),
                            )
                          : SizedBox.expand(
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                    // width: _controller.value.size?.width ?? 0,
                                    // height: _controller.value.size?.height ?? 0,
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                    child: Chewie(
                                      controller: _chewieController,
                                    )),
                              ),
                            )
                      : Container(),
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

  Widget userInfo() {
    return Row(
      children: [
        imgUrl == null || imgUrl == ''
            ? CircleAvatar(
                radius: 15,
                backgroundColor: Colors.grey.withOpacity(0.7),
              )
            : Hero(
                tag: widget.video.id,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: CachedNetworkImage(
                    imageUrl: imgUrl,
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
        SizedBox(width: 10.0),
        Text(
          widget.video.name.toUpperCase(),
          style: GoogleFonts.quicksand(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        Text(
          ' • ' + widget.timeAgo,
          style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[300]),
        )
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
            style: GoogleFonts.quicksand(
                fontSize: 15,
                fontWeight: FontWeight.w600,
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
        //         style: GoogleFonts. inter(
        // fontFamily: Constants.fontFamily,
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
      margin: EdgeInsets.only(bottom: 10.0),
      width: MediaQuery.of(context).size.width,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
            child: Row(
          children: [
            Icon(AntDesign.heart, color: Colors.white, size: 15.0),
            SizedBox(width: 10.0),
            Text(widget.video.likeCount.toString(),
                style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
            SizedBox(width: 15.0),
            Icon(AntDesign.message1, color: Colors.white, size: 15.0),
            SizedBox(width: 10.0),
            Text(widget.video.commentCount.toString(),
                style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white))
          ],
        )),
        Container(
            child: Row(children: [
          InkWell(
            onTap: () {
              if (widget.video.userId == FIR_UID) {
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
                showBarModalBottomSheet(
                  context: context,
                  expand: true,
                  builder: (context) => VideoComments(video: widget.video),
                );
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) =>
                //             VideoComments(video: widget.video)));
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
    _controller.pause();
    if (_controller != null) {
      _controller.dispose();
    }
    if (_chewieController != null) {
      _chewieController.dispose();
    }
    initialized = false;
  }

  @override
  void initState() {
    super.initState();
    key = getRandString(10);
    getUser(widget.video.userId).then((value) {
      imgUrl = value.profileImgUrl;
      token = value.deviceToken;
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
        _controller.setLooping(true);
        _controller.play();
      });
    });
  }

  String getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  showDelete(BuildContext context) {
    final act = CupertinoActionSheet(
        title: Text(
          'Delete',
          style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).accentColor),
        ),
        message: Text(
          'Are you sure you want to delete this video?',
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
              onPressed: () async {
                widget.delete();
                Navigator.pop(context);
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
        ]);
    showCupertinoModalPopup(
        context: context, builder: (BuildContext context) => act);
  }

  showReport(BuildContext context) {
    final act = CupertinoActionSheet(
      title: Text(
        "REPORT",
        style: GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).accentColor),
      ),
      message: Text(
        "What is the issue?",
        style: GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).accentColor),
      ),
      actions: [
        CupertinoActionSheetAction(
            child: Text(
              "It's suspicious or spam",
              style: GoogleFonts.quicksand(
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
              style: GoogleFonts.quicksand(
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
              style: GoogleFonts.quicksand(
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
              style: GoogleFonts.quicksand(
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
              "Hide this video.",
              style: GoogleFonts.quicksand(
                  fontSize: 13, fontWeight: FontWeight.w500, color: Colors.red),
            ),
            onPressed: () {
              Navigator.pop(context);
              final act = CupertinoActionSheet(
                title: Text(
                  "PROCEED?",
                  style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor),
                ),
                message: Text(
                  "Are you sure you want to hide this video?",
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
                      onPressed: () async {}),
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
            }),
        CupertinoActionSheetAction(
            child: Text(
              "Block this user",
              style: GoogleFonts.quicksand(
                  fontSize: 13, fontWeight: FontWeight.w500, color: Colors.red),
            ),
            onPressed: () {
              Navigator.pop(context);
              final act = CupertinoActionSheet(
                title: Text(
                  "PROCEED?",
                  style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor),
                ),
                message: Text(
                  "Are you sure you want to block this user?",
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
                      onPressed: () async {}),
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
            }),
        CupertinoActionSheetAction(
            child: Text(
              "Cancel",
              style: GoogleFonts.quicksand(
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
        content: Text(
          'Your report has been received.',
          style: GoogleFonts.quicksand(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).accentColor),
        ));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  Future<Null> getAspectRatio() async {
    final Image image =
        Image(image: Image.network(widget.video.thumbnailUrl).image);
    Completer<ui.Image> completer = new Completer<ui.Image>();
    image.image
        .resolve(new ImageConfiguration())
        .addListener(new ImageStreamListener((ImageInfo image, bool _) {
      completer.complete(image.image);
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
