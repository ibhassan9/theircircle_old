import 'package:flutter/material.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';
import 'package:unify/Models/user.dart';

class VerificationPage extends StatefulWidget {
  final int code;
  final String uid;
  final String email;
  final String password;
  VerificationPage({Key key, this.code, this.uid, this.email, this.password})
      : super(key: key);
  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  String _code;
  bool _onEditing = true;
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          "CODE VERIFICATION",
          style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).accentColor),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(50.0, 20.0, 50.0, 10.0),
          child: Column(
            children: <Widget>[
              Text(
                "We have sent a code to verify your university email address.",
                style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).accentColor),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                "Sent to ${widget.email}",
                style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).buttonColor),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              VerificationCode(
                textStyle: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
                keyboardType: TextInputType.number,
                // in case underline color is null it will use primaryColor: Colors.red from Theme
                underlineColor: Colors.amber,
                length: 4,
                // clearAll is NOT required, you can delete it
                // takes any widget, so you can implement your design
                clearAll: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "Clear",
                    style: GoogleFonts.manrope(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue),
                  ),
                ),
                onCompleted: (String value) async {
                  if (value == widget.code.toString()) {
                    // do something
                    showCorrect();
                    var result = await updateVerification(widget.uid);
                    if (result) {
                      await signInUser(widget.email, widget.password, context);
                    }
                  } else {
                    showWrong();
                  }
                },
                onEditing: (bool value) {
                  setState(() {
                    _onEditing = value;
                  });
                  if (!_onEditing) FocusScope.of(context).unfocus();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  showCorrect() {
    Toast.show("Code entered is correct. Please wait.", context);
  }

  showWrong() {
    // final snackBar = SnackBar(
    //     content: Text('Sorry! The code is wrong please try again.',
    //         style: GoogleFonts.lexendDeca(
    //           textStyle: GoogleFonts.manrope(
    //               fontSize: 15,
    //               fontWeight: FontWeight.w500,
    //               color: Colors.white),
    //         )));
    // Scaffold.of(context).showSnackBar(snackBar);
    Toast.show("Code entered is wrong. Please try again!", context);
  }
}
