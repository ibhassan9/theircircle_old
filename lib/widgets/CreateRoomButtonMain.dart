import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/pages/CreateRoom.dart';

class CreateRoomButtonMain extends StatefulWidget {
  final Function reloadRooms;

  CreateRoomButtonMain({Key key, this.reloadRooms}) : super(key: key);
  @override
  _CreateRoomButtonMainState createState() => _CreateRoomButtonMainState();
}

class _CreateRoomButtonMainState extends State<CreateRoomButtonMain> {
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: InkWell(
        onTap: () async {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => CreateRoom())).then((v) {
            if (v == true) {
              widget.reloadRooms();
            }
          });
        },
        child: Column(
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: Container(
                      height: 100,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Theme.of(context).buttonColor.withOpacity(0.15),
                        // border: Border.all(
                        //     color:
                        //         Theme.of(context).buttonColor.withOpacity(0.1),
                        //     width: 2.0)
                      ),
                      child: Icon(FlutterIcons.add_mdi,
                          color: Theme.of(context).accentColor)),
                ),
                Positioned(
                  top: 0.0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 7.0,
                    backgroundColor: Colors.transparent,
                    child: SizedBox(height: 30, width: 30, child: Container()),
                  ),
                )
              ],
            ),
            SizedBox(height: 5.0),
            Container(
              width: 60,
              child: Center(
                child: Text('Create',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.kulimPark(
                        fontSize: 14.0, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
