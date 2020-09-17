import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/user.dart';

class MemberWidget extends StatefulWidget {
  final PostUser user;
  final Club club;

  MemberWidget({Key key, this.user, this.club});

  @override
  _MemberWidgetState createState() => _MemberWidgetState();
}

class _MemberWidgetState extends State<MemberWidget> {
  @override
  Widget build(BuildContext context) {
    print(widget.user.id);
    print(widget.club.adminId);
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
                          backgroundColor: Colors.deepPurple,
                          child: Text(
                            widget.user.name[0].toUpperCase(),
                            style: GoogleFonts.quicksand(
                              textStyle: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Text(widget.user.name,
                            style: GoogleFonts.quicksand(
                              textStyle: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black),
                            ))
                      ],
                    ),
                  ),
                  widget.user.id == widget.club.adminId
                      ? Text("ADMIN",
                          style: GoogleFonts.quicksand(
                            textStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.deepPurple),
                          ))
                      : SizedBox(),
                ]),
            Divider(),
          ])),
    );
  }
}
