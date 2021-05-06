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
            Container(
                height: 85,
                width: 85,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    color: Theme.of(context).buttonColor.withOpacity(0.3),
                    border: Border.all(
                        color: Theme.of(context).buttonColor.withOpacity(0.1),
                        width: 2.0)),
                child: Icon(FlutterIcons.add_mdi,
                    color: Theme.of(context).accentColor)),
            SizedBox(height: 5.0),
            Container(
              width: 60,
              child: Center(
                child: Text('Create',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                        fontSize: 12.0, fontWeight: FontWeight.w600),
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
