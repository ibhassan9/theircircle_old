import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ChatPage.dart';
import 'package:unify/pages/ProfilePage.dart';

class SearchUserWidget extends StatefulWidget {
  final PostUser peer;
  final Function show;
  SearchUserWidget({Key key, @required this.peer, @required this.show})
      : super(key: key);
  @override
  _SearchUserWidgetState createState() => _SearchUserWidgetState();
}

class _SearchUserWidgetState extends State<SearchUserWidget> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
      child: InkWell(
        onTap: () {},
        child: Row(
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
                            child: Icon(AntDesign.user,
                                color: Colors.white, size: 15.0),
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.network(
                            widget.peer.profileImgUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
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
                                        indicatorType: Indicator.ballClipRotate,
                                        color: Theme.of(context).accentColor,
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
                      widget.peer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.quicksand(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
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
              child: Container(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 7.0, 10.0, 7.0),
                    child: Text(
                      'Message',
                      style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                  ),
                  decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      borderRadius: BorderRadius.circular(3.0))),
            )
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
