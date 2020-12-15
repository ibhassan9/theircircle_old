import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterWidget extends StatefulWidget {
  final String text;
  final Function remove;
  FilterWidget({Key key, this.text, this.remove}) : super(key: key);
  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
      child: Container(
        height: 20,
        color: Theme.of(context).backgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.text,
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              ),
            ),
            InkWell(
                onTap: () {
                  widget.remove();
                },
                child: Icon(AntDesign.close, color: Colors.red, size: 20.0)),
          ],
        ),
      ),
    );
  }
}
