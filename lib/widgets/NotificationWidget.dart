import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart';
import 'package:unify/Models/notification.dart' as noti;
import 'package:unify/Models/post.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ChatPage.dart';
import 'package:unify/pages/VideoPreview.dart';
import 'package:unify/pages/club_page.dart';
import 'package:unify/pages/course_page.dart';
import 'package:unify/pages/post_detail_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationWidget extends StatefulWidget {
  final noti.Notification notification;

  NotificationWidget({Key key, this.notification}) : super(key: key);
  @override
  _NotificationWidgetState createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget>
    with AutomaticKeepAliveClientMixin {
  String imgUrl;
  String name = '';
  String body = '';
  Widget build(BuildContext context) {
    super.build(context);
    return name.isNotEmpty && body.isNotEmpty
        ? InkWell(
            onTap: () async {
              await handleNotification();
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      imgUrl == null || imgUrl == ''
                          ? CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.grey[300],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.network(
                                imgUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: Center(
                                      child: SizedBox(
                                          width: 10,
                                          height: 10,
                                          child: LoadingIndicator(
                                            indicatorType:
                                                Indicator.ballClipRotate,
                                            color:
                                                Theme.of(context).accentColor,
                                          )),
                                    ),
                                  );
                                },
                              ),
                            ),
                      SizedBox(width: 10.0),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  name,
                                  maxLines: null,
                                  style: GoogleFonts.quicksand(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).accentColor),
                                ),
                                Text(
                                  ' • ',
                                  maxLines: 1,
                                  style: GoogleFonts.quicksand(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).buttonColor),
                                ),
                                Text(
                                  timeago.format(
                                      new DateTime.fromMillisecondsSinceEpoch(
                                          widget.notification.timestamp)),
                                  maxLines: null,
                                  style: GoogleFonts.quicksand(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).buttonColor),
                                ),
                              ],
                            ),
                            SizedBox(height: 3.0),
                            Text(body,
                                maxLines: null,
                                style: GoogleFonts.quicksand(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).buttonColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    thickness: 1.5,
                  ),
                ],
              ),
            ),
          )
        : Container();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.notification.university != null) {
      getUserWithUniversity(
              widget.notification.from, widget.notification.university)
          .then((value) {
        setState(() {
          imgUrl = value.profileImgUrl;
          name = value.name;
          body = widget.notification.body.replaceAll(name, "").trimLeft();
        });
      });
    } else {
      getUser(widget.notification.from).then((value) {
        setState(() {
          imgUrl = value.profileImgUrl;
          name = value.name;
          body = widget.notification.body.replaceAll(name, "").trimLeft();
        });
      });
    }
  }

  Future<Null> handleNotification() async {
    var screen = widget.notification.screen;
    var type = widget.notification.type;
    var postId = widget.notification.postId;
    var id = widget.notification.id;
    var chatId = widget.notification.chatId;

    switch (type) {
      // course, club, post, chat, video
      case "course":
        Course course = await fetchCourse(id);
        switch (screen) {
          case "COMMENT_PAGE":
            Post post = await fetchCoursePost(postId, id);
            var timeAgo =
                new DateTime.fromMillisecondsSinceEpoch(post.timeStamp);
            showBarModalBottomSheet(
                context: context,
                expand: true,
                builder: (context) => PostDetailPage(
                    post: post,
                    course: course,
                    timeAgo: timeago.format(timeAgo)));
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => PostDetailPage(
            //             post: post,
            //             course: course,
            //             timeAgo: timeago.format(timeAgo))));
            break;
          case "COURSE_PAGE":
            showBarModalBottomSheet(
                context: context,
                expand: true,
                builder: (context) => CoursePage(course: course));
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => CoursePage(course: course)));
        }
        break;
      case "club":
        Club club = await fetchClub(id);
        switch (screen) {
          case "COMMENT_PAGE":
            Post post = await fetchClubPost(postId, id);
            var timeAgo =
                new DateTime.fromMillisecondsSinceEpoch(post.timeStamp);
            showBarModalBottomSheet(
                context: context,
                expand: true,
                builder: (context) => PostDetailPage(
                    post: post, club: club, timeAgo: timeago.format(timeAgo)));
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => PostDetailPage(
            //             post: post,
            //             club: club,
            //             timeAgo: timeago.format(timeAgo))));
            break;
          case "CLUB_PAGE":
            showBarModalBottomSheet(
                context: context,
                expand: true,
                builder: (context) => ClubPage(club: club));
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => ClubPage(club: club)));
        }
        break;
      case "post":
        Post post = await fetchPost(postId);
        var timeAgo = new DateTime.fromMillisecondsSinceEpoch(post.timeStamp);
        showBarModalBottomSheet(
            context: context,
            expand: true,
            builder: (context) =>
                PostDetailPage(post: post, timeAgo: timeago.format(timeAgo)));
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => PostDetailPage(
        //               post: post,
        //               timeAgo: timeago.format(timeAgo),
        //             )));
        break;
      case "chat":
        PostUser receiver = await getUser(id);
        showBarModalBottomSheet(
            context: context,
            expand: true,
            builder: (context) => ChatPage(receiver: receiver, chatId: chatId));
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) =>
        //             ChatPage(receiver: receiver, chatId: chatId)));
        break;
      case "video":
        Video video = await VideoApi.fetchVideo(id);
        var timeAgo = new DateTime.fromMillisecondsSinceEpoch(video.timeStamp);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VideoPreview(
                    video: video, timeAgo: timeago.format(timeAgo))));
        break;
      default:
        return null;
        break;
    }
  }

  bool get wantKeepAlive => true;
}
