import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/CameraScreen.dart';
import 'package:unify/pages/MyLibrary.dart';
import 'package:unify/pages/UploadVideo.dart';
import 'package:unify/widgets/VideoWidget.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:timeago/timeago.dart' as timeago;

class CustomFadingEffectPainer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height));
    Paint paint = Paint()
      ..shader = LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment(0.0, 0.5),
              colors: [Colors.black, Color.fromARGB(0, 0, 0, 0)])
          .createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(CustomFadingEffectPainer linePainter) => false;
}

class CustomFadingEffect2Painer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height));
    Paint paint = Paint()
      ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [
            Colors.black.withOpacity(0.3),
            Color.fromARGB(0, 0, 0, 0)
          ]).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(CustomFadingEffect2Painer linePainter) => false;
}

class VideosPage extends StatefulWidget {
  @override
  _VideosPageState createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  Future<List<Video>> videoFuture;
  CarouselController _carouselController = CarouselController();
  Gradient gradient = LinearGradient(colors: [Colors.blue, Colors.pink]);
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          brightness: Brightness.dark,
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.white),
          // leading: IconButton(
          //   icon: Icon(FlutterIcons.photo_album_mdi, color: Colors.white),
          //   onPressed: () async {
          //     Navigator.push(context,
          //         MaterialPageRoute(builder: (context) => MyLibrary()));
          //   },
          // ),
          leadingWidth: 50,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyLibrary()));
              },
              child: CircleAvatar(
                radius: 20.0,
                backgroundColor: Colors.grey.withOpacity(0.4),
                child: Icon(FlutterIcons.library_books_mco,
                    color: Colors.white, size: 20.0),
              ),
            ),
          ),
          title: InkWell(
            onTap: () {
              refresh();
            },
            child: Text("Explore",
                style: GoogleFonts.manrope(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white)),
          ),
          actions: [
            // IconButton(
            //   icon: Icon(FlutterIcons.video_camera_faw, color: Colors.white),
            //   onPressed: () async {
            //     await selectVideo();
            //   },
            // )

            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: InkWell(
                onTap: () async {
                  await selectVideo();
                },
                child: CircleAvatar(
                  backgroundColor: Colors.grey.withOpacity(0.4),
                  radius: 20.0,
                  child: Icon(FlutterIcons.plus_circle_outline_mco,
                      color: Colors.white, size: 20.0),
                ),
              ),
            )
          ],
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        body: RefreshIndicator(
            onRefresh: refresh,
            child: StreamBuilder(
              stream: videoFuture.asStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  List<Video> videos = snapshot.data;
                  return CarouselSlider.builder(
                      carouselController: _carouselController,
                      options: CarouselOptions(
                          enableInfiniteScroll: false,
                          viewportFraction: 0.99999,
                          autoPlay: false,
                          scrollDirection: Axis.vertical,
                          height: MediaQuery.of(context).size.height),
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index, index1) {
                        Video video = videos[index];
                        var timeAgo = new DateTime.fromMillisecondsSinceEpoch(
                            video.timeStamp);
                        Function delete = () async {
                          await VideoApi.delete(video.id).then((value) {
                            //setState(() {});
                            setState(() {
                              videoFuture = VideoApi.fetchVideos();
                            });
                            //_carouselController.animateToPage(0);
                          });
                        };

                        Function blockUser = () async {
                          await block(video.userId, video.university)
                              .then((value) {
                            setState(() {
                              videoFuture = VideoApi.fetchVideos();
                            });
                          });
                        };
                        return VideoWidget(
                            key: ValueKey(video.id),
                            video: video,
                            timeAgo: timeago.format(timeAgo),
                            delete: delete,
                            blockUser: blockUser);
                      });
                } else {
                  return Container();
                }
              },
            )));
    // child: FutureBuilder(
    //   future: videoStream,
    //   builder: (context, snapshot) {
    //     if (snapshot.hasData && snapshot.data != null) {
    //       // return PageView.builder(
    //       //     scrollDirection: Axis.vertical,
    //       //     itemCount: snapshot.data.length,
    //       //     itemBuilder: (context, index) {
    //       //       Video video = snapshot.data[index];
    //       //       print(index);
    //       //       var timeAgo = new DateTime.fromMillisecondsSinceEpoch(
    //       //           video.timeStamp);
    //       //       Function delete = () async {
    //       //         await VideoApi.delete(video.id).then((value) {
    //       //           setState(() {});
    //       //           //_carouselController.animateToPage(0);
    //       //         });
    //       //       };
    //       //       return VideoWidget(
    //       //           video: video,
    //       //           timeAgo: timeago.format(timeAgo),
    //       //           delete: delete);
    //       //     });

    //     } else {
    //       return Container();
    //     }
    //   },
    // )));

    // Widget feed() {
    //   return FutureBuilder(
    //     future: videoStream,
    //     builder: (context, snapshot) {
    //       if (snapshot.hasData && snapshot.data != null) {
    //         List<Video> lst = snapshot.data;
    //         return CarouselSlider(
    //           options: CarouselOptions(
    //               enableInfiniteScroll: false,
    //               viewportFraction: 1.0,
    //               autoPlay: false,
    //               scrollDirection: Axis.vertical,
    //               height: MediaQuery.of(context).size.height),
    //           items: lst.map((i) {
    //             var timeAgo =
    //                 new DateTime.fromMillisecondsSinceEpoch(i.timeStamp);
    //             return Builder(
    //               builder: (BuildContext context) {
    //                 return VideoWidget(
    //                   video: i,
    //                   timeAgo: timeago.format(timeAgo),
    //                 );
    //               },
    //             );
    //           }).toList(),
    //         );
    //       } else {
    //         return Container();
    //       }
    //     },
    //   );
    // }
  }

  selectVideo() async {
    File file = await VideoApi.getVideo();
    if (file == null) {
      return;
    }
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UploadVideo(videoFile: file)))
        .then((value) async {
      await refresh().then((value) {
        _carouselController.animateToPage(0);
      });
    });
  }

  Future<Null> refresh() async {
    videoFuture = VideoApi.fetchVideos();
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refresh();
  }
}
