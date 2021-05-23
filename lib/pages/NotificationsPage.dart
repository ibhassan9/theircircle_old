import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/notification.dart' as noti;
import 'package:unify/widgets/NotificationWidget.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with AutomaticKeepAliveClientMixin {
  Future<List<noti.Notification>> notificationFuture;

  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: appBar(),
      body: Stack(
        children: [
          ListView(
            children: [
              FutureBuilder(
                future: notificationFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        noti.Notification notification = snapshot.data[index];
                        if (notification.seen == false) {
                          noti.seenNotification(notification.notificationId);
                        }
                        var timeText = timeago.format(
                            new DateTime.fromMillisecondsSinceEpoch(
                                notification.timestamp));
                        if (index == 0) {
                          if (timeText.contains('day') ||
                              timeText.contains('second') ||
                              timeText.contains('minute')) {
                            return notificationWithBar(
                                'Recently', notification);
                          } else {
                            return notificationWithBar(
                                'Previous', notification);
                          }
                        } else {
                          noti.Notification notification2 =
                              snapshot.data[index - 1];
                          var timeText2 = timeago.format(
                              new DateTime.fromMillisecondsSinceEpoch(
                                  notification2.timestamp));
                          if ((timeText2.contains('day') ||
                                  timeText2.contains('second') ||
                                  timeText2.contains('minute')) &&
                              (timeText.contains('month') ||
                                  timeText.contains('year'))) {
                            return notificationWithBar(
                                'Previous', notification);
                          } else {
                            return NotificationWidget(
                              key: ValueKey(notification.notificationId),
                              notification: notification,
                            );
                          }
                        }
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget notificationWithBar(String title, noti.Notification notification) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: 15.0, right: 15.0, top: 5.0, bottom: 5.0),
          child: Text(
            title,
            maxLines: null,
            style: GoogleFonts.kulimPark(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).buttonColor.withOpacity(0.7)),
          ),
        ),
        NotificationWidget(
          key: ValueKey(notification.notificationId),
          notification: notification,
        ),
      ],
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Theme.of(context).backgroundColor,
      centerTitle: true,
      iconTheme: IconThemeData(color: Theme.of(context).accentColor),
      title: Text(
        "Activity",
        style: GoogleFonts.kulimPark(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).accentColor),
      ),
      elevation: 0.0,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationFuture = noti.fetchNotifications();
    //noti.seenAllNotifications();
  }

  bool get wantKeepAlive => true;
}
