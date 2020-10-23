import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/user.dart';

class MyMatchWidget extends StatefulWidget {
  final PostUser user;
  MyMatchWidget({Key key, @required this.user}) : super(key: key);
  @override
  _MyMatchWidgetState createState() => _MyMatchWidgetState();
}

class _MyMatchWidgetState extends State<MyMatchWidget> {
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
      child: Column(
        children: [
          CircleAvatar(radius: 45, backgroundColor: Colors.pink),
          SizedBox(height: 5.0),
          Text(widget.user.name.split(' ')[0],
              style: GoogleFonts.quicksand(
                textStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black),
              ))
        ],
      ),
    );
  }
}
