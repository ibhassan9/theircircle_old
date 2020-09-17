import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/assignment.dart';
import 'package:unify/Courses/course_page.dart';

class AssignmentWidget extends StatefulWidget {
  final Assignment assignment;
  final String timeAgo;

  AssignmentWidget({Key key, @required this.assignment, @required this.timeAgo})
      : super(key: key);

  @override
  _AssignmentWidgetState createState() => _AssignmentWidgetState();
}

class _AssignmentWidgetState extends State<AssignmentWidget> {
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
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0), color: color()),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
            child: Wrap(
              //crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Upcoming",
                      style: GoogleFonts.quicksand(
                        textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      widget.assignment.title,
                      style: GoogleFonts.quicksand(
                        textStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Text(
                      widget.assignment.description,
                      style: GoogleFonts.quicksand(
                        textStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                  ],
                )),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Due: 11:59 PM",
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
            ),
          ),
        ),
      ),
    );
  }
}
