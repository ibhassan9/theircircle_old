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

class _ClubsPageState extends State<ClubsPage> {
  TextEditingController clubNameController = TextEditingController();
  TextEditingController clubDescriptionController = TextEditingController();
  TextEditingController searchingController = TextEditingController();

  List<Club> clubs = List<Club>();
  List<Club> searchedClubs = List<Club>();
  bool isSearching = false;
  String filter;

  Future<List<Club>> _future;

  @override
  Widget build(BuildContext context) {
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
                    style: GoogleFonts.quicksand(
                      textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
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
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
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
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
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
                          style: GoogleFonts.quicksand(
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
                _future = fetchClubs();
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "Clubs",
          style: GoogleFonts.quicksand(
            textStyle: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add, color: Colors.black),
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
                      // searchedClubs = [];
                      // if (value.isEmpty) {
                      //   setState(() {
                      //     searchedClubs = [];
                      //   });
                      // } else {
                      //   value = value.toLowerCase();
                      //   for (var club in clubs) {
                      //     if (club.name.toLowerCase().contains(value)) {
                      //       if (searchedClubs.contains(club)) {
                      //       } else {
                      //         searchedClubs.add(club);
                      //       }
                      //     }
                      //   }
                      //   setState(() {});
                      // }
                    },
                    decoration: new InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                            left: 15, bottom: 11, top: 11, right: 15),
                        hintText: "Search Clubs..."),
                    style: GoogleFonts.quicksand(
                      textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
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
                              setState(() {});
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
                        future: fetchClubs(),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting)
                            return Center(
                                child: CircularProgressIndicator(
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
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 10),
                                    Text("Cannot find any clubs :(",
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
                                    Text("There are no clubs :(",
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
  }

  Future<Null> refresh() async {
    this.setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    clubNameController.dispose();
    clubDescriptionController.dispose();
  }
}
