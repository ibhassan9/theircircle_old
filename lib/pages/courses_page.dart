import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';
import 'package:unify/Widgets/CourseWidget.dart';
import 'package:unify/Models/course.dart';

class CoursesPage extends StatefulWidget {
  @override
  _CoursesPageState createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage>
    with AutomaticKeepAliveClientMixin {
  bool didload = false;
  String filter;
  TextEditingController titleController = TextEditingController();
  Future<List<Course>> _courseFuture;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    addCourseDialog() {
      bool switchVal = false;
      AwesomeDialog(
          context: context,
          animType: AnimType.SCALE,
          dialogType: DialogType.NO_HEADER,
          body: StatefulBuilder(builder: (context, setState) {
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Don't see your course? Request it!",
                    style: GoogleFonts.quicksand(
                      textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: titleController,
                  maxLines: null,
                  textAlign: TextAlign.center,
                  decoration: new InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                          left: 15, bottom: 11, top: 11, right: 15),
                      hintText: "Eg. CSC437H1"),
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
              ],
            );
          }),
          btnOkColor: Colors.deepOrange,
          btnOkOnPress: () async {
            // send request on firebase
            if (titleController.text.isEmpty || titleController.text == null) {
              return;
            }
            await requestCourse(titleController.text);
            titleController.clear();
            Toast.show("Your request has been received!", context);
          })
        ..show();
    }

    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 0.5,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          FlatButton(
            child: Text(
              "Request a course",
              style: GoogleFonts.quicksand(
                textStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ),
            onPressed: () {
              addCourseDialog();
            },
          ),
          // InkWell(
          //   onTap: () {
          //     addCourseDialog();
          //   },
          //   child: Text(
          //     "Request a course",
          //     style: GoogleFonts.quicksand(
          //       textStyle: TextStyle(
          //           fontSize: 15,
          //           fontWeight: FontWeight.w500,
          //           color: Colors.black),
          //     ),
          //   ),
          // ),
          // SizedBox(width: 10.0)
        ],
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Courses",
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
                Text(
                  "Engage with your peers",
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
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
                            color: Colors.grey.shade600),
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
                        future: _courseFuture,
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
                                    : course.name.toLowerCase().trim().contains(
                                                filter.toLowerCase().trim()) ||
                                            course.code
                                                .toLowerCase()
                                                .trim()
                                                .contains(
                                                    filter.toLowerCase().trim())
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
                                    Text("Cannot find any courses :(",
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
    setState(() {
      _courseFuture = fetchCourses();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        _courseFuture = fetchCourses();
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

  @override
  bool get wantKeepAlive => true;
}
