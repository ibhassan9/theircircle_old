import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ChatPage.dart';
import 'package:unify/pages/DB.dart';
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
  Color color;

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10.0)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
          child: InkWell(
            onTap: () {
              //widget.show();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePage(
                          user: widget.peer, heroTag: widget.peer.id)));
            },
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      child: Flexible(
                    child: Row(
                      children: [
                        widget.peer.profileImgUrl == null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey,
                                  child: Icon(AntDesign.user,
                                      color: Colors.white, size: 15.0),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: CachedNetworkImage(
                                  imageUrl: widget.peer.profileImgUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                        SizedBox(width: 15.0),
                        Flexible(
                          child: Column(
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
                                        ? '🗣️ ' + widget.peer.about
                                        : "No bio available."
                                    : "No bio available.",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.quicksand(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).buttonColor),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 5.0)
                      ],
                    ),
                  )),
                  InkWell(
                    onTap: () {
                      var chatId = '';
                      var myID = FIR_UID;
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
                          padding:
                              const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
                          child: Text(
                            '👋 Send message',
                            style: GoogleFonts.quicksand(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).accentColor),
                          ),
                        ),
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(1.0))),
                  )
                ]),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    color = Constants.color();
  }
}
