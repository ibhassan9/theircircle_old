import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Home/PostWidget.dart';
import 'package:unify/Home/hashtag_widget.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/Models/user.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        ListView(
          shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            SizedBox(height: 55),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "FEED",
                style: GoogleFonts.ubuntu(
                  textStyle: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 20),
            FutureBuilder(
              future: fetchPosts(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data != null ? snapshot.data.length : 0,
                    itemBuilder: (BuildContext context, int index) {
                      Post post = snapshot.data[index];
                      var timeAgo = new DateTime.fromMillisecondsSinceEpoch(
                          post.timeStamp);
                      return PostWidget(
                          post: post, timeAgo: timeago.format(timeAgo));
                    },
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            color: Colors.white,
            height: 50,
            child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (BuildContext context, int index) {
                return HashtagWidget(title: "#Trending");
              },
            ),
          ),
        ),
      ]),
    );
  }
}
