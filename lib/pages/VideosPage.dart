import 'dart:ffi';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/pages/CameraScreen.dart';
import 'package:unify/widgets/VideoWidget.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideosPage extends StatefulWidget {
  @override
  _VideosPageState createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          brightness: Brightness.dark,
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text("Explore",
              style: GoogleFonts.poppins(
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
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white)),
          actions: [
            IconButton(
              icon: Icon(AntDesign.videocamera, color: Colors.white),
              onPressed: () async {
                // await upload();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CameraScreen()));
              },
            )
          ],
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.grey[800],
        body: feed());
  }

  Widget feed() {
    return FutureBuilder(
      future: VideoApi.fetchVideos(),
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
              return Builder(
                builder: (BuildContext context) {
                  return VideoWidget(
                    video: i,
                  );
                },
              );
            }).toList(),
          );
        } else {
          return Container();
        }
      },
    );
  }

  upload() async {
    File file = await VideoApi.getVideo();
    if (file == null) {
      return;
    }
    var res = await VideoApi.createVideo(file);
    if (res) {
      print('Video & thumbnail uploaded');
    }
  }
}
