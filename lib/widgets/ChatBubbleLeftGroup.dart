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
import 'package:timeago/timeago.dart' as timeago;

class ChatBubbleLeftGroup extends StatefulWidget {
  final Message msg;
  final Function scroll;
  final bool meLastSender;
  ChatBubbleLeftGroup(
      {Key key, @required this.msg, this.scroll, this.meLastSender})
      : super(key: key);

  @override
  _ChatBubbleLeftGroupState createState() => _ChatBubbleLeftGroupState();
}

class _ChatBubbleLeftGroupState extends State<ChatBubbleLeftGroup> {
  PostUser user;
  Product prod;
  bool prodNull;
  Color color;

  Widget build(BuildContext context) {
    return user != null
        ? Padding(
            padding: EdgeInsets.only(
                left: 10.0, right: 10.0, top: widget.meLastSender ? 10.0 : 0.0),
            child: Row(
              children: [
                widget.meLastSender
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: CachedNetworkImage(
                            imageUrl: user.profileImgUrl,
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover),
                      )
                    : Container(height: 1, width: 30),
                SizedBox(width: 5.0),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: widget.meLastSender,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: 10.0, bottom: 3.0),
                          child: Text(
                            user.name.split(' ').first,
                            style: GoogleFonts.quicksand(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: color),
                          ),
                        ),
                      ),
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            //Container(width: 1.5, color: color),
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
                            //SizedBox(width: 5.0),
                            Flexible(
                              child:
                                  prod != null ||
                                          (prodNull != null && prodNull == true)
                                      ? InkWell(
                                          onTap: () {
                                            if (prod == null) {
                                              return;
                                            }
                                            showBarModalBottomSheet(
                                                context: context,
                                                builder: (context) =>
                                                    ProductDetailPage(
                                                      prod: prod,
                                                    ));
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 5.0),
                                                child: Stack(
                                                  children: [
                                                    prodNull != null &&
                                                            prodNull == true
                                                        ? Container(
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.0)),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                'Listing not available',
                                                                style: GoogleFonts.quicksand(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ),
                                                          )
                                                        : Container(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height /
                                                                8,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0)),
                                                            child: Row(
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            5.0),
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .grey[100],
                                                                      ),
                                                                      child:
                                                                          CachedNetworkImage(
                                                                        imageUrl: prod !=
                                                                                null
                                                                            ? prod.imgUrls[0]
                                                                            : '',
                                                                        height: MediaQuery.of(context).size.height /
                                                                            4.5,
                                                                        width:
                                                                            MediaQuery.of(context).size.width /
                                                                                5,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Flexible(
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            5.0),
                                                                    child:
                                                                        Column(
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
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: GoogleFonts.quicksand(
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight.w500,
                                                                              color: Colors.black),
                                                                        ),
                                                                        // Text(
                                                                        //   r'$ ' + prod.price,
                                                                        //   style: GoogleFonts.lexendDeca(
                                                                        //     textStyle: GoogleFonts.quicksand(
                                                                        //         fontSize: 13,
                                                                        //         fontWeight: FontWeight.w500,
                                                                        //         color: Colors.black),
                                                                        //   ),
                                                                        // ),
                                                                        Text(
                                                                          prod.description,
                                                                          maxLines:
                                                                              2,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: GoogleFonts.quicksand(
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w400,
                                                                              color: Colors.black),
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
                                              Wrap(
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children: [
                                                  Text(
                                                    widget.msg.messageText,
                                                    style:
                                                        GoogleFonts.quicksand(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Theme.of(
                                                                    context)
                                                                .accentColor),
                                                  ),
                                                  // SizedBox(width: 5.0),
                                                  // Text(
                                                  //   ' • ' +
                                                  //       timeago
                                                  //           .format(
                                                  //               DateTime.fromMillisecondsSinceEpoch(
                                                  //                   widget.msg
                                                  //                       .timestamp),
                                                  //               locale:
                                                  //                   'en_short')
                                                  //           .replaceAll(
                                                  //               '~', ''),
                                                  //   style:
                                                  //       GoogleFonts.quicksand(
                                                  //           fontSize: 10,
                                                  //           fontWeight:
                                                  //               FontWeight.w500,
                                                  //           color: Theme.of(
                                                  //                   context)
                                                  //               .buttonColor),
                                                  // )
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Wrap(
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              Text(
                                                widget.msg.messageText,
                                                style: GoogleFonts.quicksand(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    color: Theme.of(context)
                                                        .accentColor),
                                              ),
                                              // SizedBox(width: 5.0),
                                              // Text(
                                              //   ' • ' +
                                              //       timeago
                                              //           .format(
                                              //               DateTime.fromMillisecondsSinceEpoch(
                                              //                   widget.msg
                                              //                       .timestamp),
                                              //               locale: 'en_short')
                                              //           .replaceAll('~', ''),
                                              //   style: GoogleFonts.quicksand(
                                              //       fontSize: 10,
                                              //       fontWeight: FontWeight.w500,
                                              //       color: Theme.of(context)
                                              //           .buttonColor),
                                              // )
                                            ],
                                          ),
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
    color = Colors.transparent;
    getUser(widget.msg.senderId).then((value) {
      if (widget.msg.productId != null) {
        Product.info(widget.msg.productId).then((_prod) {
          setState(() {
            if (_prod == null) {
              prodNull = true;
            }
            prod = _prod;
            user = value;
            double nameLength = user.name.split(" ").first.length / 2;
            int index = nameLength.toInt();
            color = Constants.colorIndex(index);
          });
          //widget.scroll();
        });
      } else {
        setState(() {
          user = value;
          double nameLength = user.name.split(" ").first.length / 2;
          int index = nameLength.round();
          color = Constants.colorIndex(index);
        });
      }
      widget.scroll();
    });
  }
}
