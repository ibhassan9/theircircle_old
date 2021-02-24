import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Components/Constants.dart';

class ShareFeelingPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        centerTitle: true,
        iconTheme: IconThemeData(color: Theme.of(context).accentColor),
        title: Text(
          "How are you feeling today?",
          style: TextStyle(
              fontFamily: "Futura1",
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).accentColor),
        ),
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
        child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 4.0),
            itemCount: 20,
            itemBuilder: (context, index) {
              String feelings =
                  Constants.feelings.keys.toList().elementAt(index);
              String emoji =
                  Constants.feelings.values.toList().elementAt(index);
              return InkWell(
                onTap: () {
                  Navigator.pop(context, feelings);
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).buttonColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5.0)),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$emoji',
                          style: TextStyle(
                              fontFamily: "Medium",
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          '$feelings',
                          style: GoogleFonts.quicksand(
                              color: Theme.of(context).accentColor,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
