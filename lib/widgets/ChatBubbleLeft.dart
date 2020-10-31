import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/message.dart';

class ChatBubbleLeft extends StatelessWidget {
  final Message msg;
  ChatBubbleLeft({Key key, @required this.msg}) : super(key: key);

  Widget build(BuildContext context) {
    return Bubble(
      margin: BubbleEdges.fromLTRB(
          10.0, 10.0, MediaQuery.of(context).size.width / 4, 10.0),
      alignment: Alignment.centerLeft,
      nip: BubbleNip.leftTop,
      nipWidth: 10,
      nipHeight: 10,
      nipRadius: 5,
      stick: true,
      color: Colors.pink,
      child: Text(msg.messageText,
          style: GoogleFonts.quicksand(
            textStyle: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
          )),
    );
  }
}
