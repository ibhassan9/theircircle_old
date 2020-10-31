import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ChatPage.dart';

class MyConversationWidget extends StatefulWidget {
  final PostUser user;
  final String lastMessage;
  final String chatId;
  MyConversationWidget(
      {Key key,
      @required this.user,
      @required this.lastMessage,
      @required this.chatId})
      : super(key: key);
  @override
  _MyConversationWidgetState createState() => _MyConversationWidgetState();
}

class _MyConversationWidgetState extends State<MyConversationWidget> {
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
                      ))).then((value) {
            setState(() {});
          });
        },
        child: Row(
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
            SizedBox(width: 15.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.user.name,
                    style: GoogleFonts.quicksand(
                      textStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    )),
                Text(widget.lastMessage,
                    style: GoogleFonts.quicksand(
                      textStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
