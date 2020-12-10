import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/match.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ChatPage.dart';
import 'package:unify/pages/UserSearchPage.dart';
import 'package:unify/widgets/MyConversationWidget.dart';
import 'package:unify/widgets/MyMatchWidget.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyMatchesPage extends StatefulWidget {
  @override
  _MyMatchesPageState createState() => _MyMatchesPageState();
}

class _MyMatchesPageState extends State<MyMatchesPage>
    with AutomaticKeepAliveClientMixin {
  var db = FirebaseDatabase.instance.reference().child('users');
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Stream<Event> myStream;

  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(FlutterIcons.create_mdi,
                  color: Theme.of(context).accentColor),
              onPressed: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserSearchPage()))
                    .then((value) {});
              })
        ],
        brightness: Theme.of(context).brightness,
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Theme.of(context).accentColor),
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Chat",
                  style: GoogleFonts.manjari(
                    textStyle: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).accentColor),
                  ),
                ),
                Text(
                  "Start a conversation!",
                  style: GoogleFonts.manjari(
                    textStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).accentColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          ListView(children: [
            SizedBox(height: 10.0),
            StreamBuilder(
              stream: myStream,
              builder: (context, snap) {
                List<Match> chats = [];
                if (snap.hasData &&
                    !snap.hasError &&
                    snap.data.snapshot.value != null) {
                  Map values = snap.data.snapshot.value;
                  for (var key in values.keys) {
                    var peerId = key;
                    var lastMessage = values[key]['lastMessage'];
                    var lastMessageSenderId = values[key]['senderId'];
                    var timestamp = values[key]['timestamp'];
                    var seen = values[key]['seen'] != null
                        ? values[key]['seen']
                        : false;
                    var chatId = '';
                    var myID = firebaseAuth.currentUser.uid;
                    if (myID.hashCode <= peerId.hashCode) {
                      chatId = '$myID-$peerId';
                    } else {
                      chatId = '$peerId-$myID';
                    }
                    var match = Match(
                        peerId: peerId,
                        chatId: chatId,
                        lastMessage: lastMessage,
                        timestamp: timestamp,
                        seen: seen,
                        lastMessageSenderId: lastMessageSenderId);
                    chats.add(match);
                  }
                } else {
                  return Container(
                    height: MediaQuery.of(context).size.height / 1.4,
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            FlutterIcons.chat_ent,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text("Your chat list is empty",
                              style: GoogleFonts.manjari(
                                textStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey),
                              )),
                        ],
                      ),
                    ),
                  );
                }
                chats.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                return FutureBuilder(
                  future: users(chats),
                  builder: (_, s) {
                    if (snap.hasData && snap.data != null) {
                      return ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: chats != null ? chats.length : 0,
                        itemBuilder: (BuildContext context, int index) {
                          Match chat = chats[index];
                          var timeAgo = new DateTime.fromMillisecondsSinceEpoch(
                              chat.timestamp);
                          var time = timeago.format(timeAgo);
                          Function reload = () {
                            setState(() {
                              myStream = db.onValue;
                            });
                          };

                          if (s.hasData && s.data.length == chats.length) {
                            PostUser u = s.data[index];
                            return Column(
                              children: [
                                MyConversationWidget(
                                    peerId: chat.peerId,
                                    lastMessage: chat.lastMessage,
                                    chatId: chat.chatId,
                                    timestamp: chat.timestamp,
                                    reload: reload,
                                    peer: u,
                                    timeAgo: time,
                                    seen: chat.seen,
                                    lastMessageSenderId:
                                        chat.lastMessageSenderId),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Divider(),
                                ),
                              ],
                            );
                          } else {
                            return Container();
                          }
                        },
                      );
                    } else {
                      return Container(
                        height: MediaQuery.of(context).size.height / 1.4,
                        child: Center(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.chat,
                                color: Theme.of(context).accentColor,
                              ),
                              SizedBox(width: 10),
                              Text("Your chat list is empty :(",
                                  style: GoogleFonts.manjari(
                                    textStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).accentColor),
                                  )),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),

            // FutureBuilder(
            //     future: fetchChatList(),
            //     builder: (context, snap) {
            //       if (snap.connectionState == ConnectionState.waiting)
            //         return Center(
            //             child: CircularProgressIndicator(
            //           strokeWidth: 2.0,
            //         ));
            //       else if (snap.hasData)
            //         return ListView.builder(
            //           shrinkWrap: true,
            //           scrollDirection: Axis.vertical,
            //           physics: NeverScrollableScrollPhysics(),
            //           itemCount: snap.data != null ? snap.data.length : 0,
            //           itemBuilder: (BuildContext context, int index) {
            //             Match match = snap.data[index];
            //             return MyConversationWidget(
            //               user: match.user,
            //               lastMessage: match.lastMessage,
            //               chatId: match.chatId,
            //               timestamp: match.timestamp,
            //             );
            //           },
            //         );
            //       else if (snap.hasError)
            //         return Center(
            //           child: Row(
            //             crossAxisAlignment: CrossAxisAlignment.center,
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: <Widget>[
            //               Icon(
            //                 Icons.face,
            //                 color: Colors.grey,
            //               ),
            //               SizedBox(width: 10),
            //               Text("You haven't started any conversations yet :(",
            //                   style: GoogleFonts.manjari(
            //                     textStyle: TextStyle(
            //                         fontSize: 14,
            //                         fontWeight: FontWeight.w500,
            //                         color: Colors.grey),
            //                   )),
            //             ],
            //           ),
            //         );
            //       else
            //         return Container(
            //           height: MediaQuery.of(context).size.height / 1.4,
            //           child: Center(
            //             child: Row(
            //               crossAxisAlignment: CrossAxisAlignment.center,
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               children: <Widget>[
            //                 Icon(
            //                   Icons.face,
            //                   color: Colors.grey,
            //                 ),
            //                 SizedBox(width: 10),
            //                 Text("You haven't started any conversations yet :(",
            //                     style: GoogleFonts.manjari(
            //                       textStyle: TextStyle(
            //                           fontSize: 14,
            //                           fontWeight: FontWeight.w500,
            //                           color: Colors.grey),
            //                     )),
            //               ],
            //             ),
            //           ),
            //         );
            //     }),
          ])
        ],
      ),
    );
  }

  Future<List<PostUser>> users(List<Match> chats) async {
    var blocks = await getBlocks();
    List<PostUser> p = [];
    for (var chat in chats) {
      PostUser user = await getUser(chat.peerId);
      if (blocks.contains(user.id)) {
        // blocked
      } else {
        p.add(user);
      }
    }
    return p;
  }

  @override
  void initState() {
    super.initState();
    var uniKey = Constants.checkUniversity();
    var myID = firebaseAuth.currentUser.uid;
    db = db.child(uniKey == 0 ? 'UofT' : 'YorkU').child(myID).child('chats');
    myStream = db.onValue;
  }

  @override
  bool get wantKeepAlive => true;
}
