import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/message.dart';
import 'package:unify/Models/user.dart';

class ChatBubbleLeft extends StatefulWidget {
  final Message msg;
  ChatBubbleLeft({Key key, @required this.msg}) : super(key: key);

  @override
  _ChatBubbleLeftState createState() => _ChatBubbleLeftState();
}

class _ChatBubbleLeftState extends State<ChatBubbleLeft> {
  String imgUrl;

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          imgUrl == null || imgUrl == ''
              ? Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(15.0)))
              : ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                      color: Colors.grey,
                      child: CachedNetworkImage(
                        imageUrl: imgUrl != null ? imgUrl : '',
                        width: 25,
                        height: 25,
                        fit: BoxFit.cover,
                      )),
                ),
          Flexible(
            child: Bubble(
              shadowColor: Colors.transparent,
              margin: BubbleEdges.fromLTRB(
                  10.0, 10.0, MediaQuery.of(context).size.width / 4, 0.0),
              alignment: Alignment.centerLeft,
              nip: BubbleNip.leftTop,
              nipWidth: 10,
              nipHeight: 10,
              nipRadius: 5,
              stick: true,
              radius: Radius.circular(20.0),
              color: Colors.grey.shade200,
              child: Text(widget.msg.messageText,
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser(widget.msg.senderId).then((value) {
      setState(() {
        imgUrl = value.profileImgUrl;
      });
    });
  }
}
