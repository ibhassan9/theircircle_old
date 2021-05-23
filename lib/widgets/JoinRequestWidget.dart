import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ProfilePage.dart';

class JoinRequestWidget extends StatefulWidget {
  final PostUser user;
  final Club club;

  JoinRequestWidget({Key key, this.user, this.club});

  @override
  _JoinRequestWidgetState createState() => _JoinRequestWidgetState();
}

class _JoinRequestWidgetState extends State<JoinRequestWidget> {
  bool rejected = false;
  bool accepted = false;

  String imgUrl = '';
  PostUser user;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
      child: InkWell(
        onTap: () {
          if (user == null) {
            return;
          }
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) =>
          //             ProfilePage(user: widget.user, heroTag: widget.user.id)));
          showBarModalBottomSheet(
              context: context,
              builder: (context) =>
                  ProfilePage(user: widget.user, heroTag: widget.user.id));
        },
        child: user != null
            ? Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Theme.of(context).backgroundColor),
                child: Wrap(children: <Widget>[
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              imgUrl == null || imgUrl == ''
                                  ? CircleAvatar(
                                      backgroundColor: Colors.grey[400],
                                      child: Text(user.name.substring(0, 1),
                                          style: GoogleFonts.kulimPark(
                                              color: Theme.of(context)
                                                  .backgroundColor)))
                                  : Hero(
                                      tag: user.id,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: Image.network(
                                          imgUrl,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return SizedBox(
                                              height: 40,
                                              width: 40,
                                              child: Center(
                                                child: SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: LoadingIndicator(
                                                      indicatorType: Indicator
                                                          .ballScaleMultiple,
                                                      color: Theme.of(context)
                                                          .accentColor,
                                                    )),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                              SizedBox(width: 10.0),
                              Text(
                                user.name,
                                style: GoogleFonts.kulimPark(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).accentColor),
                              )
                            ],
                          ),
                        ),
                        Container(
                          child: rejected == false
                              ? accepted == false
                                  ? Row(
                                      children: <Widget>[
                                        InkWell(
                                          onTap: () async {
                                            await acceptUserToClub(
                                                user, widget.club);
                                            setState(() {
                                              accepted = true;
                                            });
                                          },
                                          child: Text(
                                            "ACCEPT",
                                            style: GoogleFonts.kulimPark(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.blue),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            await removeUserFromRequests(
                                                widget.club, user);
                                            setState(() {
                                              rejected = true;
                                            });
                                          },
                                          child: Text(
                                            "DENY",
                                            style: GoogleFonts.kulimPark(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.red),
                                          ),
                                        )
                                      ],
                                    )
                                  : Text(
                                      "ACCEPTED",
                                      style: GoogleFonts.kulimPark(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blue),
                                    )
                              : Text(
                                  "DENIED",
                                  style: GoogleFonts.kulimPark(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red),
                                ),
                        )
                      ]),
                  Divider(),
                ]))
            : Container(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getUser(widget.user.id).then((value) {
      setState(() {
        imgUrl = value.profileImgUrl;
        user = value;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
