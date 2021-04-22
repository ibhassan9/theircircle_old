import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_unicons/unicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:unify/Models/notification.dart';
import 'package:unify/Models/room.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/widgets/AddUserWidget.dart';
import 'package:unify/widgets/SearchUserWidget.dart';
import 'package:unify/Components/Constants.dart';

class AddUserPage extends StatefulWidget {
  final Room room;
  AddUserPage({Key key, this.room}) : super(key: key);
  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage>
    with AutomaticKeepAliveClientMixin {
  TextEditingController bioController = TextEditingController();

  TextEditingController snapchatController = TextEditingController();

  TextEditingController instagramController = TextEditingController();

  TextEditingController linkedinController = TextEditingController();

  TextEditingController searchingController = TextEditingController();

  String filter;

  List<PostUser> selectedUsers = [];

  bool updating = false;
  bool loading = true;
  List<PostUser> allUsers = [];

  Future<List<PostUser>> _searchFuture = myCampusUsers();

  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          elevation: 0.5,
          centerTitle: true,
          iconTheme: IconThemeData(color: Theme.of(context).accentColor),
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Unicon(UniconData.uniArrowLeft,
                  color: Theme.of(context).accentColor),
            ),
          ),
          actions: [
            updating
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: SizedBox(
                          width: 10,
                          height: 10,
                          child: LoadingIndicator(
                              indicatorType: Indicator.circleStrokeSpin,
                              color: Theme.of(context).accentColor)),
                    ),
                  )
                : IconButton(
                    icon: Unicon(UniconData.uniSave,
                        color: Theme.of(context).accentColor),
                    onPressed: () async {
                      setState(() {
                        updating = true;
                      });
                      var res = await Room.addMembers(
                          members: selectedUsers, roomId: widget.room.id);
                      if (res) {
                        setState(() {
                          updating = false;
                        });
                        for (var user in selectedUsers) {
                          pushAddedToRoom(
                              room: widget.room, receiverId: user.device_token);
                        }
                        Navigator.pop(context, true);
                      }
                    },
                  )
          ],
          leadingWidth: 35,
          title: Hero(
            tag: 'searchBar_tag',
            child: Container(
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
                    hintText: "Search students..."),
                style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              ),
            ),
          ),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (_) {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Stack(children: [
            ListView(children: [
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
              //         style: GoogleFonts.manrope(
              // fontFamily: Constants.fontFamily,
              //             fontSize: 15,
              //             fontWeight: FontWeight.w500,
              //             color: Theme.of(context).accentColor),
              //       ),
              //     ),
              //   ),
              // ),
              loading
                  ? SizedBox(
                      width: 15,
                      height: 15,
                      child: LoadingIndicator(
                          indicatorType: Indicator.circleStrokeSpin,
                          color: Theme.of(context).accentColor))
                  : ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: allUsers.length,
                      itemBuilder: (BuildContext context, int i) {
                        PostUser user = allUsers[i];
                        Function add = () {
                          setState(() {
                            selectedUsers.add(user);
                          });
                        };
                        Function delete = () {
                          setState(() {
                            selectedUsers.remove(user);
                          });
                        };
                        return filter == null || filter.trim() == ""
                            ? AddUserWidget(
                                peer: user,
                                add: add,
                                delete: delete,
                                selectedUsers: selectedUsers)
                            : user.name
                                    .toLowerCase()
                                    .trim()
                                    .contains(filter.toLowerCase().trim())
                                ? AddUserWidget(
                                    peer: user,
                                    add: add,
                                    delete: delete,
                                    selectedUsers: selectedUsers)
                                : new Container();
                      },
                    )
            ])
          ]),
        ));
  }

  @override
  void initState() {
    super.initState();
    myCampusUsers().then((value) {
      List<PostUser> users = [];
      for (var user in value) {
        if (widget.room.members.any((e) => e.id == user.id)) {
        } else {
          users.add(user);
        }
      }
      setState(() {
        allUsers = users;
        loading = false;
      });
    });
  }

  Future<Null> refresh() async {
    this.setState(() {
      _searchFuture = myCampusUsers();
    });
  }

  @override
  bool get wantKeepAlive => true;
}
