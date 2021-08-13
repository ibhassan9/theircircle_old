import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:unify/Models/user.dart';

class BlockedUserWidget extends StatelessWidget {
  final PostUser user;
  final Function unblock;

  BlockedUserWidget({this.user, this.unblock});

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                child: Row(
              children: [
                user.profileImgUrl == null || user.profileImgUrl == ''
                    ? CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(user.name.substring(0, 1),
                            style: GoogleFonts.quicksand(color: Colors.white)))
                    : Hero(
                        tag: user.id,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(
                            user.profileImgUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) return child;
                              return SizedBox(
                                height: 40,
                                width: 40,
                                child: Center(
                                  child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: LoadingIndicator(
                                        indicatorType:
                                            Indicator.ballClipRotateMultiple,
                                        color: Theme.of(context).accentColor,
                                      )),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                SizedBox(width: 5.0),
                Text(
                  user.name,
                  style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).accentColor),
                ),
              ],
            )),
            InkWell(
              onTap: () {
                unblock();
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    borderRadius: BorderRadius.circular(3.0)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                  child: Center(
                      child: Text(
                    'Unblock',
                    style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white),
                  )),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
