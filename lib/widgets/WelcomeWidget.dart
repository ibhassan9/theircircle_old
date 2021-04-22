import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_unicons/unicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/user.dart';

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

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Widget build(BuildContext context) {
    // return Padding(
    //   padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 5.0),
    //   child: Container(
    //     child: Column(
    //       children: [
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             InkWell(
    //               onTap: () {
    //                 widget.create();
    //               },
    //               child: Container(
    //                 child: Row(
    //                   children: [
    //                     CircleAvatar(
    //                       radius: 10.0,
    //                       backgroundColor: Colors.teal,
    //                     ),
    //                     const SizedBox(width: 10.0),
    //                     Text(
    //                       "What's on your mind today?",
    //                       style: GoogleFonts.manrope(),
    //                     )
    //                   ],
    //                 ),
    //               ),
    //             ),
    //             Row(
    //               children: [
    //                 Icon(FlutterIcons.poll_mdi, size: 15.0),
    //                 SizedBox(width: 3.0),
    //                 Icon(FlutterIcons.photo_camera_mdi, size: 15.0),
    //                 SizedBox(width: 3.0)
    //               ],
    //             )
    //           ],
    //         ),
    //         const Divider(),
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             InkWell(
    //               onTap: () {
    //                 widget.answerQuestion();
    //               },
    //               child: Container(
    //                 width: MediaQuery.of(context).size.width / 2.15,
    //                 decoration: BoxDecoration(
    //                   // color: Colors.purple,
    //                   border: Border.all(color: Colors.purple, width: 2.0),
    //                   borderRadius: BorderRadius.circular(5.0),
    //                 ),
    //                 child: Center(
    //                   child: Padding(
    //                     padding: const EdgeInsets.only(top: 7.0, bottom: 7.0),
    //                     child: Row(
    //                       mainAxisAlignment: MainAxisAlignment.center,
    //                       children: [
    //                         Icon(FlutterIcons.md_happy_ion, size: 15.0),
    //                         SizedBox(width: 5.0),
    //                         Text("Answer Question",
    //                             style: GoogleFonts.manrope(
    //                                 color: Theme.of(context).accentColor)),
    //                       ],
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //             InkWell(
    //               onTap: () {
    //                 widget.startRoom();
    //               },
    //               child: Container(
    //                 width: MediaQuery.of(context).size.width / 2.15,
    //                 decoration: BoxDecoration(
    //                   //color: Colors.teal,
    //                   border: Border.all(color: Colors.teal, width: 2.0),
    //                   borderRadius: BorderRadius.circular(5.0),
    //                 ),
    //                 child: Center(
    //                   child: Padding(
    //                     padding: const EdgeInsets.only(top: 7.0, bottom: 7.0),
    //                     child: Row(
    //                       mainAxisAlignment: MainAxisAlignment.center,
    //                       children: [
    //                         Icon(FlutterIcons.more_vert_mdi, size: 15.0),
    //                         SizedBox(width: 5.0),
    //                         Text("Start a room",
    //                             style: GoogleFonts.manrope(
    //                                 color: Theme.of(context).accentColor)),
    //                       ],
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             )
    //           ],
    //         ),
    //       ],
    //     ),
    //   ),
    // );
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
                        style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).accentColor),
                      ),
                      Text(
                        "Here is your university digest",
                        style: GoogleFonts.manrope(
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
              // Divider(),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     InkWell(
              //       onTap: () {
              //         widget.create();
              //       },
              //       child: Container(
              //         child: Row(
              //           children: [
              //             CircleAvatar(
              //               radius: 10.0,
              //               backgroundColor: Colors.blue,
              //             ),
              //             const SizedBox(width: 10.0),
              //             Text(
              //               "What's on your mind today?",
              //               style: GoogleFonts.manrope(
              //                   fontWeight: FontWeight.w500),
              //             )
              //           ],
              //         ),
              //       ),
              //     ),
              //     Row(
              //       children: [
              //         Icon(FlutterIcons.poll_mdi, size: 15.0),
              //         SizedBox(width: 3.0),
              //         Icon(FlutterIcons.photo_camera_mdi, size: 15.0),
              //         SizedBox(width: 3.0)
              //       ],
              //     )
              //   ],
              // ),
              //SizedBox(height: 5.0),
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
