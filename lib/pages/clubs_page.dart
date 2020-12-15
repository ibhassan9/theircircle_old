import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Widgets/ClubWidget.dart';
import 'package:unify/Widgets/CourseWidget.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart';

class ClubsPage extends StatefulWidget {
  @override
  _ClubsPageState createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage>
    with AutomaticKeepAliveClientMixin {
  TextEditingController clubNameController = TextEditingController();
  TextEditingController clubDescriptionController = TextEditingController();
  TextEditingController searchingController = TextEditingController();

  List<Club> clubs = List<Club>();
  List<Club> searchedClubs = List<Club>();
  bool isSearching = false;
  String filter;

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
                    "Create a Virtual Club",
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).accentColor),
                    ),
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
                          left: 15, bottom: 11, top: 11, right: 15),
                      hintText: "Ex. Football Society"),
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).accentColor),
                  ),
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
                          left: 15, bottom: 11, top: 11, right: 15),
                      hintText: "Describe your club here..."),
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).accentColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Privacy",
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey),
                          ),
                        ),
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
          btnOkColor: Colors.deepOrange,
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
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        backgroundColor: Theme.of(context).backgroundColor,
        centerTitle: true,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Theme.of(context).accentColor),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "CLUBS",
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).accentColor),
                  ),
                ),
                // Text(
                //   "Start or join a club!",
                //   style: GoogleFonts.poppins(
                //     textStyle: TextStyle(
                //         fontSize: 12,
                //         fontWeight: FontWeight.w500,
                //         color: Theme.of(context).accentColor),
                //   ),
                // ),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add, color: Theme.of(context).accentColor),
            onPressed: () {
              addClubDialog();
            },
          )
        ],
      ),
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
                          left: 15, bottom: 11, top: 11, right: 15),
                      hintText: "Search Clubs...",
                      hintStyle: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).accentColor),
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).accentColor),
                    ),
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
                                child: CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).accentColor),
                              strokeWidth: 2.0,
                            ));
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
                                  setState(() {});
                                };

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
                              },
                            );
                          else if (snap.hasError)
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
                                    Text("Cannot find any clubs :(",
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .accentColor),
                                        )),
                                  ],
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
                                    Text("There are no clubs :(",
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .accentColor),
                                        )),
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
    );
  }

  @override
  void initState() {
    super.initState();
    _clubFuture = fetchClubs();
  }

  Future<Null> refresh() async {
    this.setState(() {
      _clubFuture = fetchClubs();
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
