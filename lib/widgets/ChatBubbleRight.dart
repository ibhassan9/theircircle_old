import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unify/Models/message.dart';
import 'package:unify/Models/product.dart';
import 'package:unify/pages/ProductDetailPage.dart';

class ChatBubbleRight extends StatefulWidget {
  final Message msg;
  ChatBubbleRight({Key key, @required this.msg}) : super(key: key);

  @override
  _ChatBubbleRightState createState() => _ChatBubbleRightState();
}

class _ChatBubbleRightState extends State<ChatBubbleRight> {
  Product prod;
  bool prodNull;

  Widget build(BuildContext context) {
    return Container(
      child: Bubble(
        shadowColor: Colors.transparent,
        margin: BubbleEdges.fromLTRB(
            MediaQuery.of(context).size.width * 0.4, 10.0, 10.0, 0.0),
        alignment: Alignment.centerRight,
        nip: BubbleNip.rightTop,
        nipWidth: 10,
        nipHeight: 10,
        nipRadius: 5,
        radius: Radius.circular(20.0),
        stick: true,
        color: prod != null || (prodNull != null && prodNull == true)
            ? Colors.transparent
            : Colors.blue,
        child: prod != null || (prodNull != null && prodNull == true)
            ? InkWell(
                onTap: () {
                  if (prod == null) {
                    return;
                  }
                  showBarModalBottomSheet(
                      context: context,
                      builder: (context) => ProductDetailPage(
                            prod: prod,
                          ));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: Stack(
                        children: [
                          prodNull != null && prodNull == true
                              ? Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(5.0)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Listing not available',
                                      style: GoogleFonts.quicksand(
                                        textStyle: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  height:
                                      MediaQuery.of(context).size.height / 8,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
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
                                                  4.5,
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
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 5.0),
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
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.quicksand(
                                                  textStyle: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.black),
                                                ),
                                              ),
                                              // Text(
                                              //   r'$ ' + prod.price,
                                              //   style: GoogleFonts.quicksand(
                                              //     textStyle: TextStyle(
                                              //         fontSize: 13,
                                              //         fontWeight: FontWeight.w500,
                                              //         color: Colors.black),
                                              //   ),
                                              // ),
                                              Text(
                                                prod.description,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.quicksand(
                                                  textStyle: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                        ],
                      ),
                    ),
                    Text(widget.msg.messageText,
                        style: GoogleFonts.quicksand(
                          textStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).accentColor),
                        )),
                  ],
                ),
              )
            : Text(widget.msg.messageText,
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                )),
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
