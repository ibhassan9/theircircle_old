import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/message.dart';
import 'package:unify/Models/product.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ProductDetailPage.dart';

class ChatBubbleLeftGroup extends StatefulWidget {
  final Message msg;
  final Function scroll;
  ChatBubbleLeftGroup({Key key, @required this.msg, this.scroll})
      : super(key: key);

  @override
  _ChatBubbleLeftGroupState createState() => _ChatBubbleLeftGroupState();
}

class _ChatBubbleLeftGroupState extends State<ChatBubbleLeftGroup> {
  String imgUrl;
  PostUser user;
  Product prod;
  bool prodNull;

  Color color;

  Widget build(BuildContext context) {
    return user != null
        ? Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                imgUrl == null || imgUrl == ''
                    ? Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(15.0)))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                            color: Colors.grey,
                            child: CachedNetworkImage(
                              imageUrl: imgUrl != null ? imgUrl : '',
                              width: 30,
                              height: 30,
                              fit: BoxFit.cover,
                            )),
                      ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      user != null
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 5.0, left: 15.0),
                              child: Text(user.name,
                                  style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).accentColor,
                                    fontSize: 12.0,
                                  )),
                            )
                          : Container(),
                      Bubble(
                        shadowColor: Colors.transparent,
                        margin: BubbleEdges.fromLTRB(10.0, 0.0,
                            MediaQuery.of(context).size.width / 4, 10.0),
                        alignment: Alignment.centerLeft,
                        nip: BubbleNip.no,
                        nipWidth: 1,
                        nipHeight: 1,
                        nipRadius: 0.5,
                        stick: false,
                        radius: Radius.circular(20.0),
                        color: Theme.of(context).dividerColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                              child: Text(
                                widget.msg.messageText,
                                style: GoogleFonts.quicksand(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).accentColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Container();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    color = Constants.color();
    getUser(widget.msg.senderId).then((value) {
      if (widget.msg.productId != null) {
        Product.info(widget.msg.productId).then((_prod) {
          setState(() {
            imgUrl = value.profileImgUrl;
            user = value;
            if (_prod == null) {
              prodNull = true;
            }
            prod = _prod;
          });
          widget.scroll();
        });
      } else {
        setState(() {
          imgUrl = value.profileImgUrl;
          user = value;
        });
        widget.scroll();
      }
    });
  }
}
