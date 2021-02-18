import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/MatchedOverlay.dart';
import 'package:unify/pages/MyMatchesPage.dart';
import 'package:unify/pages/MyProfilePage.dart';
import 'package:unify/pages/ProfilePage.dart';
import 'package:unify/widgets/MatchWidget.dart';
import 'package:unify/widgets/MatchWidgetPersonal.dart';

class MatchPage extends StatefulWidget {
  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage>
    with AutomaticKeepAliveClientMixin {
  CardController controller = CardController();
  ConfettiController _controllerCenter =
      ConfettiController(duration: const Duration(seconds: 10));
  int currentIndex = 0;
  List<PostUser> currentUsers = [];
  Future<List<PostUser>> _students;
  PostUser _user;

  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        centerTitle: false,
        iconTheme: IconThemeData(color: Theme.of(context).accentColor),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Network",
              style: GoogleFonts.quicksand(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).accentColor),
            ),
            Text(
              "Expand your horizon",
              style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).accentColor),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(AntDesign.user, color: Theme.of(context).accentColor),
            onPressed: () {
              if (_user == null) {
                return;
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePage(
                            user: _user,
                            heroTag: _user.id,
                            isMyProfile: true,
                          )));
            },
          ),
          IconButton(
            icon: Icon(FlutterIcons.chat_bubble_mdi,
                color: Theme.of(context).accentColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyMatchesPage()),
              );
            },
          ),
        ],
        elevation: 0.0,
      ),
      body: Stack(children: [
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _controllerCenter,
            blastDirectionality: BlastDirectionality
                .explosive, // don't specify a direction, blast randomly
            shouldLoop:
                false, // start again as soon as the animation is finished
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ], // manually specify the colors to be used
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: FutureBuilder(
                        future: _students,
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting)
                            return Center(
                                child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                            ));
                          else if (snap.hasData) {
                            currentUsers = snap.data;
                            return TinderSwapCard(
                              swipeUp: false,
                              swipeDown: false,
                              animDuration: 200,
                              orientation: AmassOrientation.BOTTOM,
                              swipeEdgeVertical: 10.0,
                              totalNum: snap.data.length,
                              stackNum: 4,
                              swipeEdge: 4.0,
                              maxWidth: MediaQuery.of(context).size.width * 0.9,
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.9,
                              minWidth: MediaQuery.of(context).size.width * 0.8,
                              minHeight:
                                  MediaQuery.of(context).size.height * 0.8,
                              cardBuilder: (context, index) {
                                PostUser user = snap.data[index];
                                Function swipe = () {
                                  controller.triggerRight();
                                };
                                if (user.id == firebaseAuth.currentUser.uid) {
                                  return MatchWidgetPersonal(
                                      user: user, swipe: swipe);
                                }
                                return MatchWidget(user: user, swipe: swipe);
                              },
                              cardController: controller,
                              swipeUpdateCallback:
                                  (DragUpdateDetails details, Alignment align) {
                                /// Get swiping card's alignment
                                if (align.x < 0) {
                                  //Card is LEFT swiping
                                } else if (align.x > 0) {
                                  //Card is RIGHT swiping
                                }
                              },
                              swipeCompleteCallback:
                                  (CardSwipeOrientation orientation,
                                      int index) async {
                                currentIndex = index;

                                /// Get orientation & index of swiped card!
                                if (orientation == CardSwipeOrientation.RIGHT) {
                                  //PostUser user = snap.data[index];
                                  //bool isMatch = await swipeRight(user.id);
                                  // if (isMatch) {
                                  //   Navigator.of(context)
                                  //       .push(MatchedOverlay(user: user));
                                  // } else {}
                                }
                              },
                            );
                          } else if (snap.hasError)
                            return Center(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(FlutterIcons.sad_cry_faw5,
                                    color: Theme.of(context).accentColor),
                                SizedBox(height: 10.0),
                                Text(
                                  'The feed is empty now! Come back later.',
                                  style: GoogleFonts.quicksand(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).accentColor),
                                ),
                              ],
                            ));
                          else
                            return Center(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(FlutterIcons.sad_cry_faw5,
                                    color: Theme.of(context).accentColor),
                                SizedBox(height: 10.0),
                                Text(
                                  'The feed is empty now! Come back later.',
                                  style: GoogleFonts.quicksand(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).accentColor),
                                ),
                              ],
                            ));
                        }),
                  ),
                ),

                // Container(
                //   width: MediaQuery.of(context).size.width * 0.9,
                //   height: 50,
                //   decoration: BoxDecoration(
                //       color: Theme.of(context).accentColor,
                //       borderRadius: BorderRadius.circular(30.0)),
                // )
              ],
            ),
          ),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controllerCenter.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _students = allStudents();
    getUser(firebaseAuth.currentUser.uid).then((value) {
      setState(() {
        _user = value;
      });
    });
  }

  bool get wantKeepAlive => true;
}
