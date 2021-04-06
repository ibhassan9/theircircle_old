import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_unicons/unicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/pages/Suggestions/InitialPage.dart';
import 'package:unify/pages/TodaysQuestionPage.dart';

class TodaysQuestionWidget extends StatefulWidget {
  final Function refresh;
  final String question;
  TodaysQuestionWidget({Key key, this.refresh, this.question})
      : super(key: key);
  @override
  _TodaysQuestionWidgetState createState() => _TodaysQuestionWidgetState();
}

class _TodaysQuestionWidgetState extends State<TodaysQuestionWidget> {
  TextEditingController contentController = TextEditingController();
  String title = "Tell us about it here...";
  int clength = 300;

  bool isPosting = false;
  bool isAnonymous = false;

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
      child: InkWell(
        onTap: () {
          if (widget.question == null) {
            return;
          }

          // showBarModalBottomSheet(
          //     context: context,
          //     builder: (context) => questionContainer(),
          //     expand: true);
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TodaysQuestionPage(question: widget.question)))
              .then((value) {
            if (value == false) {
              return;
            }
            widget.refresh();
          });
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => InitialSuggestionsPage()));
        },
        child: Container(
          height: 50.0,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.teal, Colors.blue]),
              borderRadius: BorderRadius.circular(5.0)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Unicon(
                UniconData.uniSmileBeam,
                color: Colors.white,
              ),
              SizedBox(width: 15.0),
              Text(
                "We've got a question for you!",
                style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    contentController.dispose();
  }
}
