import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/notification.dart' as noti;
import 'package:unify/widgets/NotificationWidget.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  Future<List<noti.Notification>> notificationFuture;
  Widget build(BuildContext context) {
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
                        return NotificationWidget(
                          notification: notification,
                        );
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

  AppBar appBar() {
    return AppBar(
      backgroundColor: Theme.of(context).backgroundColor,
      centerTitle: true,
      iconTheme: IconThemeData(color: Theme.of(context).accentColor),
      title: Text(
        "Notifications",
        style: GoogleFonts.questrial(
          textStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).accentColor),
        ),
      ),
      elevation: 0.0,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationFuture = noti.fetchNotifications();
  }
}
