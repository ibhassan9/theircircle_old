import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stretchy_header/stretchy_header.dart';
import 'package:toast/toast.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ChatPage.dart';

class ProfilePage extends StatefulWidget {
  final PostUser user;
  final String heroTag;
  final bool isFromChat;

  ProfilePage({Key key, this.user, this.heroTag, this.isFromChat})
      : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  var height = 400.0;
  bool isBlocked;

  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        brightness: widget.user.profileImgUrl != null &&
                widget.user.profileImgUrl.isNotEmpty
            ? Brightness.dark
            : Brightness.light,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(FlutterIcons.arrow_back_mdi,
                color: widget.user.profileImgUrl != null &&
                        widget.user.profileImgUrl.isNotEmpty
                    ? Colors.white
                    : Colors.black)),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: StretchyHeader.singleChild(
        headerData: HeaderData(
          headerHeight: height,
          header: picture(),
          highlightHeaderAlignment: HighlightHeaderAlignment.bottom,
          highlightHeader: Container(
            width: MediaQuery.of(context).size.width,
            child:
                Padding(padding: const EdgeInsets.all(8.0), child: socials()),
          ),
          blurContent: false,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: body(),
        ),
      ),
    );
  }

  Widget body() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.name + ',',
                    style: GoogleFonts.questrial(
                      textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).accentColor),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(FlutterIcons.graduation_cap_ent,
                          color: Theme.of(context).buttonColor, size: 17.0),
                      SizedBox(width: 5.0),
                      Text(
                        widget.user.university,
                        style: GoogleFonts.questrial(
                          textStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).buttonColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  isBlocked
                      ? unblock(widget.user.id)
                      : block(widget.user.id, widget.user.university);
                  setState(() {
                    isBlocked = isBlocked ? false : true;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(15.0)),
                  width: 75,
                  height: 30,
                  child: Center(
                    child: Text(
                      isBlocked ? "Unblock" : "Block",
                      style: GoogleFonts.questrial(
                        textStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(),
          about(),
          // Text(
          //   "My accomplishments",
          //   style: GoogleFonts.questrial(
          //     textStyle: TextStyle(
          //         fontSize: 16,
          //         fontWeight: FontWeight.w700,
          //         color: Colors.grey[700]),
          //   ),
          // ),
          Divider(),
          accomplishments(),
          // SizedBox(height: 20.0),
          // Text("Places i've visited"),
          // Divider(),
          interests(),
          //places(),
        ],
      ),
    );
  }

  Widget picture() {
    return Hero(
      tag: widget.heroTag,
      child: widget.user.profileImgUrl != null &&
              widget.user.profileImgUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(0.0),
              child: Container(
                child: Image.network(
                  widget.user.profileImgUrl,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Colors.grey.shade600),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes
                                : null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.grey[300],
              child: Icon(AntDesign.user, color: Colors.black, size: 30.0)),
    );
  }

  Widget about() {
    return widget.user.about != null && widget.user.about.isNotEmpty
        ? Text(
            widget.user.about,
            style: GoogleFonts.questrial(
              textStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).accentColor),
            ),
          )
        : Text(
            'Nothing to see here... :(',
            style: GoogleFonts.questrial(
              textStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).accentColor),
            ),
          );
  }

  Widget accomplishments() {
    String result = '';
    if (widget.user.accomplishments != null) {
      for (var acc in widget.user.accomplishments) {
        if (acc.isNotEmpty) {
          result = result + '• $acc\n\n';
        }
      }
    }
    result.trimRight();
    print(result);
    return result.isNotEmpty
        ? Text(
            result,
            style: GoogleFonts.questrial(
              textStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).accentColor),
            ),
          )
        : SizedBox();
  }

  Widget interests() {
    return widget.user.interests != null && widget.user.interests.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "I'm interested in",
                style: GoogleFonts.questrial(
                  textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor),
                ),
              ),
              Divider(),
              Wrap(
                children: _buildChoicesList(),
              ),
              Divider(),
            ],
          )
        : SizedBox();
  }

  Widget socials() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            if (widget.user.snapchatHandle != null &&
                widget.user.snapchatHandle.isNotEmpty) {
              showHandle(text: widget.user.snapchatHandle);
            } else {
              Toast.show('Snapchat not available', context);
            }
          },
          child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20.0,
              child:
                  Icon(FlutterIcons.snapchat_ghost_faw, color: Colors.black)),
        ),
        SizedBox(width: 5.0),
        InkWell(
          onTap: () {
            if (widget.user.linkedinHandle != null &&
                widget.user.linkedinHandle.isNotEmpty) {
              showHandle(text: widget.user.linkedinHandle);
            } else {
              Toast.show('LinkedIn not available', context);
            }
          },
          child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20.0,
              child: Icon(FlutterIcons.linkedin_faw, color: Colors.blue)),
        ),
        SizedBox(width: 5.0),
        InkWell(
          onTap: () {
            if (widget.user.instagramHandle != null &&
                widget.user.instagramHandle.isNotEmpty) {
              showHandle(text: widget.user.instagramHandle);
            } else {
              Toast.show('Instagram not available', context);
            }
          },
          child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20.0,
              child: Icon(FlutterIcons.instagram_faw, color: Colors.black)),
        ),
        SizedBox(width: 5.0),
        Visibility(
          visible: widget.isFromChat == null && sameUniversity(),
          child: InkWell(
            onTap: () {
              goToChat();
            },
            child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20.0,
                child: Icon(FlutterIcons.message1_ant, color: Colors.black)),
          ),
        ),
      ],
    );
  }

  _buildChoicesList() {
    List<Widget> choices = List();
    for (var interest in widget.user.interests) {
      choices.add(Container(
        padding: const EdgeInsets.only(left: 0.0, right: 2.0),
        child: ChoiceChip(
          selectedColor: Colors.pink,
          label: Text(
            interest,
            style: GoogleFonts.questrial(
              textStyle: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
          ),
          onSelected: (selected) {
            setState(() {});
          },
          selected: true,
        ),
      ));
    }

    return choices;
  }

  Widget places() {
    return widget.user.interests != null && widget.user.interests.isNotEmpty
        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              "Places i've been to",
              style: GoogleFonts.questrial(
                textStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              ),
            ),
            Divider(),
            Wrap(
              children: _buildPlacesList(),
            ),
            Divider(),
          ])
        : SizedBox();
  }

  _buildPlacesList() {
    List<Widget> choices = List();
    for (var interest in widget.user.interests) {
      choices.add(Container(
        padding: const EdgeInsets.only(left: 0.0, right: 2.0),
        child: ChoiceChip(
          selectedColor: Colors.deepPurpleAccent,
          avatar: Text('🇸🇩'),
          label: Text(
            'Sudan',
            style: GoogleFonts.questrial(
              textStyle: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
          ),
          onSelected: (selected) {
            setState(() {});
          },
          selected: true,
        ),
      ));
    }

    return choices;
  }

  goToChat() {
    var chatId = '';
    var myID = firebaseAuth.currentUser.uid;
    var peerId = widget.user.id;
    if (myID.hashCode <= peerId.hashCode) {
      chatId = '$myID-$peerId';
    } else {
      chatId = '$peerId-$myID';
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatPage(
                  receiver: widget.user,
                  chatId: chatId,
                )));
  }

  showHandle({String text}) {
    AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.NO_HEADER,
      body: Center(
        child: Text(
          text,
          style: GoogleFonts.questrial(
            textStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).accentColor),
          ),
        ),
      ),
    )..show();
  }

  @override
  void initState() {
    super.initState();
    isBlocked = widget.user.isBlocked;
  }

  bool sameUniversity() {
    var uni = Constants.checkUniversity() == 0
        ? 'UofT'
        : Constants.checkUniversity() == 1
            ? 'YorkU'
            : 'WesternU';
    return uni == widget.user.university;
  }

  bool get wantKeepAlive => true;
}
