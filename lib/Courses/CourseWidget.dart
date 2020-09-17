import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Courses/course_page.dart';

class CourseWidget extends StatefulWidget {
  final Course course;

  CourseWidget({Key key, @required this.course}) : super(key: key);

  @override
  _CourseWidgetState createState() => _CourseWidgetState();
}

class _CourseWidgetState extends State<CourseWidget> {
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
                builder: (context) => CoursePage(
                      course: widget.course,
                    )));
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.deepPurple),
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
                      widget.course.code,
                      style: GoogleFonts.quicksand(
                        textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                    Text(
                      widget.course.name,
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
                    Text(
                      "Join Group",
                      style: GoogleFonts.quicksand(
                        textStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
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
                            "${widget.course.postCount}",
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
                            "${widget.course.memberCount}",
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
