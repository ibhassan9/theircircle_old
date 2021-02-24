import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_unicons/unicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:unify/Models/room.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ChatPage.dart';
import 'package:unify/pages/ProfilePage.dart';

class AddUserWidget extends StatefulWidget {
  final PostUser peer;
  final Function add;
  final Function delete;
  final List<PostUser> selectedUsers;
  AddUserWidget(
      {Key key,
      @required this.peer,
      @required this.add,
      @required this.delete,
      this.selectedUsers})
      : super(key: key);
  @override
  _AddUserWidgetState createState() => _AddUserWidgetState();
}

class _AddUserWidgetState extends State<AddUserWidget> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  bool isSelected = false;

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 10.0, 10.0, 0.0),
      child: InkWell(
        onTap: () {},
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    //widget.show();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfilePage(
                                user: widget.peer, heroTag: widget.peer.id)));
                  },
                  child: Container(
                      child: Row(children: [
                    Hero(
                      tag: widget.peer.id,
                      child: widget.peer.profileImgUrl == null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey,
                                child: Icon(Ionicons.md_person,
                                    color: Colors.white, size: 30.0),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.network(
                                widget.peer.profileImgUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: Center(
                                      child: SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: LoadingIndicator(
                                            indicatorType:
                                                Indicator.ballClipRotate,
                                            color:
                                                Theme.of(context).accentColor,
                                          )),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                    SizedBox(width: 15.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.peer.name.trim(),
                          style: TextStyle(
                              fontFamily: "Futura1",
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).accentColor),
                        ),
                        Text(
                          widget.peer.about != null
                              ? widget.peer.about.isNotEmpty
                                  ? widget.peer.about
                                  : "No bio available."
                              : "No bio available.",
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).accentColor),
                        ),
                      ],
                    ),
                  ])),
                ),
                InkWell(
                  onTap: () {
                    var chatId = '';
                    var myID = firebaseAuth.currentUser.uid;
                    var peerId = widget.peer.id;
                    if (myID.hashCode <= peerId.hashCode) {
                      chatId = '$myID-$peerId';
                    } else {
                      chatId = '$peerId-$myID';
                    }
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatPage(
                                  receiver: widget.peer,
                                  chatId: chatId,
                                )));
                  },
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 7.0, 10.0, 7.0),
                      child: IconButton(
                          onPressed: () {
                            if (widget.selectedUsers.contains(widget.peer)) {
                              widget.delete();
                            } else {
                              widget.add();
                            }
                          },
                          icon: Icon(
                              widget.selectedUsers.contains(widget.peer) ==
                                      false
                                  ? FlutterIcons.add_circle_mdi
                                  : FlutterIcons.remove_circle_mdi,
                              color: widget.selectedUsers.contains(widget.peer)
                                  ? Colors.red
                                  : Colors.blue))),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
}
