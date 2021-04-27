import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Components/Constants.dart';

class AlreadyHaveAnAccountCheck extends StatefulWidget {
  final bool login;
  final Function press;
  const AlreadyHaveAnAccountCheck({
    Key key,
    this.login = true,
    this.press,
  }) : super(key: key);

  @override
  _AlreadyHaveAnAccountCheckState createState() =>
      _AlreadyHaveAnAccountCheckState();
}

class _AlreadyHaveAnAccountCheckState extends State<AlreadyHaveAnAccountCheck> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          widget.login
              ? "Don’t have an Account ? "
              : "Already have an Account ? ",
          style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).accentColor),
        ),
        GestureDetector(
          onTap: widget.press,
          child: Text(
            widget.login ? "Sign Up" : "Sign In",
            style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).accentColor),
          ),
        )
      ],
    );
  }
}
