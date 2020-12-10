import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PreviewPage extends StatefulWidget {
  final String videoPath;

  PreviewPage({this.videoPath});
  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  Widget build(BuildContext context) {
    print("From Preview Page: " + widget.videoPath);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text('CREATE',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            )),
      ),
      backgroundColor: Colors.white,
    );
  }
}
