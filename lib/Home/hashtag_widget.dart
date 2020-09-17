import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HashtagWidget extends StatefulWidget {
  final String title;

  HashtagWidget({Key key, @required this.title}) : super(key: key);

  @override
  _HashtagWidgetState createState() => _HashtagWidgetState();
}

class _HashtagWidgetState extends State<HashtagWidget> {
  Widget build(BuildContext context) {
    Color color() {
      Random random = new Random();
      int index = random.nextInt(6);
      switch (index) {
        case 1:
          {
            return Colors.deepOrangeAccent;
          }
          break;
        case 2:
          {
            return Colors.deepPurpleAccent;
          }
          break;
        case 3:
          {
            return Colors.blueAccent;
          }
          break;
        case 4:
          {
            return Colors.purpleAccent;
          }
          break;
        case 5:
          {
            return Colors.redAccent;
          }
          break;
        default:
          {
            return Colors.indigoAccent;
          }
          break;
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 0.0),
        child: Container(
          decoration: BoxDecoration(
              color: color(), borderRadius: BorderRadius.circular(20)),
          height: MediaQuery.of(context).size.height / 8,
          width: MediaQuery.of(context).size.height / 9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                child: Text(
                  "${widget.title}",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
