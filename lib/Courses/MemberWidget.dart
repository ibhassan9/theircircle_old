import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/user.dart';

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
          showProfile(widget.user, context, bioC, sC, igC, lC);
        },
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0), color: Colors.white),
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
                              style: GoogleFonts.quicksand(
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
                              style: GoogleFonts.quicksand(
                                textStyle: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black),
                              ))
                        ],
                      ),
                    ),
                    widget.isCourse == false
                        ? widget.user.id == widget.club.adminId
                            ? Text("Admin",
                                style: GoogleFonts.quicksand(
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
                                    child: Icon(AntDesign.close, size: 20.0)))
                        : SizedBox(),
                  ]),
              Divider(),
            ])),
      ),
    );
  }
}
