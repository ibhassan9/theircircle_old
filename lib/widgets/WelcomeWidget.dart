import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unify/Models/user.dart';

class WelcomeWidget extends StatefulWidget {
  @override
  _WelcomeWidgetState createState() => _WelcomeWidgetState();
}

class _WelcomeWidgetState extends State<WelcomeWidget> {
  var name = "";

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 5.0),
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
                                ? "Hey $name,"
                                : "Hey,"
                            : "Hey,",
                        style: GoogleFonts.questrial(
                          textStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).accentColor),
                        ),
                      ),
                      Text(
                        "Here is your university digest",
                        style: GoogleFonts.questrial(
                          textStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).accentColor),
                        ),
                      ),
                    ],
                  )),
                  Icon(FlutterIcons.feed_faw, color: Colors.deepPurpleAccent)
                ],
              ),
              // SizedBox(height: 5.0),
              // Divider(),
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
