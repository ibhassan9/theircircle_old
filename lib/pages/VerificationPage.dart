import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';

class VerificationPage extends StatefulWidget {
  final String uid;
  final String email;
  final String password;
  VerificationPage({Key key, this.uid, this.email, this.password})
      : super(key: key);
  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  String _code;
  bool _onEditing = true;
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          brightness: Theme.of(context).brightness,
          leading: Container(),
          actions: [
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: Theme.of(context).accentColor))
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 70.0),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).accentColor),
                  borderRadius: BorderRadius.circular(5)),
              child: Center(
                child: Text(
                  "I have verified! Sign in.",
                  style: GoogleFonts.darkerGrotesque(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 100),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Almost There!',
                textAlign: TextAlign.center,
                style: GoogleFonts.darkerGrotesque(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).accentColor),
              ),
              Text(
                'We have sent an email to ${widget.email}. Please verify it to finish creating your account!',
                textAlign: TextAlign.left,
                style: GoogleFonts.darkerGrotesque(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).buttonColor),
              ),
            ])));
  }

  showCorrect() {
    Toast.show("Code entered is correct. Please wait.", context);
  }

  showWrong() {
    // final snackBar = SnackBar(
    //     content: Text('Sorry! The code is wrong please try again.',
    //         style: GoogleFonts.lexendDeca(
    //           textStyle: GoogleFonts. inter(
    //               fontSize: 15,
    //               fontWeight: FontWeight.w500,
    //               color: Colors.white),
    //         )));
    // Scaffold.of(context).showSnackBar(snackBar);
    Toast.show("Code entered is wrong. Please try again!", context);
  }
}
