import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ChatPage.dart';
import 'package:unify/pages/ProfilePage.dart';

class PollResultWidget extends StatefulWidget {
  final PostUser peer;
  final Function show;
  final String question;
  PollResultWidget(
      {Key key,
      @required this.peer,
      @required this.show,
      @required this.question})
      : super(key: key);
  @override
  _PollResultWidgetState createState() => _PollResultWidgetState();
}

class _PollResultWidgetState extends State<PollResultWidget> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
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
                              borderRadius: BorderRadius.circular(70),
                              child: Container(
                                width: 40,
                                height: 40,
                                color: Colors.grey,
                                child:
                                    Icon(AntDesign.user, color: Colors.white),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(70),
                              child: Image.network(
                                widget.peer.profileImgUrl,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                Colors.grey.shade600),
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes
                                            : null,
                                      ),
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
                        Text(widget.peer.name,
                            style: GoogleFonts.manjari(
                              textStyle: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black),
                            )),
                        Text('Voted: ' + widget.question,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manjari(
                              textStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black),
                            )),
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
                  child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(FlutterIcons.message_mdi,
                          color: Colors.deepPurpleAccent)),
                )
              ],
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
