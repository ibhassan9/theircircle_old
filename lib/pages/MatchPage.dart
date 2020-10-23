import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/match.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/MyMatchesPage.dart';
import 'package:unify/widgets/MatchWidget.dart';

class MatchPage extends StatefulWidget {
  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  CardController controller = CardController();

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(FlutterIcons.user_ant, color: Colors.pink),
          onPressed: () {},
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Find & Match",
              style: GoogleFonts.quicksand(
                textStyle: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ),
            Text(
              "Meet & Make New Friends",
              style: GoogleFonts.quicksand(
                textStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(FlutterIcons.kiss_wink_heart_faw5s, color: Colors.pink),
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
        Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FlutterIcons.sad_cry_faw5, color: Colors.grey),
            SizedBox(height: 10.0),
            Text(
              'The feed is empty now! Come back later.',
              style: GoogleFonts.quicksand(
                textStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey),
              ),
            ),
          ],
        )),
        ListView(children: [
          Container(
            height: MediaQuery.of(context).size.height / 1.5,
            child: FutureBuilder(
                future: myCampusUsers(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting)
                    return Center(
                        child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                    ));
                  else if (snap.hasData)
                    return TinderSwapCard(
                      swipeUp: false,
                      swipeDown: false,
                      animDuration: 200,
                      orientation: AmassOrientation.RIGHT,
                      totalNum: snap.data.length,
                      stackNum: 4,
                      swipeEdge: 4.0,
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                      maxHeight: MediaQuery.of(context).size.height / 1.6,
                      minWidth: MediaQuery.of(context).size.width * 0.8,
                      minHeight: MediaQuery.of(context).size.height / 1.7,
                      cardBuilder: (context, index) {
                        PostUser user = snap.data[index];
                        return MatchWidget(user: user);
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
                          (CardSwipeOrientation orientation, int index) async {
                        /// Get orientation & index of swiped card!
                        if (orientation == CardSwipeOrientation.RIGHT) {
                          PostUser user = snap.data[index];
                          bool isMatch = await swipeRight(user.id);
                          if (isMatch) {
                            print('This is a match! Congrats');
                          } else {
                            print('This isn\'t a match. Sorry!');
                          }
                        }
                      },
                    );
                  else if (snap.hasError)
                    return Text("ERROR: ${snap.error}");
                  else
                    return Text('None');
                }),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      blurRadius: 3,
                      color: Colors.grey.shade400,
                      spreadRadius: 1)
                ],
              ),
              child: InkWell(
                onTap: () {
                  controller.triggerLeft();
                },
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.black,
                  child: Icon(FlutterIcons.close_ant, color: Colors.white),
                ),
              ),
            ),
            SizedBox(width: 20.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      blurRadius: 3,
                      color: Colors.grey.shade400,
                      spreadRadius: 1)
                ],
              ),
              child: InkWell(
                onTap: () {
                  controller.triggerRight();
                },
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.pink,
                  child: Icon(FlutterIcons.hearto_ant, color: Colors.white),
                ),
              ),
            )
          ])
        ]),
      ]),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
}
