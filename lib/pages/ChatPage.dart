import 'dart:async';

import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_unicons/unicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:timeago/timeago.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/message.dart';
import 'package:unify/Models/notification.dart';
import 'package:unify/Models/product.dart';
import 'package:unify/Models/user.dart' as u;
import 'package:unify/pages/ProfilePage.dart';
import 'package:unify/widgets/ChatBubbleLeft.dart';
import 'package:unify/widgets/ChatBubbleRight.dart';
import 'package:unify/widgets/SayHiWidget.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final u.PostUser receiver;
  final String chatId;
  final Product prod;
  ChatPage({Key key, @required this.receiver, @required this.chatId, this.prod})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with AutomaticKeepAliveClientMixin {
  TextEditingController chatController = TextEditingController();
  var uniKey = Constants.checkUniversity();
  var myID = firebaseAuth.currentUser.uid;
  var db = FirebaseDatabase.instance.reference().child('chats');
  TextEditingController bioController = TextEditingController();
  TextEditingController snapchatController = TextEditingController();
  TextEditingController linkedinController = TextEditingController();
  TextEditingController instagramController = TextEditingController();
  ScrollController _scrollController = new ScrollController();
  Stream<Event> myChat;
  bool seen = false;
  bool isSending = false;
  int renders = 0;
  bool listRendered = false;
  Product prod;

  Widget build(BuildContext context) {
    super.build(context);

    Padding chatBox = Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            border:
                Border(top: BorderSide(color: Theme.of(context).dividerColor))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          child: Container(
            height:
                prod == null ? 50 : MediaQuery.of(context).size.height / 5.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                prod != null
                    ? Padding(
                        padding: const EdgeInsets.only(
                            left: 5.0, right: 5.0, bottom: 5.0),
                        child: Stack(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height / 8,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: prod != null
                                              ? prod.imgUrls[0]
                                              : '',
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              8,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              5,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          prod.title +
                                              ' • ' +
                                              r'$' +
                                              prod.price,
                                          style: GoogleFonts.quicksand(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black),
                                        ),
                                        // Text(
                                        //   r'$ ' + prod.price,
                                        //   style: GoogleFonts.lexendDeca(
                                        //     GoogleFonts.overpass: TextStyle(
                                        //  fontFamily: Constants.fontFamily,
                                        //         fontSize: 13,
                                        //         fontWeight: FontWeight.w700,
                                        //         color: Colors.black),
                                        //   ),
                                        // ),
                                        Text(
                                          prod.description,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.quicksand(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Positioned(
                              top: 0.0,
                              right: 0.0,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 5.0, right: 5.0),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      prod = null;
                                    });
                                  },
                                  child: CircleAvatar(
                                    radius: 13.0,
                                    backgroundColor: Colors.white,
                                    child: Icon(FlutterIcons.remove_mdi,
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    : Container(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                        child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor,
                          borderRadius: BorderRadius.circular(20.0)),
                      child: TextField(
                        onTap: () {
                          Timer(
                              Duration(milliseconds: 300),
                              () => _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeIn));
                        },
                        textInputAction: TextInputAction.done,
                        maxLines: null,
                        controller: chatController,
                        decoration: new InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                              left: 15, bottom: 11, top: 11, right: 15),
                          hintText: "Insert message here",
                          hintStyle: GoogleFonts.quicksand(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).accentColor),
                        ),
                        style: GoogleFonts.quicksand(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).accentColor),
                      ),
                    )),
                    isSending
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                                height: 10,
                                width: 10,
                                child: LoadingIndicator(
                                  indicatorType: Indicator.circleStrokeSpin,
                                  color: Theme.of(context).accentColor,
                                )),
                          )
                        : IconButton(
                            icon: Icon(
                              FlutterIcons.send_mdi,
                              color: Theme.of(context).accentColor,
                            ),
                            onPressed: () async {
                              if (chatController.text.isEmpty || isSending) {
                                return;
                              }

                              setState(() {
                                isSending = true;
                              });
                              var res = await sendMessage(
                                  chatController.text,
                                  widget.receiver.id,
                                  widget.chatId,
                                  prod != null ? prod.id : null);
                              if (res) {
                                await sendPushChat(
                                    widget.receiver.device_token,
                                    chatController.text,
                                    widget.receiver.id,
                                    widget.chatId,
                                    widget.receiver.id);
                                chatController.clear();
                                setState(() {
                                  isSending = false;
                                  prod = null;
                                });
                                _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent +
                                      10,
                                  curve: Curves.easeOut,
                                  duration: const Duration(milliseconds: 300),
                                );
                              }
                            },
                          )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        toolbarHeight: 100,
        elevation: 30.0,
        shadowColor: Theme.of(context).dividerColor.withOpacity(0.5),
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
        title: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: CachedNetworkImage(
                  imageUrl: widget.receiver.profileImgUrl,
                  width: 35.0,
                  height: 35.0,
                  fit: BoxFit.cover),
            ),
            SizedBox(height: 5.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.receiver.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).accentColor),
                ),
                SizedBox(height: 3.0),
                Text(
                  widget.receiver.about != null ? widget.receiver.about : '',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).buttonColor),
                ),
              ],
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(FlutterIcons.person_mdi,
                color: Theme.of(context).accentColor),
            onPressed: () {
              // showBarModalBottomSheet(
              //     context: context,
              //     expand: true,
              //     builder: (context) => ProfilePage(
              //         user: widget.receiver,
              //         heroTag: widget.receiver.id,
              //         isFromChat: true));
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfilePage(
                          user: widget.receiver,
                          heroTag: widget.receiver.id,
                          isFromChat: true)));
            },
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Stack(children: [
          ListView(
            controller: _scrollController,
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              StreamBuilder(
                stream: myChat,
                builder: (context, snap) {
                  if (snap.hasData &&
                      !snap.hasError &&
                      snap.data.snapshot.value != null) {
                    Map data = snap.data.snapshot.value;
                    List<Message> messages = [];
                    for (var key in data.keys) {
                      Message msg = Message(
                          id: key,
                          messageText: data[key]['messageText'],
                          receiverId: data[key]['receiverId'],
                          senderId: data[key]['senderId'],
                          timestamp: data[key]['timeStamp']);
                      if (data[key]['prodId'] != null) {
                        msg.productId = data[key]['prodId'];
                      }
                      messages.add(msg);
                    }

                    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

                    if (messages.isNotEmpty) {
                      if (seen == false) {
                        seen = true;
                        setSeen(widget.receiver.id);
                      }
                    }

                    Function scroll = () {
                      Timer(
                          Duration(milliseconds: 300),
                          () => _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeIn));
                    };

                    return ListView.builder(
                      shrinkWrap: true,
                      reverse: false,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        renders += 1;
                        if (renders == messages.length - 1) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollController.jumpTo(
                                _scrollController.position.maxScrollExtent);
                          });
                        }

                        Message msg = messages[index];
                        var date =
                            DateTime.fromMillisecondsSinceEpoch(msg.timestamp);
                        var formattedDate = DateFormat.yMMMd().format(date);
                        var date_now = DateTime.now();
                        var formattedNow = DateFormat.yMMMd().format(date_now);
                        if (index == 0) {
                          if (msg.senderId == myID) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Column(
                                children: [
                                  Text(
                                    formattedDate == formattedNow
                                        ? "Today"
                                        : formattedDate,
                                    style: GoogleFonts.quicksand(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .accentColor
                                            .withOpacity(0.7)),
                                  ),
                                  ChatBubbleRight(
                                      msg: msg,
                                      scroll: scroll,
                                      meLastSender: index == 0
                                          ? true
                                          : messages[index - 1].senderId ==
                                                      firebaseAuth
                                                          .currentUser.uid ||
                                                  (formattedDate !=
                                                          formattedNow &&
                                                      messages[index - 1]
                                                              .senderId ==
                                                          firebaseAuth
                                                              .currentUser.uid)
                                              ? false
                                              : true),
                                ],
                              ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Column(
                                children: [
                                  Text(
                                    formattedDate == formattedNow
                                        ? "Today"
                                        : formattedDate,
                                    style: GoogleFonts.quicksand(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .accentColor
                                            .withOpacity(0.7)),
                                  ),
                                  ChatBubbleLeft(
                                      user: widget.receiver,
                                      msg: msg,
                                      scroll: scroll,
                                      meLastSender: index == 0
                                          ? true
                                          : messages[index - 1].senderId ==
                                                      msg.senderId ||
                                                  formattedDate != formattedNow
                                              ? false
                                              : true),
                                ],
                              ),
                            );
                          }
                        } else {
                          if (index > 0) {
                            Message _old = messages[index - 1];
                            var _date = DateTime.fromMillisecondsSinceEpoch(
                                _old.timestamp);
                            var _formattedDate =
                                DateFormat.yMMMd().format(_date);
                            if (_formattedDate == formattedDate) {
                              if (msg.senderId == myID) {
                                return ChatBubbleRight(
                                    msg: msg,
                                    scroll: scroll,
                                    meLastSender: index == 0
                                        ? true
                                        : messages[index - 1].senderId ==
                                                    firebaseAuth
                                                        .currentUser.uid ||
                                                (formattedDate !=
                                                        formattedNow &&
                                                    messages[index - 1]
                                                            .senderId ==
                                                        firebaseAuth
                                                            .currentUser.uid)
                                            ? false
                                            : true);
                              } else {
                                return ChatBubbleLeft(
                                    user: widget.receiver,
                                    msg: msg,
                                    scroll: scroll,
                                    meLastSender: index == 0
                                        ? true
                                        : messages[index - 1].senderId ==
                                                    msg.senderId ||
                                                (formattedDate !=
                                                        formattedNow &&
                                                    messages[index - 1]
                                                            .senderId ==
                                                        msg.senderId)
                                            ? false
                                            : true);
                              }
                            } else {
                              if (msg.senderId == myID) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        formattedDate == formattedNow
                                            ? "Today"
                                            : formattedDate,
                                        style: GoogleFonts.quicksand(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context)
                                                .accentColor
                                                .withOpacity(0.7)),
                                      ),
                                      ChatBubbleRight(
                                          msg: msg,
                                          scroll: scroll,
                                          meLastSender: index == 0
                                              ? true
                                              : messages[index - 1].senderId ==
                                                          firebaseAuth
                                                              .currentUser
                                                              .uid ||
                                                      (formattedDate !=
                                                              formattedNow &&
                                                          messages[index - 1]
                                                                  .senderId ==
                                                              firebaseAuth
                                                                  .currentUser
                                                                  .uid)
                                                  ? false
                                                  : true),
                                    ],
                                  ),
                                );
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        formattedDate == formattedNow
                                            ? "Today"
                                            : formattedDate,
                                        style: GoogleFonts.quicksand(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context)
                                                .accentColor
                                                .withOpacity(0.7)),
                                      ),
                                      ChatBubbleLeft(
                                          user: widget.receiver,
                                          msg: msg,
                                          scroll: scroll,
                                          meLastSender: index == 0
                                              ? true
                                              : messages[index - 1].senderId ==
                                                          msg.senderId ||
                                                      (formattedDate !=
                                                              formattedNow &&
                                                          messages[index - 1]
                                                                  .senderId ==
                                                              msg.senderId)
                                                  ? false
                                                  : true),
                                    ],
                                  ),
                                );
                              }
                            }
                          } else {
                            if (msg.senderId == myID) {
                              return ChatBubbleRight(
                                  msg: msg,
                                  scroll: scroll,
                                  meLastSender: index == 0
                                      ? true
                                      : messages[index - 1].senderId ==
                                                  firebaseAuth
                                                      .currentUser.uid ||
                                              (formattedDate != formattedNow &&
                                                  messages[index - 1]
                                                          .senderId ==
                                                      firebaseAuth
                                                          .currentUser.uid)
                                          ? false
                                          : true);
                            } else {
                              return ChatBubbleLeft(
                                  user: widget.receiver,
                                  msg: msg,
                                  scroll: scroll,
                                  meLastSender: index == 0
                                      ? true
                                      : messages[index - 1].senderId ==
                                                  msg.senderId ||
                                              (formattedDate != formattedNow &&
                                                  messages[index - 1]
                                                          .senderId ==
                                                      msg.senderId)
                                          ? false
                                          : true);
                            }
                          }
                        }
                      },
                    );
                  } else
                    return Center(
                        child: SayHiWidget(receiver: widget.receiver));
                },
              ),
            ],
          )
        ]),
      ),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0), child: chatBox),
    );
  }

  Widget userBar() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
          child: Row(children: [
        widget.receiver.profileImgUrl == null ||
                widget.receiver.profileImgUrl == ''
            ? ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  width: 40,
                  height: 40,
                  color: Theme.of(context).dividerColor,
                  child: Center(
                    child: Icon(Feather.feather,
                        color: Theme.of(context).accentColor, size: 15.0),
                  ),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.network(
                  widget.receiver.profileImgUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: Container(
                          width: 40,
                          height: 40,
                          color: Theme.of(context).dividerColor),
                    );
                  },
                ),
              ),
        SizedBox(width: 5.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.receiver.name.split(' ').first,
              style: GoogleFonts.quicksand(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).accentColor),
            ),
            widget.receiver.about != null && widget.receiver.about.isNotEmpty
                ? Text(
                    widget.receiver.about,
                    maxLines: 1,
                    style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).accentColor),
                  )
                : Container(),
          ],
        )
      ]))
    ]);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var chats = db
        .child(uniKey == 0
            ? 'UofT'
            : uniKey == 1
                ? 'YorkU'
                : 'WesternU')
        .child(widget.chatId);
    myChat = chats.onValue;
    // chats.onChildAdded.listen((event) {
    //   print('event received');
    //   _scrollController.animateTo(_scrollController.position.maxScrollExtent,
    //       duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    // });
    prod = widget.prod;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    chatController.dispose();
    _scrollController.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
