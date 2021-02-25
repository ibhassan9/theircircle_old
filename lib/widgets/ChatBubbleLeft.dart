import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unify/Models/message.dart';
import 'package:unify/Models/product.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ProductDetailPage.dart';

class ChatBubbleLeft extends StatefulWidget {
  final Message msg;
  final Function scroll;
  final PostUser user;
  final bool meLastSender;
  ChatBubbleLeft(
      {Key key, @required this.msg, this.scroll, this.meLastSender, this.user})
      : super(key: key);

  @override
  _ChatBubbleLeftState createState() => _ChatBubbleLeftState();
}

class _ChatBubbleLeftState extends State<ChatBubbleLeft> {
  String imgUrl;
  Product prod;
  bool prodNull;

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: widget.meLastSender,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 3.0),
              child: Text(
                widget.user.name.split(' ').first.toUpperCase(),
                style: TextStyle(
                    fontFamily: "Futura1",
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue),
              ),
            ),
          ),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 3.0, color: Colors.blue),
                // imgUrl == null || imgUrl == ''
                //     ? Container(
                //         width: 25,
                //         height: 25,
                //         decoration: BoxDecoration(
                //             color: Colors.grey,
                //             borderRadius: BorderRadius.circular(15.0)))
                //     : ClipRRect(
                //         borderRadius: BorderRadius.circular(25),
                //         child: Container(
                //             color: Colors.grey,
                //             child: CachedNetworkImage(
                //               imageUrl: imgUrl != null ? imgUrl : '',
                //               width: 25,
                //               height: 25,
                //               fit: BoxFit.cover,
                //             )),
                //       ),
                SizedBox(width: 5.0),
                Flexible(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5.0),
                                child: Stack(
                                  children: [
                                    prodNull != null && prodNull == true
                                        ? Container(
                                            decoration: BoxDecoration(
                                                color: Colors.grey.shade300,
                                                borderRadius:
                                                    BorderRadius.circular(5.0)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Listing not available',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                8,
                                            decoration: BoxDecoration(
                                                color: Colors.grey.shade300,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[100],
                                                      ),
                                                      child: CachedNetworkImage(
                                                        imageUrl: prod != null
                                                            ? prod.imgUrls[0]
                                                            : '',
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            4.5,
                                                        width: MediaQuery.of(
                                                                    context)
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
                                                        const EdgeInsets.only(
                                                            right: 5.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          prod.title +
                                                              ' • ' +
                                                              r'$' +
                                                              prod.price,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .lexendDeca(
                                                            textStyle: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                        // Text(
                                                        //   r'$ ' + prod.price,
                                                        //   style: GoogleFonts.lexendDeca(
                                                        //     textStyle: TextStyle(
                                                        //         fontSize: 13,
                                                        //         fontWeight: FontWeight.w500,
                                                        //         color: Colors.black),
                                                        //   ),
                                                        // ),
                                                        Text(
                                                          prod.description,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .lexendDeca(
                                                            textStyle: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: Colors
                                                                    .black),
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
                              Text(
                                widget.msg.messageText,
                                style: GoogleFonts.quicksand(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).accentColor),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: Text(
                            widget.msg.messageText,
                            style: GoogleFonts.quicksand(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).accentColor),
                          ),
                        ),
                ),
              ],
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
    print(widget.meLastSender);
    if (widget.msg.productId != null) {
      Product.info(widget.msg.productId).then((_prod) {
        setState(() {
          if (_prod == null) {
            prodNull = true;
          }
          prod = _prod;
        });
        widget.scroll();
      });
    }
  }
}
