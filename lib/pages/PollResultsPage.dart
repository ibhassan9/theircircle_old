import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/widgets/PollResultWidget.dart';

class PollResultsPage extends StatefulWidget {
  final Map<dynamic, dynamic> votes;
  final String questionOne;
  final String questionTwo;
  PollResultsPage(
      {Key key,
      @required this.votes,
      @required this.questionOne,
      @required this.questionTwo})
      : super(key: key);
  @override
  _PollResultsPageState createState() => _PollResultsPageState();
}

class _PollResultsPageState extends State<PollResultsPage> {
  TextEditingController bioController = TextEditingController();
  TextEditingController igController = TextEditingController();
  TextEditingController scController = TextEditingController();
  TextEditingController linkedinController = TextEditingController();

  List<PostUser> option1users = [];
  List<PostUser> option2users = [];

  int selectedOption = 1;

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        title: Text(
          "Poll Results",
          style: GoogleFonts.quicksand(
            textStyle: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: ListView(
        children: [
          Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    selectedOption = 1;
                  });
                },
                child: Text(
                  widget.questionOne,
                  style: GoogleFonts.quicksand(
                    textStyle: selectedOption == 1
                        ? TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.blue)
                        : TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                  ),
                ),
              ),
              Text(
                " | ",
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    selectedOption = 2;
                  });
                },
                child: Text(
                  widget.questionTwo,
                  style: GoogleFonts.quicksand(
                    textStyle: selectedOption == 2
                        ? TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.blue)
                        : TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                  ),
                ),
              ),
            ],
          )),
          SizedBox(height: 10.0),
          ListView.builder(
              itemCount: selectedOption == 1
                  ? option1users.length
                  : option2users.length,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                PostUser user = selectedOption == 1
                    ? option1users[index]
                    : option2users[index];
                Function f = () {
                  // showProfile(user, context, bioController, scController,
                  //     igController, linkedinController, null, null);
                };
                return PollResultWidget(
                    peer: user,
                    show: f,
                    question: selectedOption == 1
                        ? widget.questionOne
                        : widget.questionTwo);
              }),
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.votes == null) {
      return;
    }
    getData();
  }

  getData() async {
    for (var key in widget.votes.keys) {
      String userId = key;
      int option = widget.votes[key];
      if (option == 1) {
        PostUser user = await getUser(userId);
        option1users.add(user);
      } else if (option == 2) {
        PostUser user = await getUser(userId);
        option2users.add(user);
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    bioController.dispose();
    igController.dispose();
    scController.dispose();
    linkedinController.dispose();
  }
}
