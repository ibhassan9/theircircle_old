import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductWidget extends StatefulWidget {
  @override
  _ProductWidgetState createState() => _ProductWidgetState();
}

class _ProductWidgetState extends State<ProductWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
              child: Container(height: 215, color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
              child: Container(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "iClicker",
                      style: GoogleFonts.quicksand(
                        textStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                    ),
                    Text(
                      r"$ 20",
                      style: GoogleFonts.quicksand(
                        textStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
