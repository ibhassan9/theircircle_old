import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ChatPage.dart';

class MyMatchWidget extends StatefulWidget {
  final PostUser user;
  final String chatId;
  MyMatchWidget({Key key, @required this.user, @required this.chatId})
      : super(key: key);
  @override
  _MyMatchWidgetState createState() => _MyMatchWidgetState();
}

class _MyMatchWidgetState extends State<MyMatchWidget> {
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(
                        receiver: widget.user,
                        chatId: widget.chatId,
                      )));
        },
        child: Column(
          children: [
            widget.user.profileImgUrl == null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(90),
                    child: Container(width: 90, height: 90, color: Colors.grey),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(90),
                    child: Image.network(
                      widget.user.profileImgUrl,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          height: 90,
                          width: 90,
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
            SizedBox(height: 5.0),
            Text(
              widget.user.name.split(' ')[0],
              style: GoogleFonts.quicksand(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            )
          ],
        ),
      ),
    );
  }
}
