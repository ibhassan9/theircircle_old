import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tabbar/tabbar.dart';
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
                    style: TextStyle(
                        fontFamily: "Futura1",
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
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
                    style: TextStyle(
                        fontFamily: "Futura1",
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
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
                    style: TextStyle(
                        fontFamily: "Futura1",
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
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
      body: PageView(
        onPageChanged: (index) {
          setState(() {
            selected = index;
          });
        },
        controller: controller,
        children: <Widget>[CoursesPage(), ClubsPage(), Rooms()],
      ),
    );
  }
}
