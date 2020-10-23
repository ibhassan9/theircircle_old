import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/user.dart';

class MatchWidget extends StatefulWidget {
  final PostUser user;
  MatchWidget({Key key, this.user}) : super(key: key);
  @override
  _MatchWidgetState createState() => _MatchWidgetState();
}

class _MatchWidgetState extends State<MatchWidget> {
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 5,
          blurRadius: 7,
          offset: Offset(0, 3), // changes position of shadow
        ),
      ], color: Colors.white, borderRadius: BorderRadius.circular(20.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0)),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2,
              color: Colors.grey,
              child: Image.network(
                widget.user.profileImgUrl == null
                    ? Constants.dummyImageUrl
                    : widget.user.profileImgUrl,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: new AlwaysStoppedAnimation<Color>(
                            Colors.grey.shade600),
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 8.0),
            child: Container(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name,
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
                Text(
                  widget.user.email,
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
                Text(
                  widget.user.bio == null || widget.user.bio.isEmpty
                      ? 'Bio is not available for this user.'
                      : widget.user.bio,
                  style: GoogleFonts.quicksand(
                    textStyle: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                ),
              ],
            )),
          )
        ],
      ),
    );
  }
}
