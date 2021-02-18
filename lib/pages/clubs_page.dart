import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:unify/Models/OHS.dart';
import 'package:unify/Widgets/ClubWidget.dart';
import 'package:unify/Widgets/CourseWidget.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/pages/OHS%20Pages/MainPage.dart';
import 'package:unify/pages/club_page.dart';

class ClubsPage extends StatefulWidget {
  @override
  _ClubsPageState createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage>
    with AutomaticKeepAliveClientMixin {
  TextEditingController clubNameController = TextEditingController();
  TextEditingController clubDescriptionController = TextEditingController();
  TextEditingController searchingController = TextEditingController();
  FirebaseAuth fAuth = FirebaseAuth.instance;

  List<Club> clubs = [];
  List<Club> searchedClubs = [];
  bool isSearching = false;
  String filter;
  Club _oneHealingSpace;
  String _oneHealingSpaceImageUrl;

  Future<List<Club>> _clubFuture;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    addClubDialog() {
      bool switchVal = false;
      AwesomeDialog(
          context: context,
          animType: AnimType.SCALE,
          dialogType: DialogType.NO_HEADER,
          body: StatefulBuilder(builder: (context, setState) {
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Create a Virtual Community",
                    style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).accentColor),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: clubNameController,
                  maxLines: null,
                  decoration: new InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                          left: 10, bottom: 11, top: 11, right: 15),
                      hintText: "Ex. Football Society"),
                  style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor),
                ),
                TextField(
                  controller: clubDescriptionController,
                  maxLines: null,
                  decoration: new InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                          left: 10, bottom: 11, top: 11, right: 15),
                      hintText: "Describe your community here..."),
                  style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            "Privacy " +
                                (switchVal == true ? "(Private)" : "(Public)"),
                            style: GoogleFonts.quicksand(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).accentColor)),
                        Switch(
                            activeColor: Colors.deepOrange,
                            value: switchVal,
                            onChanged: (val) {
                              setState(() {
                                switchVal = val;
                              });
                            })
                      ]),
                )
              ],
            );
          }),
          btnOkColor: Colors.deepPurpleAccent,
          btnOkOnPress: () async {
            // create club
            var club = Club(
                name: clubNameController.text,
                description: clubDescriptionController.text,
                privacy: switchVal ? 1 : 0);
            var result = await createClub(club);

            if (result) {
              setState(() {
                _clubFuture = fetchClubs();
              });
              clubNameController.clear();
              clubDescriptionController.clear();
            } else {
              // result creation error
            }
          })
        ..show();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      // appBar: AppBar(
      //   brightness: Theme.of(context).brightness,
      //   backgroundColor: Theme.of(context).backgroundColor,
      //   centerTitle: false,
      //   elevation: 0.0,
      //   iconTheme: IconThemeData(color: Theme.of(context).accentColor),
      //   title: Text(
      //     "Communities",
      //     style: GoogleFonts.pacifico(
      //       GoogleFonts.quicksand: GoogleFonts.quicksand(
      //           fontSize: 25,
      //           fontWeight: FontWeight.w500,
      //           color: Theme.of(context).accentColor),
      //     ),
      //   ),
      //   actions: <Widget>[
      //     IconButton(
      //       icon: Icon(Icons.add, color: Theme.of(context).accentColor),
      //       onPressed: () {
      //         addClubDialog();
      //       },
      //     )
      //   ],
      // ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: Stack(
          children: <Widget>[
            ListView(
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              children: <Widget>[
                Container(
                  child: TextField(
                    controller: searchingController,
                    onChanged: (value) {
                      setState(() {
                        filter = value;
                      });
                    },
                    decoration: new InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                          left: 20, bottom: 11, top: 11, right: 15),
                      hintText: "Search Communities...",
                      hintStyle: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).accentColor),
                    ),
                    style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).accentColor),
                  ),
                ),
                searchedClubs.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount:
                            searchedClubs != null ? searchedClubs.length : 0,
                        itemBuilder: (BuildContext context, int index) {
                          Club club = searchedClubs[index];
                          Function delete = () async {
                            Navigator.pop(context);
                            var res = await deleteClub(club);
                            if (res) {
                              setState(() {
                                _clubFuture = fetchClubs();
                              });
                            }
                          };

                          return Column(
                            children: <Widget>[
                              ClubWidget(club: club, delete: delete),
                              Divider(),
                            ],
                          );
                        },
                      )
                    : FutureBuilder(
                        future: _clubFuture,
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting)
                            return Center(
                                child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: LoadingIndicator(
                                      indicatorType: Indicator.ballClipRotate,
                                      color: Theme.of(context).accentColor,
                                    )));
                          else if (snap.hasData)
                            return ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount:
                                  snap.data != null ? snap.data.length : 0,
                              itemBuilder: (BuildContext context, int index) {
                                Club club = snap.data[index];
                                Function delete = () async {
                                  Navigator.pop(context);
                                  await deleteClub(club);
                                  setState(() {
                                    _clubFuture = fetchClubs();
                                  });
                                };

                                if (index == 0) {
                                  return Column(children: [
                                    oneHealingSpace(),
                                    filter == null || filter.trim() == ""
                                        ? Column(
                                            children: <Widget>[
                                              ClubWidget(
                                                  club: club, delete: delete),
                                              Divider(),
                                            ],
                                          )
                                        : club.name
                                                .toLowerCase()
                                                .trim()
                                                .contains(
                                                    filter.toLowerCase().trim())
                                            ? Column(
                                                children: <Widget>[
                                                  ClubWidget(
                                                      club: club,
                                                      delete: delete),
                                                  Divider(),
                                                ],
                                              )
                                            : new Container()
                                  ]);
                                } else {
                                  return filter == null || filter.trim() == ""
                                      ? Column(
                                          children: <Widget>[
                                            ClubWidget(
                                                club: club, delete: delete),
                                            Divider(),
                                          ],
                                        )
                                      : club.name.toLowerCase().trim().contains(
                                              filter.toLowerCase().trim())
                                          ? Column(
                                              children: <Widget>[
                                                ClubWidget(
                                                    club: club, delete: delete),
                                                Divider(),
                                              ],
                                            )
                                          : new Container();
                                }
                              },
                            );
                          else if (snap.hasError)
                            return Center(
                              child: Container(
                                child: Center(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.face,
                                        color: Theme.of(context).accentColor,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Cannot find any clubs :(",
                                        style: GoogleFonts.quicksand(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                Theme.of(context).accentColor),
                                      ),
                                    ],
                                  ),
                                ),
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
                                      color: Theme.of(context).accentColor,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "There are no clubs :(",
                                      style: GoogleFonts.quicksand(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).accentColor),
                                    ),
                                  ],
                                ),
                              ),
                            );
                        }),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 40,
        height: 40,
        child: FloatingActionButton(
          heroTag: 'btn1',
          backgroundColor: Colors.deepPurpleAccent,
          child: Icon(Entypo.plus, color: Colors.white),
          onPressed: () async {
            addClubDialog();
          },
        ),
      ),
    );
  }

  Widget oneHealingSpace() {
    return _oneHealingSpace != null
        ? InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          OHSMainPage(club: _oneHealingSpace)));
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                    ),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: _oneHealingSpace.imgUrl != null
                              ? _oneHealingSpace.imgUrl
                              : '',
                          width: MediaQuery.of(context).size.width,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 0.0,
                          left: 0.0,
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                Colors.deepPurple,
                                Colors.pinkAccent
                              ])),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    10.0, 5.0, 10.0, 5.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.star,
                                        color: Colors.white, size: 15.0),
                                    SizedBox(width: 10.0),
                                    Text(
                                      'Featured Club',
                                      style: GoogleFonts.quicksand(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0.0,
                          right: 0.0,
                          child: InkWell(
                            onTap: () async {
                              if (_oneHealingSpace.adminId ==
                                  fAuth.currentUser.uid) {
                                return;
                              } else {
                                if (_oneHealingSpace.inClub) {
                                  setState(() {
                                    _oneHealingSpace.inClub = false;
                                  });
                                  var res = await OneHealingSpace.leave();
                                  if (res == false) {
                                    setState(() {
                                      _oneHealingSpace.inClub = true;
                                    });
                                  }
                                } else {
                                  setState(() {
                                    _oneHealingSpace.inClub = true;
                                  });
                                  var res = await OneHealingSpace.join();
                                  if (res == false) {
                                    setState(() {
                                      _oneHealingSpace.inClub = false;
                                    });
                                  }
                                }
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                Colors.deepPurple,
                                Colors.pinkAccent
                              ])),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  _oneHealingSpace.adminId ==
                                          fAuth.currentUser.uid
                                      ? 'Created by you'
                                      : _oneHealingSpace.inClub
                                          ? 'Leave Community'
                                          : 'Join Community',
                                  style: GoogleFonts.quicksand(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
            ),
          )
        : Container(
            width: MediaQuery.of(context).size.width,
            height: 150,
            color: Colors.grey[100],
          );
  }

  @override
  void initState() {
    super.initState();
    _clubFuture = fetchClubs();
    OneHealingSpace.object().then((value) {
      setState(() {
        _oneHealingSpace = value;
      });
    });
  }

  Future<Null> refresh() async {
    OneHealingSpace.object().then((value) {
      setState(() {
        _oneHealingSpace = value;
        _clubFuture = fetchClubs();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    clubNameController.dispose();
    clubDescriptionController.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
