import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/widgets/BlockedUserWidget.dart';

class MyBlockedUsers extends StatefulWidget {
  @override
  _MyBlockedUsersState createState() => _MyBlockedUsersState();
}

class _MyBlockedUsersState extends State<MyBlockedUsers> {
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            centerTitle: true,
            elevation: 0.5,
            title: Text(
              'Blocked Users',
              style: GoogleFonts.quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).accentColor),
            )),
        body: body());
  }

  Widget body() {
    return FutureBuilder(
      future: getBlocks(),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          Map<String, String> blockList = snapshot.data;
          var uids = blockList.keys.toList();
          var unis = blockList.values.toList();
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return FutureBuilder(
                future: uids[index] != unis[index]
                    ? getUserWithUniversity(uids[index], unis[index])
                    : getUser(uids[index]),
                builder: (c, snap) {
                  if (snap.hasData &&
                      snap.connectionState == ConnectionState.done) {
                    PostUser user = snap.data;
                    Function unblockUser = () async {
                      await unblock(user.id).then((value) {
                        setState(() {});
                      });
                    };
                    return BlockedUserWidget(
                      user: user,
                      unblock: unblockUser,
                    );
                  } else {
                    return Container();
                  }
                },
              );
            },
          );
        } else {
          return Container();
        }
      },
    );
  }
}
