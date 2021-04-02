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
    return InkWell(
      onTap: () async {
        Navigator.push(
                context, MaterialPageRoute(builder: (context) => CreateRoom()))
            .then((v) {
          if (v == true) {
            widget.reloadRooms();
          }
        });
      },
      child: Column(
        children: [
          Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(15.0)),
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
    );
  }
}
