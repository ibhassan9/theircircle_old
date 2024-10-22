import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unify/Models/match.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ChatPage.dart';

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
  final Function getBlocks;
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
      this.lastMessageSenderId,
      this.getBlocks})
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
        padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: Theme.of(context).cardColor),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            child: InkWell(
              onTap: () {
                showMaterialModalBottomSheet(
                    context: context,
                    expand: true,
                    builder: (context) => ChatPage(
                          receiver: widget.peer,
                          chatId: widget.chatId,
                        )).then((value) {});
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => ChatPage(
                //               receiver: widget.peer,
                //               chatId: widget.chatId,
                //             ))).then((value) {});
              },
              child: Hero(
                tag: widget.peer.id,
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
                                      borderRadius: BorderRadius.circular(40),
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        color: Colors.deepPurpleAccent,
                                        child: Icon(AntDesign.user,
                                            size: 15.0, color: Colors.white),
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: CachedNetworkImage(
                                        imageUrl: widget.peer.profileImgUrl,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                              : SizedBox(),
                          SizedBox(width: 15.0),
                          Flexible(
                            child: Container(
                              child: widget.peer != null
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                widget.peer.name,
                                                style: GoogleFonts.quicksand(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: Theme.of(context)
                                                        .accentColor),
                                              ),
                                              Text(
                                                widget.timeAgo.toUpperCase(),
                                                style: GoogleFonts.quicksand(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: Theme.of(context)
                                                        .accentColor
                                                        .withOpacity(0.5)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 1.0),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // widget.lastMessageSenderId ==
                                            //         widget.peer.id
                                            //     ? Icon(Feather.message_circle,
                                            //         size: 15.0,
                                            //         color: Colors.lightBlue)
                                            //     : Icon(FlutterIcons.send_mdi,
                                            //         size: 15.0,
                                            //         color: Colors
                                            //             .deepPurpleAccent),
                                            // SizedBox(width: 5.0),
                                            widget.lastMessageSenderId !=
                                                    widget.peer.id
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 5.0),
                                                    child: Text(
                                                      'You:',
                                                      style: GoogleFonts.quicksand(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: widget.seen
                                                              ? Theme.of(
                                                                      context)
                                                                  .buttonColor
                                                              : Colors.blue),
                                                    ),
                                                  )
                                                : Container(),
                                            Flexible(
                                              child: Text(
                                                  widget.lastMessage != null
                                                      ? widget.lastMessage
                                                      : '',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.quicksand(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: widget.seen
                                                        ? Theme.of(context)
                                                            .buttonColor
                                                        : Colors.blue,
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
