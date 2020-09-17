import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/user.dart';

class JoinRequestWidget extends StatefulWidget {
  final PostUser user;
  final Club club;

  JoinRequestWidget({Key key, this.user, this.club});

  @override
  _JoinRequestWidgetState createState() => _JoinRequestWidgetState();
}

class _JoinRequestWidgetState extends State<JoinRequestWidget> {
  @override
  Widget build(BuildContext context) {
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
                  Container(
                    child: Row(
                      children: <Widget>[
                        Text("ACCEPT",
                            style: GoogleFonts.quicksand(
                              textStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue),
                            )),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text("DENY",
                            style: GoogleFonts.quicksand(
                              textStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.red),
                            ))
                      ],
                    ),
                  )
                ]),
            Divider(),
          ])),
    );
  }
}
