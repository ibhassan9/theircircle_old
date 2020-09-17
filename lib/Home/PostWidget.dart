import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/Comments/post_detail_page.dart';

class PostWidget extends StatefulWidget {
  final Post post;
  final String timeAgo;
  final Course course;

  PostWidget({Key key, @required this.post, this.timeAgo, this.course})
      : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isLiked = false;

  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PostDetailPage(
                      post: widget.post,
                      course: widget.course,
                    )));
      },
      child: Container(
        child: Wrap(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            widget.post.username[0].toUpperCase(),
                            style: GoogleFonts.aleo(
                              textStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          widget.post.username,
                          style: GoogleFonts.cabin(
                            textStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.black),
                          ),
                        )
                      ],
                    ),
                  ),
                  Text(widget.timeAgo,
                      style: GoogleFonts.cabin(
                        textStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                      )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                widget.post.content,
                style: GoogleFonts.cabin(
                  textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black),
                ),
              ),
            ),
            widget.post.imgUrl != null
                ? Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, right: 10.0, bottom: 5.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Container(
                        color: Colors.grey.shade300,
                        child: Image.network(
                          widget.post.imgUrl,
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              height: 200,
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      Colors.grey.shade600),
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
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
                  )
                : Container(),
            widget.post.questionOne != null && widget.post.questionTwo != null
                ? Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 10.0),
                        child: ButtonTheme(
                          height: 50,
                          minWidth: MediaQuery.of(context).size.width,
                          child: FlatButton(
                            color: Colors.deepPurple.shade400,
                            child: Text(
                              widget.post.questionOne,
                              style: GoogleFonts.quicksand(
                                textStyle: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: ButtonTheme(
                          height: 50,
                          minWidth: MediaQuery.of(context).size.width,
                          child: FlatButton(
                            color: Colors.blue.shade400,
                            child: Text(
                              widget.post.questionTwo,
                              style: GoogleFonts.quicksand(
                                textStyle: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(),
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    icon: Icon(FontAwesome.heart,
                        color: isLiked == false
                            ? Colors.grey.shade300
                            : Colors.red),
                    onPressed: () {
                      setState(() {
                        isLiked == true ? isLiked = false : isLiked = true;
                      });
                    },
                  ),
                  Text(
                    "${widget.post.likeCount}",
                    style: GoogleFonts.quicksand(
                      textStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade300),
                    ),
                  ),
                  IconButton(
                    icon: Icon(MaterialIcons.comment,
                        color: Colors.grey.shade300),
                    onPressed: () {},
                  ),
                  Text(
                    "${widget.post.commentCount}",
                    style: GoogleFonts.quicksand(
                      textStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade300),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 10,
              color: Colors.grey.shade50,
            ),
          ],
        ),
      ),
    );
  }
}
