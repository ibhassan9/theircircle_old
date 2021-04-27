import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/UserPage.dart';

class UserWidget extends StatefulWidget {
  final PostUser user;
  final Function show;

  UserWidget({Key key, this.user, this.show}) : super(key: key);

  @override
  _UserWidgetState createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  Color color;
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          widget.show();
        },
        child: Container(
          height: 150,
          width: 100,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    widget.user.name[0].toUpperCase(),
                    style: GoogleFonts.quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 10.0, bottom: 15.0),
                child: Text(
                  widget.user.name,
                  style: GoogleFonts.quicksand(
                      fontSize: widget.user.name.length > 16 ? 11 : 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    color = Constants.color();
  }
}
