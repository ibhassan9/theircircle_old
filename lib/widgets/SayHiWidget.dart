import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/user.dart';

class SayHiWidget extends StatefulWidget {
  final PostUser receiver;

  SayHiWidget({this.receiver});

  @override
  _SayHiWidgetState createState() => _SayHiWidgetState();
}

class _SayHiWidgetState extends State<SayHiWidget>
    with AutomaticKeepAliveClientMixin {
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(50.0, 0, 50.0, 0.0),
      child: Container(
        height: MediaQuery.of(context).size.height / 1.4,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FlutterIcons.nature_people_mdi,
                  color: Theme.of(context).accentColor, size: 30),
              SizedBox(height: 15.0),
              Text("Need an opener? A simple 'hey' can go a long way!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor))
            ],
          ),
        ),
      ),
    );
  }

  bool get wantKeepAlive => true;
}
