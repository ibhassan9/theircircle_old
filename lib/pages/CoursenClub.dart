import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/pages/Rooms.dart';
import 'package:unify/pages/clubs_page.dart';
import 'package:unify/pages/courses_page.dart';

class CoursenClub extends StatefulWidget {
  @override
  _CoursenClubState createState() => _CoursenClubState();
}

class _CoursenClubState extends State<CoursenClub> {
  final controller = PageController();
  int selected = 0;
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () {
                controller.animateToPage(0,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeIn);
                setState(() {
                  selected = 0;
                });
              },
              child: Column(
                children: [
                  Text(
                    "Courses",
                    style: GoogleFonts.quicksand(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: selected == 0
                            ? Theme.of(context).accentColor
                            : Theme.of(context).accentColor.withOpacity(0.4)),
                  ),
                  SizedBox(height: 5.0),
                  CircleAvatar(
                    radius: 3.0,
                    backgroundColor: selected == 0
                        ? Colors.purple
                        : Theme.of(context).backgroundColor,
                  )
                ],
              ),
            ),
            InkWell(
              onTap: () {
                controller.animateToPage(1,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeIn);
                setState(() {
                  selected = 1;
                });
              },
              child: Column(
                children: [
                  Text(
                    "Communities",
                    style: GoogleFonts.quicksand(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: selected == 1
                            ? Theme.of(context).accentColor
                            : Theme.of(context).accentColor.withOpacity(0.4)),
                  ),
                  SizedBox(height: 5.0),
                  CircleAvatar(
                    radius: 3.0,
                    backgroundColor: selected == 1
                        ? Colors.purple
                        : Theme.of(context).backgroundColor,
                  )
                ],
              ),
            ),
            InkWell(
              onTap: () {
                controller.animateToPage(2,
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeIn);
                setState(() {
                  selected = 2;
                });
              },
              child: Column(
                children: [
                  Text(
                    "Rooms",
                    style: GoogleFonts.quicksand(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: selected == 2
                            ? Theme.of(context).accentColor
                            : Theme.of(context).accentColor.withOpacity(0.4)),
                  ),
                  SizedBox(height: 5.0),
                  CircleAvatar(
                    radius: 3.0,
                    backgroundColor: selected == 2
                        ? Colors.purple
                        : Theme.of(context).backgroundColor,
                  )
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: ClipRRect(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0)),
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: Theme.of(context).backgroundColor,
          child: PageView(
            onPageChanged: (index) {
              setState(() {
                selected = index;
              });
            },
            controller: controller,
            children: <Widget>[CoursesPage(), ClubsPage(), Rooms()],
          ),
        ),
      ),
    );
  }
}
