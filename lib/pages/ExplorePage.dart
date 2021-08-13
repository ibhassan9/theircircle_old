import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/news.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/Models/room.dart';
import 'package:unify/widgets/CreateRoomButtonMain.dart';
import 'package:unify/widgets/NewsWidget.dart';
import 'package:unify/widgets/RoomWidgetMain.dart';

class Explore extends StatefulWidget {
  @override
  _ExploreState createState() => _ExploreState();
}

class _ExploreState extends State<Explore> with AutomaticKeepAliveClientMixin {
  String promo;
  String name;
  int uni;

  Future<List<News>> _newsFuture;
  Future<List<Room>> _roomFuture;

  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
        child: ListView(
          children: [
            // SizedBox(height: 20.0),
            // promoWidget(),
            // SizedBox(height: 20.0),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Text('Live Rooms',
            //             style: GoogleFonts.quicksand(
            //                 height: 0.5,
            //                 color: Theme.of(context).accentColor,
            //                 fontSize: 16.0,
            //                 fontWeight: FontWeight.w600)),
            //         SizedBox(height: 5.0),
            //         Text('Tap in to conversate!',
            //             style: GoogleFonts.quicksand(
            //                 height: 1,
            //                 color: Theme.of(context).buttonColor,
            //                 fontSize: 14.0,
            //                 fontWeight: FontWeight.w500)),
            //       ],
            //     ),
            //     Container(
            //       decoration: BoxDecoration(
            //           color: Colors.deepPurpleAccent,
            //           borderRadius: BorderRadius.only(
            //               topLeft: Radius.circular(20.0),
            //               topRight: Radius.circular(20.0),
            //               bottomLeft: Radius.circular(20.0))),
            //       child: Padding(
            //         padding: const EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 2.0),
            //         child: Row(
            //           children: [
            //             Icon(FlutterIcons.plus_circle_outline_mco,
            //                 color: Colors.white, size: 15.0),
            //             SizedBox(width: 5.0),
            //             Text('Create',
            //                 style: GoogleFonts.quicksand(
            //                     color: Colors.white,
            //                     fontSize: 16.0,
            //                     fontWeight: FontWeight.w600)),
            //           ],
            //         ),
            //       ),
            //     )
            //   ],
            // ),
            // SizedBox(height: 10.0),
            // rooms(),
            // SizedBox(height: 20.0),
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Text('Latest Articles',
            //         style: GoogleFonts.quicksand(
            //             height: 0.5,
            //             color: Theme.of(context).accentColor,
            //             fontSize: 16.0,
            //             fontWeight: FontWeight.w600)),
            //     SizedBox(height: 5.0),
            //     Text('Stay up-to date with current events',
            //         style: GoogleFonts.quicksand(
            //             height: 1,
            //             color: Theme.of(context).buttonColor,
            //             fontSize: 14.0,
            //             fontWeight: FontWeight.w500)),
            //   ],
            // ),
            SizedBox(height: 10.0),
            newsListWidget(),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Widget promoWidget() {
    return promo != null && promo.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
                height: 100,
                decoration: BoxDecoration(color: Colors.deepPurpleAccent),
                child: CachedNetworkImage(
                  imageUrl: promo != null ? promo : '',
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  fit: BoxFit.cover,
                )),
          )
        : Container();
  }

  Widget newsListWidget() {
    return Visibility(
      visible: uni != null,
      child: Container(
        child: FutureBuilder(
            future: _newsFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting)
                return AnimatedSwitcher(
                  duration: Duration(seconds: 1),
                  child: Center(
                      child: SizedBox(
                          width: 0,
                          height: 0,
                          child: LoadingIndicator(
                            indicatorType: Indicator.ballClipRotateMultiple,
                            color: Theme.of(context).accentColor,
                          ))),
                );
              else if (snap.hasData)
                return AnimatedSwitcher(
                  duration: Duration(seconds: 1),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 5.0,
                        mainAxisSpacing: 5.0,
                        childAspectRatio: 0.7),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snap.data.length % 2 == 0
                        ? snap.data.length
                        : snap.data.length - 1,
                    itemBuilder: (BuildContext context, int index) {
                      News news = snap.data[index];
                      return AnimatedSwitcher(
                        duration: Duration(seconds: 1),
                        child: Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: NewsWidget(
                            news: news,
                          ),
                        ),
                      );
                    },
                  ),
                );
              else if (snap.hasError)
                return AnimatedSwitcher(
                    duration: Duration(seconds: 1), child: Container());
              else
                return AnimatedSwitcher(
                    duration: Duration(seconds: 1), child: Container());
            }),
      ),
    );
  }

  Widget rooms() {
    return FutureBuilder(
      future: _roomFuture,
      builder: (context, snap) {
        if (snap.hasData && snap.connectionState == ConnectionState.done) {
          return AnimatedSwitcher(
            duration: Duration(seconds: 1),
            child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5.0,
                    mainAxisSpacing: 5.0,
                    childAspectRatio: 0.7),
                physics: NeverScrollableScrollPhysics(),
                itemCount: snap.data.length,
                itemBuilder: (context, index) {
                  Function reloadRooms = () {
                    setState(() {
                      _roomFuture = Room.fetchAll();
                    });
                  };
                  // if (index == 0) {
                  //   return AnimatedSwitcher(
                  //     duration: Duration(seconds: 1),
                  //     child: CreateRoomButtonMain(reloadRooms: reloadRooms),
                  //   );
                  // } else {
                  Room room = snap.data[index];
                  return AnimatedSwitcher(
                    duration: Duration(seconds: 1),
                    child: RoomWidgetMain(room: room, reload: reloadRooms),
                  );
                  // }
                }),
          );
        } else {
          return AnimatedSwitcher(
              duration: Duration(seconds: 1),
              child: SizedBox(
                  height: 40,
                  width: 40,
                  child: LoadingIndicator(
                      indicatorType: Indicator.ballClipRotateMultiple,
                      color: Colors.deepPurpleAccent)));
        }
      },
    );
  }

  getInitialData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _name = prefs.getString('name');
    var _uni = prefs.getInt('uni');
    var _promo = await getPromoImage();
    print(_promo);
    setState(() {
      name = _name;
      uni = _uni;
      promo = _promo;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _roomFuture = Room.fetchAll();
    getInitialData();
    uni = Constants.checkUniversity();
    _newsFuture = uni == 1
        ? scrapeYorkUNews()
        : uni == 0
            ? scrapeUofTNews()
            : scrapeWesternUNews();

    // getInitialData();
  }

  @override
  bool get wantKeepAlive => true;
}
