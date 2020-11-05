import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';
import 'package:unify/Models/user.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  TextEditingController contentController = TextEditingController();
  int clength = 1000;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        brightness: Brightness.light,
        title: Text(
          "Report an issue or a complaint",
          style: GoogleFonts.quicksand(
            textStyle: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Container(),
          TextField(
            controller: contentController,
            maxLines: null,
            onChanged: (value) {
              var newLength = 1000 - value.length;
              setState(() {
                clength = newLength;
              });
            },
            decoration: new InputDecoration(
                suffix: Text(
                  clength.toString(),
                  style:
                      TextStyle(color: clength < 0 ? Colors.red : Colors.grey),
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding:
                    EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                hintText: "What's the issue / complaint?"),
            style: GoogleFonts.quicksand(
              textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    IconButton(
                        icon: Icon(AntDesign.arrowright,
                            color: Colors.deepOrange),
                        onPressed: () async {
                          if (contentController.text.isEmpty) {
                            Toast.show('Issue/Complaint field cannot be empty.',
                                context);
                            return;
                          }
                          await sendReportEmail(contentController.text);
                          contentController.clear();
                          Toast.show(
                              'Your issue / complaint has been received.',
                              context);
                        }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}