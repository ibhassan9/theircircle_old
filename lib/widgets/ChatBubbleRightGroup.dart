import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unify/Models/message.dart';
import 'package:unify/Models/product.dart';
import 'package:unify/pages/ProductDetailPage.dart';

class ChatBubbleRightGroup extends StatefulWidget {
  final Message msg;
  final Function scroll;
  ChatBubbleRightGroup({Key key, @required this.msg, this.scroll})
      : super(key: key);

  @override
  _ChatBubbleRightGroupState createState() => _ChatBubbleRightGroupState();
}

class _ChatBubbleRightGroupState extends State<ChatBubbleRightGroup> {
  Product prod;
  bool prodNull;

  Widget build(BuildContext context) {
    return Container(
      child: Bubble(
        shadowColor: Colors.transparent,
        margin: BubbleEdges.fromLTRB(
            MediaQuery.of(context).size.width * 0.4, 10.0, 10.0, 0.0),
        alignment: Alignment.centerRight,
        nip: BubbleNip.no,
        nipWidth: 1,
        nipHeight: 1,
        nipRadius: 0.5,
        radius: Radius.circular(20.0),
        stick: true,
        color: Colors.lightBlue,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
          child: Text(
            widget.msg.messageText,
            style: GoogleFonts.quicksand(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Product.info(widget.msg.productId).then((_prod) {
      setState(() {
        if (_prod == null) {
          prodNull = true;
        }
        prod = _prod;
      });
    });
  }
}
