import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/match.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/widgets/MyConversationWidget.dart';
import 'package:unify/widgets/MyMatchWidget.dart';

class MyMatchesPage extends StatefulWidget {
  @override
  _MyMatchesPageState createState() => _MyMatchesPageState();
}

class _MyMatchesPageState extends State<MyMatchesPage> {
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.pink),
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
      ),
      body: Stack(
        children: [
          ListView(children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text('My Matches',
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  )),
            ),
            Container(
              height: 135,
              child: FutureBuilder(
                  future: fetchMatches(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting)
                      return Center(
                          child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                      ));
                    else if (snap.hasData)
                      return ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: snap.data != null ? snap.data.length : 0,
                        itemBuilder: (BuildContext context, int index) {
                          PostUser user = snap.data[index];
                          return MyMatchWidget(user: user);
                        },
                      );
                    else if (snap.hasError)
                      return Center(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.face,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 10),
                              Text("You have no matches :(",
                                  style: GoogleFonts.quicksand(
                                    textStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey),
                                  )),
                            ],
                          ),
                        );
                    else
                      return Container(
                        height: MediaQuery.of(context).size.height / 1.4,
                        child: Center(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.face,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 10),
                              Text("You have no matches :(",
                                  style: GoogleFonts.quicksand(
                                    textStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey),
                                  )),
                            ],
                          ),
                        ),
                      );
                  }),
            ),
            Divider(),
            // Chat Future
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
              child: Text('My Conversations',
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  )),
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: 7,
              itemBuilder: (BuildContext context, int index) {
                return MyConversationWidget();
              },
            ),
          ])
        ],
      ),
    );
  }
}
