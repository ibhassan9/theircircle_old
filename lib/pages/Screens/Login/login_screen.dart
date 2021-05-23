import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/Screens/Login/components/body.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  bool loading = false;

  @override
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
      // body: Body(),

      body: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back!',
              textAlign: TextAlign.center,
              style: GoogleFonts.kulimPark(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).accentColor),
            ),
            Text(
              'Please sign in below.',
              textAlign: TextAlign.center,
              style: GoogleFonts.kulimPark(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).buttonColor),
            ),
            SizedBox(height: 40.0),
            Text(
              'Email Address',
              textAlign: TextAlign.center,
              style: GoogleFonts.kulimPark(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).buttonColor),
            ),
            TextField(
              autofocus: true,
              controller: emailController,
              textInputAction: TextInputAction.next,
              style: GoogleFonts.kulimPark(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).accentColor),
              decoration: InputDecoration(
                hintText: 'example@institute.ca',
                hintStyle: GoogleFonts.kulimPark(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).buttonColor),
                border: InputBorder.none,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              'Password',
              textAlign: TextAlign.center,
              style: GoogleFonts.kulimPark(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).buttonColor),
            ),
            TextField(
              controller: passwordcontroller,
              obscureText: true,
              style: GoogleFonts.kulimPark(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).accentColor),
              decoration: InputDecoration(
                hintText: '• • • • • • • • •',
                hintStyle: GoogleFonts.kulimPark(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).buttonColor),
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 10, right: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              onTap: () async {
                if (loading) {
                  return;
                }

                if (emailController.text.trim().isEmpty ||
                    passwordcontroller.text.trim().isEmpty) {
                  Constants.showMsg(
                      content: 'All fields are required', context: context);
                  return;
                }
                setState(() {
                  loading = true;
                });

                await signInUser(
                    email: emailController.text.trim(),
                    password: passwordcontroller.text.trim(),
                    context: context,
                    onError: () {
                      setState(() {
                        loading = false;
                      });
                    });
              },
              child: CircleAvatar(
                  radius: 20.0,
                  backgroundColor: Theme.of(context).accentColor,
                  child: loading
                      ? SizedBox(
                          height: 20.0,
                          width: 20.0,
                          child: LoadingIndicator(
                              color: Theme.of(context).backgroundColor,
                              indicatorType: Indicator.ballRotate))
                      : Icon(Icons.arrow_right,
                          color: Theme.of(context).backgroundColor)),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordcontroller.dispose();
  }
}
