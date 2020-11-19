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
          color: Theme.of(context).backgroundColor,
          icon: FlutterIcons.delete_ant,
          closeOnTap: true,
          onTap: () {
            final act = CupertinoActionSheet(
              title: Text(
                "PROCEED?",
                style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              ),
              message: Text(
                "Are you sure you want to delete this chat? This will not clear the conversation.",
                style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              ),
              actions: [
                CupertinoActionSheetAction(
                    child: Text(
                      "YES",
                      style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).accentColor),
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
            width: MediaQuery.of(context).size.width,
            child: Wrap(
              alignment: WrapAlignment.start,
              children: [
                Row(
                  children: [
                    widget.peer != null
                        ? widget.peer.profileImgUrl == null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.deepPurpleAccent,
                                  child:
                                      Icon(AntDesign.user, color: Colors.white),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(50),
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
                    Flexible(
                      child: Container(
                        child: widget.peer != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(widget.peer.name,
                                            style: GoogleFonts.quicksand(
                                              textStyle: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w700,
                                                  color: Theme.of(context)
                                                      .accentColor),
                                            )),
                                        Text(widget.timeAgo,
                                            style: GoogleFonts.quicksand(
                                              textStyle: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context)
                                                      .accentColor),
                                            )),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5.0),
                                  Row(
                                    children: [
                                      widget.lastMessageSenderId !=
                                              widget.peer.id
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 5.0),
                                              child: Text('You:',
                                                  style: GoogleFonts.quicksand(
                                                    textStyle: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Theme.of(context)
                                                            .accentColor),
                                                  )),
                                            )
                                          : Container(),
                                      Flexible(
                                        child: Text(widget.lastMessage,
                                            maxLines: null,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.quicksand(
                                              textStyle: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context)
                                                      .accentColor),
                                            )),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : SizedBox(),
                      ),
                    ),
                    Visibility(
                        visible: widget.seen == false,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: CircleAvatar(
                              radius: 4.0, backgroundColor: Colors.blue),
                        )),
                  ],
                ),
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
