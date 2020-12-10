import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/MyProfilePage.dart';
import 'package:unify/pages/ProfilePage.dart';

class MemberWidget extends StatefulWidget {
  final PostUser user;
  final Club club;
  final bool isCourse;
  final Function delete;

  MemberWidget({Key key, this.user, this.club, this.isCourse, this.delete});

  @override
  _MemberWidgetState createState() => _MemberWidgetState();
}

class _MemberWidgetState extends State<MemberWidget> {
  final FirebaseAuth _fAuth = FirebaseAuth.instance;
  TextEditingController bioC = TextEditingController();
  TextEditingController sC = TextEditingController();
  TextEditingController igC = TextEditingController();
  TextEditingController lC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          if (widget.user.id == _fAuth.currentUser.uid) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MyProfilePage(
                        user: widget.user, heroTag: widget.user.id)));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfilePage(
                        user: widget.user, heroTag: widget.user.id)));
          }
          //showProfile(widget.user, context, bioC, sC, igC, lC, null, null);
        },
        child: Container(
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
                          CircleAvatar(
                            backgroundColor: Colors.deepOrange,
                            child: Text(
                              widget.user.name[0].toUpperCase(),
                              style: GoogleFonts.manjari(
                                textStyle: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Text(
                              _fAuth.currentUser.uid == widget.user.id
                                  ? 'You'
                                  : widget.user.name,
                              style: GoogleFonts.manjari(
                                textStyle: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).accentColor),
                              ))
                        ],
                      ),
                    ),
                    widget.isCourse == false
                        ? widget.user.id == widget.club.adminId
                            ? Text("Admin",
                                style: GoogleFonts.manjari(
                                  textStyle: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.deepOrange),
                                ))
                            : Visibility(
                                visible: _fAuth.currentUser.uid ==
                                        widget.club.adminId &&
                                    _fAuth.currentUser.uid != widget.user.id,
                                child: InkWell(
                                    onTap: () {
                                      widget.delete();
                                    },
                                    child: Icon(AntDesign.close,
                                        color: Theme.of(context).accentColor,
                                        size: 20.0)))
                        : SizedBox(),
                  ]),
              Divider(),
            ])),
      ),
    );
  }
}
