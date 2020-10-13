import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Courses/CourseWidget.dart';
import 'package:unify/Models/course.dart';

class CoursesPage extends StatefulWidget {
  @override
  _CoursesPageState createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  bool didload = false;
  String filter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 0.5,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "Courses",
          style: GoogleFonts.quicksand(
            textStyle: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: refresh,
        child: Stack(
          children: <Widget>[
            ListView(
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              children: <Widget>[
                Container(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        filter = value;
                      });
                    },
                    decoration: new InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                          left: 15, bottom: 11, top: 11, right: 15),
                      hintText: "Search Courses...",
                      hintStyle: GoogleFonts.quicksand(
                        textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                    ),
                    style: GoogleFonts.quicksand(
                      textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                  ),
                ),
                didload == true
                    ? FutureBuilder(
                        future: fetchCourses(),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting)
                            return Center(
                                child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                            ));
                          else if (snap.hasData)
                            return ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount:
                                  snap.data != null ? snap.data.length : 0,
                              itemBuilder: (BuildContext context, int index) {
                                Course course = snap.data[index];
                                return filter == null || filter.trim() == ""
                                    ? Column(
                                        children: <Widget>[
                                          CourseWidget(course: course),
                                          Divider(),
                                        ],
                                      )
                                    : course.name
                                                .toLowerCase()
                                                .trim()
                                                .contains(filter.trim()) ||
                                            course.code
                                                .toLowerCase()
                                                .trim()
                                                .contains(filter.trim())
                                        ? Column(
                                            children: <Widget>[
                                              CourseWidget(course: course),
                                              Divider(),
                                            ],
                                          )
                                        : new Container();
                              },
                            );
                          else if (snap.hasError)
                            return Container(
                              height: MediaQuery.of(context).size.height / 1.4,
                              child: Center(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.face,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 10),
                                    Text("Error loading courses :(",
                                        style: GoogleFonts.quicksand(
                                          textStyle: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey),
                                        )),
                                  ],
                                ),
                              ),
                            );
                          else
                            return Container(
                              height: MediaQuery.of(context).size.height / 1.4,
                              child: Center(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.face,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 10),
                                    Text("There are no courses :(",
                                        style: GoogleFonts.quicksand(
                                          textStyle: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey),
                                        )),
                                  ],
                                ),
                              ),
                            );
                        })
                    : Container(),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<Null> refresh() async {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          didload = true;
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
