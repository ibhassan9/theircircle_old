import 'package:flutter/material.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.0,
        centerTitle: false,
        title: Text(
          "Code Verification",
          style: GoogleFonts.quicksand(
            textStyle: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              Text(
                "We have sent a verification code to the email you have provided. Please enter it below to verify your account.",
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              VerificationCode(
                textStyle: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
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
                    style: GoogleFonts.quicksand(
                      textStyle: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue),
                    ),
                  ),
                ),
                onCompleted: (String value) async {
                  if (value == widget.code.toString()) {
                    // do something
                    print("Code is correct");
                    var result = await updateVerification(widget.uid);
                    if (result) {
                      await signInUser(widget.email, widget.password, context);
                    }
                  } else {
                    print("Code is wrong");
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
}
