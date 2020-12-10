import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/Models/user.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:shimmer/shimmer.dart';

class VideoWidget extends StatefulWidget {
  final Video video;

  VideoWidget({Key key, this.video}) : super(key: key);
  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController _controller;
  String key;
  bool isPaused = false;
  bool initialized = false;
  String imgUrl;
  String token;

  Widget build(BuildContext context) {
    super.build(context);
    return VisibilityDetector(
      key: Key(key),
      onVisibilityChanged: (info) {
        if (info.visibleFraction == 0.0) {
          _controller.pause();
        } else if (info.visibleFraction == 1.0) {
          _controller.play();
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
              Shimmer.fromColors(
                baseColor: Colors.grey[900],
                highlightColor: Colors.grey[800],
                direction: ShimmerDirection.ltr,
                enabled: !initialized,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0.0),
                  child: Container(
                    color: Colors.black54,
                    child: Image.network(
                      widget.video.thumbnailUrl,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Center(
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
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Shimmer.fromColors(
              //     baseColor: Colors.grey[300],
              //     highlightColor: Colors.grey[100],
              initialized
                  ? SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller.value.size?.width ?? 0,
                          height: _controller.value.size?.height ?? 0,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    )
                  : Container(),
              Positioned(
                bottom: 0.0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      10.0, 0.0, 10.0, kBottomNavigationBarHeight + 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          imgUrl == null || imgUrl == ''
                              ? CircleAvatar(
                                  backgroundColor: Colors.grey[300],
                                )
                              : Hero(
                                  tag: widget.video.id,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.network(
                                      imgUrl,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return SizedBox(
                                          height: 40,
                                          width: 40,
                                          child: Center(
                                            child: CircularProgressIndicator(
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
                                        );
                                      },
                                    ),
                                  ),
                                ),
                          SizedBox(width: 5.0),
                          Text(
                            widget.video.name,
                            style: GoogleFonts.quicksand(
                                shadows: <Shadow>[
                                  Shadow(
                                    offset: Offset(0.0, 0.0),
                                    blurRadius: 3.0,
                                    color: Colors.grey,
                                  ),
                                  Shadow(
                                    offset: Offset(0.0, 0.0),
                                    blurRadius: 8.0,
                                    color: Colors.grey,
                                  ),
                                ],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: 15.0),
                      Text(widget.video.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.quicksand(
                              shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(0.0, 0.0),
                                  blurRadius: 3.0,
                                  color: Colors.grey,
                                ),
                                Shadow(
                                  offset: Offset(0.0, 0.0),
                                  blurRadius: 8.0,
                                  color: Colors.grey,
                                ),
                              ],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white)),
                      SizedBox(height: 15.0),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.95,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  child: Row(
                                children: [
                                  Icon(AntDesign.heart,
                                      color: Colors.white, size: 15.0),
                                  SizedBox(width: 10.0),
                                  Text(widget.video.likeCount.toString(),
                                      style: GoogleFonts.quicksand(
                                          shadows: <Shadow>[
                                            Shadow(
                                              offset: Offset(0.0, 0.0),
                                              blurRadius: 3.0,
                                              color: Colors.grey,
                                            ),
                                            Shadow(
                                              offset: Offset(0.0, 0.0),
                                              blurRadius: 8.0,
                                              color: Colors.grey,
                                            ),
                                          ],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white)),
                                  SizedBox(width: 15.0),
                                  Icon(AntDesign.message1,
                                      color: Colors.white, size: 15.0),
                                  SizedBox(width: 10.0),
                                  Text(widget.video.commentCount.toString(),
                                      style: GoogleFonts.quicksand(
                                          shadows: <Shadow>[
                                            Shadow(
                                              offset: Offset(0.0, 0.0),
                                              blurRadius: 3.0,
                                              color: Colors.grey,
                                            ),
                                            Shadow(
                                              offset: Offset(0.0, 0.0),
                                              blurRadius: 8.0,
                                              color: Colors.grey,
                                            ),
                                          ],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white))
                                ],
                              )),
                              Container(
                                  child: Row(children: [
                                Icon(AntDesign.heart,
                                    color: Colors.white.withOpacity(0.8)),
                                SizedBox(width: 10.0),
                                Icon(FlutterIcons.comment_fou,
                                    color: Colors.white.withOpacity(0.8)),
                              ]))
                            ]),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    key = getRandString(10);
    getUser(widget.video.userId).then((value) {
      imgUrl = value.profileImgUrl;
      token = value.device_token;
      _controller = VideoPlayerController.network(widget.video.videoUrl)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {
            initialized = true;
          });
        });
      _controller.setLooping(true);
      _controller.play();
    });
  }

  String getRandString(int len) {
    var random = Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  bool get wantKeepAlive => true;
}
