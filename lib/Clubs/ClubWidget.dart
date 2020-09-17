import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Clubs/club_page.dart';
import 'package:unify/Models/club.dart';

class ClubWidget extends StatefulWidget {
  final Club club;

  ClubWidget({Key key, @required this.club}) : super(key: key);

  @override
  _ClubWidgetState createState() => _ClubWidgetState();
}

class _ClubWidgetState extends State<ClubWidget> {
  @override
  Widget build(BuildContext context) {
    Color color() {
      Random random = new Random();
      int index = random.nextInt(6);
      switch (index) {
        case 1:
          {
            return Colors.deepOrangeAccent;
          }
          break;
        case 2:
          {
            return Colors.deepPurpleAccent;
          }
          break;
        case 3:
          {
            return Colors.blueAccent;
          }
          break;
        case 4:
          {
            return Colors.purpleAccent;
          }
          break;
        case 5:
          {
            return Colors.redAccent;
          }
          break;
        default:
          {
            return Colors.indigoAccent;
          }
          break;
      }
    }

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ClubPage(
                      club: widget.club,
                    )));
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: widget.club.admin ? Colors.indigo : Colors.blue),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.club.name,
                      style: GoogleFonts.quicksand(
                        textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                    Text(
                      widget.club.description,
                      style: GoogleFonts.quicksand(
                        textStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    )
                  ],
                )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        widget.club.admin
                            ? setState(() {})
                            : widget.club.inClub
                                ? setState(() {
                                    widget.club.inClub = false;
                                  })
                                : widget.club.privacy == 0
                                    ? widget.club.requested
                                        ? setState(() {
                                            widget.club.requested = false;
                                          })
                                        : setState(() {
                                            widget.club.inClub = true;
                                          })
                                    : widget.club.requested
                                        ? setState(() {
                                            widget.club.requested = false;
                                          })
                                        : setState(() {
                                            widget.club.requested = true;
                                          });
                      },
                      child: Text(
                        widget.club.admin
                            ? "Created by you"
                            : widget.club.inClub
                                ? "Leave Club"
                                : widget.club.privacy == 0
                                    ? widget.club.requested
                                        ? "Awaiting Approval"
                                        : "Join Club"
                                    : widget.club.requested
                                        ? "Awaiting Approval"
                                        : "Request to Join Club",
                        style: GoogleFonts.quicksand(
                          textStyle: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.comment, color: Colors.white),
                            onPressed: () {},
                          ),
                          Text(
                            "${widget.club.postCount}",
                            style: GoogleFonts.quicksand(
                              textStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.group, color: Colors.white),
                            onPressed: () {},
                          ),
                          Text(
                            "${widget.club.memberCount}",
                            style: GoogleFonts.quicksand(
                              textStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
