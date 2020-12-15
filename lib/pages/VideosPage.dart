import 'dart:ffi';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/pages/CameraScreen.dart';
import 'package:unify/pages/MyLibrary.dart';
import 'package:unify/pages/UploadVideo.dart';
import 'package:unify/widgets/VideoWidget.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:timeago/timeago.dart' as timeago;

class VideosPage extends StatefulWidget {
  @override
  _VideosPageState createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  Future<List<Video>> videoFuture;
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          brightness: Brightness.dark,
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: Icon(FlutterIcons.photo_album_mdi, color: Colors.white),
            onPressed: () async {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyLibrary()));
            },
          ),
          title: Text("EXPLORE",
              style: GoogleFonts.poppins(
                  // shadows: <Shadow>[
                  //   Shadow(
                  //     offset: Offset(0.0, 0.0),
                  //     blurRadius: 3.0,
                  //     color: Colors.grey,
                  //   ),
                  //   Shadow(
                  //     offset: Offset(0.0, 0.0),
                  //     blurRadius: 8.0,
                  //     color: Colors.grey,
                  //   ),
                  // ],
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          actions: [
            IconButton(
              icon: Icon(FlutterIcons.video_camera_faw, color: Colors.white),
              onPressed: () async {
                await selectVideo();
              },
            )
          ],
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.grey[800],
        body: RefreshIndicator(
            onRefresh: refresh,
            child: FutureBuilder(
              future: videoFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  List<Video> lst = snapshot.data;
                  return CarouselSlider(
                    options: CarouselOptions(
                        enableInfiniteScroll: false,
                        viewportFraction: 1.0,
                        autoPlay: false,
                        scrollDirection: Axis.vertical,
                        height: MediaQuery.of(context).size.height),
                    items: lst.map((i) {
                      var timeAgo =
                          new DateTime.fromMillisecondsSinceEpoch(i.timeStamp);
                      return Builder(
                        builder: (BuildContext context) {
                          return VideoWidget(
                            video: i,
                            timeAgo: timeago.format(timeAgo),
                          );
                        },
                      );
                    }).toList(),
                  );
                } else {
                  return Container();
                }
              },
            )));
  }

  // Widget feed() {
  //   return FutureBuilder(
  //     future: videoFuture,
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

  selectVideo() async {
    File file = await VideoApi.getVideo();
    if (file == null) {
      return;
    }
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => UploadVideo(videoFile: file)));
    // var res = await VideoApi.createVideo(file);
    // if (res) {
    //   print('Video & thumbnail uploaded');
    // }
  }

  Future<Null> refresh() async {
    setState(() {
      videoFuture = VideoApi.fetchVideos();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    videoFuture = VideoApi.fetchVideos();
  }
}
