import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/pages/VideoPreview.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyLibrary extends StatefulWidget {
  @override
  _MyLibraryState createState() => _MyLibraryState();
}

class _MyLibraryState extends State<MyLibrary> {
  Future<List<Video>> _future;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: appBar(),
      body: staggeredGridView(),
    );
  }

  Widget appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      iconTheme: IconThemeData(color: Theme.of(context).accentColor),
      title: Text("MY LIBRARY",
          style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).accentColor)),
      actions: [
        IconButton(
          icon: Icon(FlutterIcons.video_camera_faw,
              color: Theme.of(context).accentColor),
          onPressed: () async {
            //await selectVideo();
          },
        )
      ],
    );
  }

  Widget staggeredGridView() {
    return FutureBuilder(
      future: _future,
      builder: (context, snap) {
        if (snap.hasData && snap.data != null) {
          return StaggeredGridView.count(
              crossAxisCount: 4,
              children: List.generate(snap.data.length, (int i) {
                Video video = snap.data[i];
                return _Tile(video: video);
              }),
              staggeredTiles: List.generate(snap.data.length, (int index) {
                return StaggeredTile.fit(2);
              }));
        } else {
          return Container();
        }
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _future = VideoApi.fetchMyVideos();
  }
}

class _Tile extends StatelessWidget {
  final Video video;

  _Tile({this.video});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: InkWell(
            onTap: () {
              var timeAgo =
                  new DateTime.fromMillisecondsSinceEpoch(video.timeStamp);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VideoPreview(
                          video: video, timeAgo: timeago.format(timeAgo))));
            },
            child:
                Hero(tag: video.id, child: Image.network(video.thumbnailUrl))),
      ),
    );
  }
}
