import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/match.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ChatPage.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:unify/pages/UserSearchPage.dart';

class MyConversationWidget extends StatefulWidget {
  final String peerId;
  final String lastMessage;
  final String chatId;
  final int timestamp;
  final Function reload;
  final String timeAgo;
  final PostUser peer;
  final bool seen;
  final String lastMessageSenderId;
  MyConversationWidget(
      {Key key,
      @required this.peerId,
      @required this.lastMessage,
      @required this.chatId,
      @required this.timestamp,
      this.reload,
      this.timeAgo,
      this.peer,
      this.seen,
      this.lastMessageSenderId})
      : super(key: key);
  @override
  _MyConversationWidgetState createState() => _MyConversationWidgetState();
}

class _MyConversationWidgetState extends State<MyConversationWidget>
    with AutomaticKeepAliveClientMixin {
  //String time = '';
  //PostUser peer;
  bool imgLoadedBefore = false;
  Widget build(BuildContext context) {
    super.build(context);
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      closeOnScroll: true,
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.white,
          icon: FlutterIcons.delete_ant,
          closeOnTap: true,
          onTap: () {
            final act = CupertinoActionSheet(
              title: Text(
                "PROCEED?",
                style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
              message: Text(
                "Are you sure you want to delete this chat? This will not clear the conversation.",
                style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
              actions: [
                CupertinoActionSheetAction(
                    child: Text(
                      "YES",
                      style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                    onPressed: () {
                      removeChat(widget.peerId);
                      Navigator.pop(context);
                    }),
                CupertinoActionSheetAction(
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.red),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ],
            );
            showCupertinoModalPopup(
                context: context, builder: (BuildContext context) => act);
          },
        )
      ],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatPage(
                          receiver: widget.peer,
                          chatId: widget.chatId,
                        )));
          },
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    widget.peer != null
                        ? widget.peer.profileImgUrl == null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(70),
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey,
                                  child:
                                      Icon(AntDesign.user, color: Colors.white),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(70),
                                child: Image.network(
                                  widget.peer.profileImgUrl,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return SizedBox(
                                      height: 70,
                                      width: 70,
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
                              )
                        : SizedBox(),
                    SizedBox(width: 15.0),
                    widget.peer != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.peer.name,
                                  style: GoogleFonts.quicksand(
                                    textStyle: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black),
                                  )),
                              SizedBox(height: 5.0),
                              Row(
                                children: [
                                  widget.lastMessageSenderId != widget.peer.id
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10.0),
                                          child: Text('You:',
                                              style: GoogleFonts.quicksand(
                                                textStyle: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        Colors.grey.shade600),
                                              )),
                                        )
                                      : Container(),
                                  Text(widget.lastMessage,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.quicksand(
                                        textStyle: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade600),
                                      )),
                                ],
                              ),
                              SizedBox(height: 5.0),
                              Text(widget.timeAgo,
                                  style: GoogleFonts.quicksand(
                                    textStyle: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey),
                                  )),
                            ],
                          )
                        : SizedBox(),
                  ],
                ),
                Visibility(
                    visible: widget.seen == false,
                    child: CircleAvatar(
                        radius: 4.0, backgroundColor: Colors.blue)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;
}
