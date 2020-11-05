import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/message.dart';

class ChatBubbleRight extends StatelessWidget {
  final Message msg;
  ChatBubbleRight({Key key, @required this.msg}) : super(key: key);

  Widget build(BuildContext context) {
    return Bubble(
      shadowColor: Colors.transparent,
      margin: BubbleEdges.fromLTRB(
          MediaQuery.of(context).size.width / 4, 10.0, 10.0, 0.0),
      alignment: Alignment.centerRight,
      nip: BubbleNip.rightTop,
      nipWidth: 10,
      nipHeight: 10,
      nipRadius: 5,
      stick: true,
      color: Colors.blue,
      child: Text(msg.messageText,
          style: GoogleFonts.quicksand(
            textStyle: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white),
          )),
    );
  }
}
