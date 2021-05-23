import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart' as fade;
import 'package:full_screen_image/full_screen_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/message.dart';
import 'package:unify/Models/product.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ProductDetailPage.dart';

class ChatBubbleRightGroup extends StatefulWidget {
  final Message msg;
  final Function scroll;
  final bool meLastSender;
  ChatBubbleRightGroup(
      {Key key, @required this.msg, this.scroll, this.meLastSender})
      : super(key: key);

  @override
  _ChatBubbleRightGroupState createState() => _ChatBubbleRightGroupState();
}

class _ChatBubbleRightGroupState extends State<ChatBubbleRightGroup> {
  PostUser user;
  Product prod;
  bool prodNull;

  Widget build(BuildContext context) {
    return user != null
        ? fade.FadeIn(
            child: Padding(
              padding: EdgeInsets.only(
                top: widget.meLastSender == true ? 10.0 : 0.0,
                right: 10.0,
                left: 10.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.meLastSender
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(25.0),
                          child: CachedNetworkImage(
                              imageUrl: user.profileImgUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover),
                        )
                      : Container(height: 1, width: 50),
                  SizedBox(width: 5.0),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Visibility(
                          visible: widget.meLastSender,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 0.0, bottom: 3.0),
                            child: Text(
                              'You',
                              style: GoogleFonts.kulimPark(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).accentColor),
                            ),
                          ),
                        ),
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Flexible(
                                child: widget.msg.imageUrl != null
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 5.0, top: 5.0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              child: Container(
                                                height: 200,
                                                color: Colors.grey
                                                    .withOpacity(0.2),
                                                child: FullScreenWidget(
                                                  backgroundColor: Colors.brown,
                                                  child: Center(
                                                    child: Image.network(
                                                      widget.msg.imageUrl,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      // height:
                                                      //     MediaQuery.of(context).size.height / 2,
                                                      fit: BoxFit.cover,
                                                      loadingBuilder: (BuildContext
                                                              context,
                                                          Widget child,
                                                          ImageChunkEvent
                                                              loadingProgress) {
                                                        if (loadingProgress ==
                                                            null) return child;
                                                        return SizedBox(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: Center(
                                                            child: SizedBox(
                                                                width: 20,
                                                                height: 20,
                                                                child:
                                                                    LoadingIndicator(
                                                                  indicatorType:
                                                                      Indicator
                                                                          .circleStrokeSpin,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .accentColor,
                                                                )),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Wrap(
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              Text(
                                                widget.msg.messageText,
                                                style: GoogleFonts.kulimPark(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    color: Theme.of(context)
                                                        .accentColor),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5.0),
                                        child: Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            Text(
                                              widget.msg.messageText,
                                              style: GoogleFonts.kulimPark(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context)
                                                      .accentColor),
                                            ),
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
            ),
          )
        : Container();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser(widget.msg.senderId).then((value) {
      setState(() {
        user = value;
        // double nameLength = user.name.split(" ").first.length / 2;
        // int index = nameLength.round();
      });
      widget.scroll();
    });
  }
}
