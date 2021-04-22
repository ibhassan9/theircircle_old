import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_select/smart_select.dart';
import 'package:toast/toast.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Home/hashtag_widget.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ChatPage.dart';
import 'package:unify/pages/MultiSelectChip.dart';
import 'dart:ui' as ui;

import 'package:unify/pages/ProfilePage.dart';

class MatchWidget extends StatefulWidget {
  final PostUser user;
  final Function swipe;
  MatchWidget({Key key, this.user, this.swipe}) : super(key: key);
  @override
  _MatchWidgetState createState() => _MatchWidgetState();
}

class _MatchWidgetState extends State<MatchWidget> {
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30.0),
      child: Stack(
        children: [
          picture(),
          Positioned(
            bottom: 0.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 100.0,
                color: Colors.transparent,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.name,
                            style: GoogleFonts.manrope(
                                shadows: <Shadow>[
                                  Shadow(
                                    offset: Offset(0.0, 0.0),
                                    blurRadius: 3.0,
                                    color: Colors.grey,
                                  ),
                                  Shadow(
                                    offset: Offset(0.0, 0.0),
                                    blurRadius: 8.0,
                                    color: Colors.grey,
                                  ),
                                ],
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                          Text(
                            widget.user.about != null
                                ? widget.user.about
                                : 'No Information Available...',
                            style: GoogleFonts.manrope(
                                shadows: <Shadow>[
                                  Shadow(
                                    offset: Offset(0.0, 0.0),
                                    blurRadius: 3.0,
                                    color: Colors.grey,
                                  ),
                                  Shadow(
                                    offset: Offset(0.0, 0.0),
                                    blurRadius: 8.0,
                                    color: Colors.grey,
                                  ),
                                ],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          )
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfilePage(
                                      user: widget.user,
                                      heroTag: widget.user.id)));
                        },
                        child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 13.0,
                            child: Icon(FlutterIcons.info_fea,
                                size: 17.0, color: Colors.black)),
                      )
                    ]),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget picture() {
    return Hero(
      tag: widget.user.id,
      child: widget.user.profileImgUrl != null &&
              widget.user.profileImgUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              child: Container(
                child: Image.network(
                  widget.user.profileImgUrl,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Colors.grey.shade600),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes
                                : null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(30.0)),
              child: Icon(AntDesign.user, color: Colors.black, size: 30.0)),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
}
