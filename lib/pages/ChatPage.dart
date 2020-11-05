import 'package:bubble/bubble.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/message.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/widgets/ChatBubbleLeft.dart';
import 'package:unify/widgets/ChatBubbleRight.dart';
import 'package:unify/widgets/SayHiWidget.dart';

class ChatPage extends StatefulWidget {
  final PostUser receiver;
  final String chatId;
  ChatPage({Key key, @required this.receiver, @required this.chatId})
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
  Stream<Event> myChat;
  bool seen = false;

  Widget build(BuildContext context) {
    super.build(context);
    Padding chatBox = Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade200))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                  child: Container(
                decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(20.0)),
                child: TextField(
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
                      hintText: "Insert message here"),
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
              )),
              IconButton(
                icon: Icon(
                  FlutterIcons.send_mdi,
                  color: Colors.black,
                ),
                onPressed: () async {
                  if (chatController.text.isEmpty) {
                    return;
                  }
                  var res = await sendMessage(
                      chatController.text, widget.receiver.id, widget.chatId);
                  if (res) {
                    chatController.clear();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.black87),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.receiver.name,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87),
              ),
            ),
            // Text(
            //   "Meet & Make New Friends",
            //   style: GoogleFonts.quicksand(
            //     textStyle: TextStyle(
            //         fontSize: 12,
            //         fontWeight: FontWeight.w500,
            //         color: Colors.black),
            //   ),
            // ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(FlutterIcons.user_alt_faw5s, color: Colors.black87),
            onPressed: () {
              showProfile(
                  widget.receiver,
                  context,
                  bioController,
                  snapchatController,
                  instagramController,
                  linkedinController,
                  null,
                  null,
                  isFromChat: true);
            },
          ),
        ],
        elevation: 0.5,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (_) {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Stack(children: [
          ListView(
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
                      messages.add(msg);
                    }

                    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

                    if (messages.isNotEmpty) {
                      if (seen == false) {
                        seen = true;
                        setSeen(widget.receiver.id);
                      }
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        Message msg = messages[index];
                        if (msg.senderId == myID) {
                          return ChatBubbleRight(
                            msg: msg,
                          );
                        } else {
                          return ChatBubbleLeft(msg: msg);
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var chats = db.child(uniKey == 0 ? 'UofT' : 'YorkU').child(widget.chatId);
    myChat = chats.onValue;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    chatController.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}