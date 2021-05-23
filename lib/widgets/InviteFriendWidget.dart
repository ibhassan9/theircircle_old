import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class InviteFriendsWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 5.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).buttonColor.withOpacity(0.1),
                blurRadius: 4,
                spreadRadius: 4,
                offset: Offset(0, 0), // Shadow position
              ),
            ],
            gradient: LinearGradient(
              colors: [Colors.deepPurpleAccent, Colors.blue],
            )),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Invite Your Friends",
                          style: GoogleFonts.kulimPark(
                              fontWeight: FontWeight.w500,
                              color: Colors.white)),
                      Text("Let's build the community together!",
                          style: GoogleFonts.kulimPark(
                              fontWeight: FontWeight.w500, color: Colors.white))
                    ],
                  ),
                  Icon(FlutterIcons.circle_notch_faw5s, color: Colors.white)
                ],
              ),
              SizedBox(height: 10.0),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0)),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text("Send Invites",
                        style: GoogleFonts.kulimPark(
                            fontWeight: FontWeight.w500, color: Colors.black)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
