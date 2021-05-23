import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Components/Constants.dart';

class HashtagWidget extends StatefulWidget {
  final String title;

  HashtagWidget({Key key, @required this.title}) : super(key: key);

  @override
  _HashtagWidgetState createState() => _HashtagWidgetState();
}

class _HashtagWidgetState extends State<HashtagWidget> {
  Color c;
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.blueAccent, borderRadius: BorderRadius.circular(3.0)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              "${widget.title}",
              textAlign: TextAlign.center,
              style: GoogleFonts.kulimPark(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      c = Constants.color();
    });
  }
}
