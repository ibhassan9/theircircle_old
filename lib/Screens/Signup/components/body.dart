import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Screens/Login/login_screen.dart';
import 'package:unify/Screens/Signup/components/background.dart';
import 'package:unify/Screens/Signup/components/or_divider.dart';
import 'package:unify/Screens/Signup/components/social_icon.dart';
import 'package:unify/components/already_have_an_account_acheck.dart';
import 'package:unify/components/rounded_button.dart';
import 'package:unify/components/rounded_input_field.dart';
import 'package:unify/components/rounded_password_field.dart';
import 'package:unify/Models/user.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "SIGNUP",
              style: GoogleFonts.quicksand(
                textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ),
            SizedBox(height: size.height * 0.03),
            SvgPicture.asset(
              "assets/icons/signup.svg",
              height: size.height * 0.35,
            ),
            RoundedInputField(
              hintText: "Your Full Name",
              onChanged: (value) {},
              controller: nameController,
            ),
            RoundedInputField(
                hintText: "Your Email",
                onChanged: (value) {},
                controller: emailController),
            RoundedPasswordField(
                onChanged: (value) {}, controller: passwordController),
            RoundedButton(
              text: "SIGNUP",
              press: () async {
                final snackBar = SnackBar(
                    content: Text('Creating your account. Please wait.',
                        style: GoogleFonts.quicksand(
                          textStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        )));
                Scaffold.of(context).showSnackBar(snackBar);
                await registerUser(nameController.text, emailController.text,
                    passwordController.text, context);
                nameController.clear();
                emailController.clear();
                passwordController.clear();
              },
            ),
            OrDivider(),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
