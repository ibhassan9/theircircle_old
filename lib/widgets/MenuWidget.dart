import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/news.dart';
import 'package:unify/pages/MatchPage.dart';
import 'package:unify/pages/MyMatchesPage.dart';
import 'package:unify/pages/clubs_page.dart';
import 'package:unify/pages/courses_page.dart';

class MenuWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CoursesPage()),
                );
              },
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width / 2.2,
                decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(3.0)),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(AntDesign.book, color: Colors.white, size: 20),
                      SizedBox(width: 5.0),
                      Text(
                        "Courses",
                        style: GoogleFonts.quicksand(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClubsPage()),
                );
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => MatchPage()),
                // );
              },
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width / 2.2,
                decoration: BoxDecoration(
                    color: Colors.pink,
                    borderRadius: BorderRadius.circular(3.0)),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(AntDesign.Trophy, color: Colors.white, size: 20),
                      SizedBox(width: 5.0),
                      Text(
                        "Clubs",
                        style: GoogleFonts.quicksand(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
