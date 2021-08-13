import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CompleteProfileWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Complete Your Profile",
            style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w600, fontSize: 17.0)),
        SizedBox(height: 15.0),
        SvgPicture.asset(
          "assets/icons/login.svg",
          height: MediaQuery.of(context).size.height * 0.2,
        ),
        SizedBox(height: 10.0),
        Text("Please complete your profile",
            style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w800, fontSize: 15.0)),
        SizedBox(height: 5.0),
        Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 10.0),
          child: Text(
              "University students prefer to look at profiles that are complete. A complete profile helps other students identify your likings and connect with you easily.",
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                  color: Theme.of(context).buttonColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.0)),
        ),
        // Container(
        //   decoration: BoxDecoration(
        //       color: Colors.tealAccent,
        //       borderRadius: BorderRadius.circular(20.0)),
        //   child: Padding(
        //     padding: const EdgeInsets.fromLTRB(15.0, 7.0, 15.0, 7.0),
        //     child: Text("Go To Profile",
        //         style: GoogleFonts. inter(
        //             color: Colors.black,
        //             fontWeight: FontWeight.w800,
        //             fontSize: 13.0)),
        //   ),
        // ),
        // SizedBox(height: 15.0),
        Container(height: 7.0, color: Theme.of(context).dividerColor),
        SizedBox(height: 5.0),
      ],
    );
  }
}
