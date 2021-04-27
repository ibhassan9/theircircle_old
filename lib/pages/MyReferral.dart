import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Components/Constants.dart';

class MyReferral extends StatefulWidget {
  @override
  _MyReferralState createState() => _MyReferralState();
}

class _MyReferralState extends State<MyReferral> {
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text('Referral',
            style: GoogleFonts.quicksand(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: body(),
    );
  }

  Widget body() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FlutterIcons.award_faw5s,
                size: 50.0, color: Theme.of(context).accentColor),
            SizedBox(height: 30.0),
            Text('10',
                style: GoogleFonts.quicksand(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 40.0)),
            SizedBox(height: 0.0),
            Text('credits earned',
                style: GoogleFonts.quicksand(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15.0)),
            SizedBox(height: 10.0),
            Divider(
              color: Theme.of(context).accentColor.withOpacity(0.2),
              thickness: 1.0,
            ),
            SizedBox(height: 10.0),
            Text('YOUR CODE',
                style: GoogleFonts.quicksand(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 10.0),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).accentColor.withOpacity(0.2),
                      width: 1.0)),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                child: Text(
                    clean(content: FirebaseAuth.instance.currentUser.uid),
                    style: GoogleFonts.quicksand(
                        color: Theme.of(context).accentColor,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            SizedBox(height: 10.0),
            Text(
                'Share this code with a student from your institute. When they use it to sign up you both earn 10 credits. To learn more about credits click below.',
                maxLines: null,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 10.0),
            Text('* Earn credits by being an active member of the community.',
                maxLines: null,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 30.0),
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.circular(20.0)),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20 + .0, top: 10.0, bottom: 10.0),
                child: Text('View Rewards',
                    style: GoogleFonts.quicksand(
                        color: Theme.of(context).backgroundColor,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String clean({String content}) {
    String result = '';
    for (var char in content.characters) {
      if (char.toUpperCase() == char) {
        if (double.tryParse(char) == null) {
          result += char;
        }
      }
    }
    return result;
  }
}
