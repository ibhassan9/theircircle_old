import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/post.dart';

class TodaysQuestionPage extends StatefulWidget {
  final Club club;
  final Course course;
  final String question;
  TodaysQuestionPage({Key key, this.club, this.course, this.question});
  @override
  _TodaysQuestionPageState createState() => _TodaysQuestionPageState();
}

class _TodaysQuestionPageState extends State<TodaysQuestionPage> {
  TextEditingController contentController = TextEditingController();
  String title = "Tell us about it here...";
  int clength = 300;

  bool isPosting = false;
  bool isAnonymous = false;

  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
            icon: Icon(FlutterIcons.arrow_back_mdi, color: Colors.white),
            onPressed: () => Navigator.pop(context, false)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.blue, Colors.teal]),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40.0, 30.0, 40.0, 30.0),
          child: ListView(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Note: This will be is a public post',
                      textAlign: TextAlign.center,
                      maxLines: null,
                      style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    Divider(color: Colors.white, thickness: 2.0),
                    SizedBox(height: 40.0),
                    Icon(FlutterIcons.md_happy_ion,
                        color: Colors.white, size: 30.0),
                    SizedBox(height: 15.0),
                    Text(
                      widget.question,
                      textAlign: TextAlign.center,
                      maxLines: null,
                      style: GoogleFonts.quicksand(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    SizedBox(height: 10.0),
                    TextField(
                      textInputAction: TextInputAction.done,
                      controller: contentController,
                      textAlign: TextAlign.center,
                      maxLines: null,
                      onChanged: (value) {
                        var newLength = 300 - value.length;
                        setState(() {
                          clength = newLength;
                        });
                      },
                      decoration: new InputDecoration(
                          suffix: Text(
                            clength.toString(),
                            style: GoogleFonts.quicksand(
                                color: clength < 0 ? Colors.red : Colors.white),
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                              left: 15, bottom: 11, top: 11, right: 15),
                          hintStyle: GoogleFonts.quicksand(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: Colors.white),
                          hintText: title),
                      style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                    SizedBox(height: 30.0),
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (isAnonymous) {
                            isAnonymous = false;
                          } else {
                            isAnonymous = true;
                          }
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Post Anonymously',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.quicksand(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                          SizedBox(width: 5.0),
                          Icon(
                              isAnonymous == false
                                  ? FlutterIcons.md_radio_button_off_ion
                                  : FlutterIcons.md_radio_button_on_ion,
                              size: 20,
                              color: Colors.white),
                        ],
                      ),
                    ),
                    SizedBox(height: 30.0),
                    InkWell(
                      onTap: () async {
                        if (isPosting) {
                          return;
                        }
                        if (contentController.text.isEmpty || clength < 0) {
                          return;
                        }

                        setState(() {
                          isPosting = true;
                        });

                        var res = await post();
                        if (res) {
                          setState(() {
                            isPosting = false;
                          });
                          Navigator.pop(context, true);
                        }
                      },
                      child: CircleAvatar(
                          radius: 25.0,
                          backgroundColor: Colors.white,
                          child: isPosting
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: LoadingIndicator(
                                    indicatorType: Indicator.orbit,
                                    color: Colors.white,
                                  ))
                              : Icon(FlutterIcons.send_mdi,
                                  color: Colors.deepPurpleAccent)),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> post() async {
    var post = Post(
        content: contentController.text,
        tcQuestion: widget.question,
        isAnonymous: isAnonymous);

    var res = widget.course == null && widget.club == null
        ? await createPost(post)
        : widget.club != null
            ? await createClubPost(post, widget.club)
            : await createCoursePost(post, widget.course);

    setState(() {
      clength = 300;
    });
    contentController.clear();
    return res;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    contentController.dispose();
  }
}
