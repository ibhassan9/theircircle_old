import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/room.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/DB.dart';
import 'package:unify/widgets/SpeakerIcon.dart';

class ConferencePage extends StatefulWidget {
  final Room room;
  ConferencePage({this.room});
  @override
  _ConferencePageState createState() => _ConferencePageState();
}

class _ConferencePageState extends State<ConferencePage>
    with AutomaticKeepAliveClientMixin {
  var db = FirebaseDatabase.instance.reference().child('rooms');
  Stream<Event> conference;
  Speaker myself;
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: Padding(padding: const EdgeInsets.all(15.0), child: _render()),
        bottomNavigationBar: toolbar());
  }

  _render() {
    return StreamBuilder(
      stream: conference,
      builder: (context, snap) {
        if (snap.hasData &&
            !snap.hasError &&
            snap.data.snapshot.value != null) {
          Map data = snap.data.snapshot.value;
          List<Speaker> speakers = [];
          List<Speaker> listeners = [];
          var speakersJSON = data['speakers'] as Map<dynamic, dynamic>;
          speakersJSON.forEach((key, value) {
            Speaker sp = Speaker(
                id: key,
                isSpeaking: value['isSpeaking'],
                isAudience: value['isAudience'],
                isMuted: value['isMuted']);

            if (sp.id == FIR_UID) {
              myself = sp;
            }

            if (sp.isAudience && sp.id != widget.room.adminId) {
              listeners.add(sp);
            } else {
              speakers.add(sp);
            }
          });

          speakers.sort((a, b) {
            return (b.id == widget.room.adminId)
                .toString()
                .compareTo((a.id == widget.room.adminId).toString());
          });

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 5.0, right: 20.0, top: 20.0, bottom: 30.0),
                child: Row(
                  children: [
                    // picture
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: CachedNetworkImage(
                          imageUrl: widget.room.imageUrl,
                          width: 35.0,
                          height: 35.0,
                          fit: BoxFit.cover),
                    ),
                    SizedBox(width: 10.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.room.name + "'s Conference",
                          style: GoogleFonts.quicksand(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).accentColor),
                        ),
                        Text(
                          '🗣️ ' + widget.room.description,
                          style: GoogleFonts.quicksand(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context)
                                  .accentColor
                                  .withOpacity(0.5)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              _renderSpeakerList(speakers),
              Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                child: Text('Listeners Area',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor.withOpacity(0.5),
                    )),
              ),
              _renderListenersList(listeners),
            ],
          );
        } else {
          return Text("Error");
        }
      },
    );
  }

  _renderSpeakerList(List<Speaker> speakers) {
    List<Widget> speakerIcons = [];
    for (var speaker in speakers) {
      if (!speaker.isAudience) {
        speakerIcons.add(SpeakerIcon(
            key: ValueKey(speaker.id), speaker: speaker, room: widget.room));
      }
    }

    return AnimationLimiter(
      child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: speakers.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 5.0,
            mainAxisSpacing: 5.0,
          ),
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: FadeInAnimation(child: speakerIcons[index]));
          }),
    );
  }

  _renderListenersList(List<Speaker> speakers) {
    List<Widget> speakerIcons = [];
    for (var speaker in speakers) {
      if (speaker.isAudience) {
        speakerIcons.add(SpeakerIcon(
            key: ValueKey(speaker.id), speaker: speaker, room: widget.room));
      }
    }

    return AnimationLimiter(
      child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: speakers.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 5.0,
            mainAxisSpacing: 5.0,
          ),
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: FadeInAnimation(child: speakerIcons[index]));
          }),
    );
  }

  Widget toolbar() {
    return myself != null
        ? Padding(
            padding:
                const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 30.0),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.circular(25.0)),
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [leaveButton(), muteButton(), changeRoleButton()],
                ),
              ),
            ),
          )
        : Container(height: 50);
  }

  Widget leaveButton() {
    return Icon(
      Icons.close,
      color: Theme.of(context).backgroundColor,
    );
  }

  Widget muteButton() {
    return InkWell(
      onTap: () async {
        var ref = db
            .child(Constants.uniString(uniKey))
            .child(widget.room.id)
            .child('conference');

        ref
            .child('speakers')
            .child(FIR_UID)
            .child('isMuted')
            .set(!myself.isMuted);
      },
      child: Icon(
        myself.isMuted ? Icons.mic_off : Icons.mic,
        color: Theme.of(context).backgroundColor,
      ),
    );
  }

  Widget changeRoleButton() {
    return InkWell(
      onTap: () {
        var ref = db
            .child(Constants.uniString(uniKey))
            .child(widget.room.id)
            .child('conference');

        ref
            .child('speakers')
            .child(FIR_UID)
            .child('isAudience')
            .set(!myself.isAudience);
      },
      child: Icon(
        myself.id == widget.room.adminId
            ? Icons.more_horiz
            : myself.isAudience
                ? Icons.call_made
                : Icons.call_end,
        color: Theme.of(context).backgroundColor,
      ),
    );
  }

  _initState() {
    var ref = db
        .child(Constants.uniString(uniKey))
        .child(widget.room.id)
        .child('conference');

    conference = ref.onValue;

    var myData = {
      'isMuted': true,
      'isAudience': true,
      'isSpeaking': false,
    };

    setState(() {
      myself = Speaker(
          id: FIR_UID, isAudience: true, isMuted: true, isSpeaking: false);
    });

    ref.child('speakers').child(FIR_UID).set(myData);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initState();
  }

  @override
  bool get wantKeepAlive => true;
}

class Speaker {
  String id;
  bool isSpeaking;
  bool isAudience;
  bool isMuted;

  Speaker({this.id, this.isSpeaking, this.isAudience, this.isMuted});
}
