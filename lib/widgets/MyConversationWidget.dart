import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyConversationWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.pink,
          ),
          SizedBox(width: 15.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nevaeh',
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  )),
              Text('I think I have seen you in my math class',
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ))
            ],
          )
        ],
      ),
    );
  }
}
