import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeWidget extends StatefulWidget {
  final Function create;
  final Function answerQuestion;
  final Function startRoom;
  WelcomeWidget({this.create, this.answerQuestion, this.startRoom});
  @override
  _WelcomeWidgetState createState() => _WelcomeWidgetState();
}

class _WelcomeWidgetState extends State<WelcomeWidget> {
  var name = "";

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 0.0),
      child: Container(
          color: Theme.of(context).backgroundColor,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name != null
                            ? name.isNotEmpty
                                ? "Hello $name,"
                                : "Hello,"
                            : "Hello,",
                        style: GoogleFonts.quicksand(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).accentColor),
                      ),
                      Text(
                        "Here is your university digest",
                        style: GoogleFonts.quicksand(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).accentColor),
                      ),
                    ],
                  )),
                  Icon(FlutterIcons.circle_double_mco,
                      color: Theme.of(context).accentColor)
                ],
              ),
            ],
          )),
    );
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<Null> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _name = prefs.getString('name');
    setState(() {
      name = _name;
    });
  }
}
