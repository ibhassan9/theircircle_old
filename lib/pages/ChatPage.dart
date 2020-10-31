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

class ChatPage extends StatefulWidget {
  final PostUser receiver;
  final String chatId;
  ChatPage({Key key, @required this.receiver, @required this.chatId})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController chatController = TextEditingController();
  var uniKey = Constants.checkUniversity();
  var myID = firebaseAuth.currentUser.uid;
  var db = FirebaseDatabase.instance.reference().child('chats');

  Widget build(BuildContext context) {
    var chats = db.child(uniKey == 0 ? 'UofT' : 'YorkU').child(widget.chatId);
    print(myID.length < widget.receiver.id.length);
    Padding chatBox = Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                  child: TextField(
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
              )),
              IconButton(
                icon: Icon(
                  AntDesign.arrowright,
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
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.pink),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.receiver.name,
              style: GoogleFonts.quicksand(
                textStyle: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ),
            Text(
              "Meet & Make New Friends",
              style: GoogleFonts.quicksand(
                textStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(FlutterIcons.flag_faw, color: Colors.pink),
            onPressed: () {
              // TODO:- unmatch
            },
          ),
        ],
        elevation: 1.0,
      ),
      body: Stack(children: [
        ListView(
          children: [
            StreamBuilder(
              stream: chats.onValue,
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
                  return Center(child: Text("No data"));
              },
            ),
          ],
        )
      ]),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0), child: chatBox),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    chatController.dispose();
  }
}
