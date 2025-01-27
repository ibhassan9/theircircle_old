import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/widgets/SearchUserWidget.dart';

class UserSearchPage extends StatefulWidget {
  @override
  _UserSearchPageState createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage>
    with AutomaticKeepAliveClientMixin {
  TextEditingController bioController = TextEditingController();

  TextEditingController snapchatController = TextEditingController();

  TextEditingController instagramController = TextEditingController();

  TextEditingController linkedinController = TextEditingController();

  TextEditingController searchingController = TextEditingController();

  String filter;

  Future<List<PostUser>> _searchFuture = myCampusUsers();

  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Theme.of(context).accentColor),
          // leading: InkWell(
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          //   child: Padding(
          //     padding: const EdgeInsets.only(left: 10.0),
          //     child: Unicon(UniconData.uniArrowLeft,
          //         color: Theme.of(context).accentColor),
          //   ),
          // ),
          leading: Container(),
          leadingWidth: 0,
          title: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5)),
            child: Row(
              children: [
                SizedBox(width: 10.0),
                Icon(FlutterIcons.search_fea,
                    size: 20.0, color: Theme.of(context).accentColor),
                Flexible(
                  child: TextField(
                    textInputAction: TextInputAction.done,
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
                            left: 10, bottom: 11.5, top: 11, right: 15),
                        hintText: "Search"),
                    style: GoogleFonts.quicksand(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).accentColor),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
              child: Center(
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.quicksand(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).accentColor.withOpacity(0.7)),
                  ),
                ),
              ),
            )
          ],
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (_) {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: ListView(physics: AlwaysScrollableScrollPhysics(), children: [
            // Hero(
            //   tag: 'searchBar_tag',
            //   child: Material(
            //     child: Container(
            //       child: TextField(
            //         textInputAction: TextInputAction.done,
            //         controller: searchingController,
            //         onChanged: (value) {
            //           setState(() {
            //             filter = value;
            //           });
            //         },
            //         decoration: new InputDecoration(
            //             border: InputBorder.none,
            //             focusedBorder: InputBorder.none,
            //             enabledBorder: InputBorder.none,
            //             errorBorder: InputBorder.none,
            //             disabledBorder: InputBorder.none,
            //             contentPadding: EdgeInsets.only(
            //                 left: 15, bottom: 11, top: 11, right: 15),
            //             hintText: "Search students..."),
            //         style: GoogleFonts. inter(
            // fontFamily: Constants.fontFamily,
            //             fontSize: 15,
            //             fontWeight: FontWeight.w500,
            //             color: Theme.of(context).accentColor),
            //       ),
            //     ),
            //   ),
            // ),
            FutureBuilder(
                future: _searchFuture,
                builder: (context, snap) {
                  if (snap.hasData && snap.data.length != 0) {
                    return ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snap.data != null ? snap.data.length : 0,
                      itemBuilder: (BuildContext context, int i) {
                        PostUser user = snap.data[i];
                        Function f = () {
                          // showProfile(
                          //     user,
                          //     context,
                          //     bioController,
                          //     snapchatController,
                          //     instagramController,
                          //     linkedinController,
                          //     null,
                          //     null);
                        };
                        return filter == null || filter.trim() == ""
                            ? SearchUserWidget(peer: user, show: f)
                            : user.name
                                    .toLowerCase()
                                    .trim()
                                    .contains(filter.toLowerCase().trim())
                                ? SearchUserWidget(peer: user, show: f)
                                : new Container();
                      },
                    );
                  } else {
                    return Center(
                      child: SizedBox(
                        height: 30,
                        width: 30,
                        child: Center(
                          child: SizedBox(
                              width: 10,
                              height: 10,
                              child: LoadingIndicator(
                                indicatorType: Indicator.ballClipRotateMultiple,
                                color: Theme.of(context).accentColor,
                              )),
                        ),
                      ),
                    );
                  }
                })
          ]),
        ));
  }

  @override
  void initState() {
    super.initState();
    _searchFuture = myCampusUsers();
  }

  Future<Null> refresh() async {
    this.setState(() {
      _searchFuture = myCampusUsers();
    });
  }

  @override
  bool get wantKeepAlive => true;
}
