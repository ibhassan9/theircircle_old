import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.black),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Find students",
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (_) {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Stack(children: [
            ListView(children: [
              Container(
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
                          left: 15, bottom: 11, top: 11, right: 15),
                      hintText: "Search users..."),
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
              ),
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
                            showProfile(
                                user,
                                context,
                                bioController,
                                snapchatController,
                                instagramController,
                                linkedinController,
                                null,
                                null);
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
                      return Center(child: Text("No data"));
                    }
                  })
            ])
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
