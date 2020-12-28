import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stretchy_header/stretchy_header.dart';
import 'package:toast/toast.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/ChatPage.dart';
import 'package:unify/pages/MultiSelectChip.dart';
import 'package:unify/pages/MyBlockedUsers.dart';

class MyProfilePage extends StatefulWidget {
  final PostUser user;
  final String heroTag;

  MyProfilePage({Key key, this.user, this.heroTag}) : super(key: key);

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage>
    with AutomaticKeepAliveClientMixin {
  Image imag;
  File f;

  var height = 400.0;
  var _interests = [];
  TextEditingController aboutController = TextEditingController();
  TextEditingController accomplishmentOneController = TextEditingController();
  TextEditingController accomplishmentTwoController = TextEditingController();
  TextEditingController accomplishmentThreeController = TextEditingController();
  TextEditingController snapController = TextEditingController();
  TextEditingController instaController = TextEditingController();
  TextEditingController linkedinController = TextEditingController();
  bool isUpdating = false;

  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      bottomNavigationBar: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: createButton(),
      ),
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () async {
                      var res = await getImage();
                      if (res.isNotEmpty) {
                        var image = res[0] as Image;
                        var file = res[1] as File;
                        setState(() {
                          imag = image;
                          f = file;
                        });
                      }
                    },
                    child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 20.0,
                        child: Icon(FlutterIcons.photo_faw,
                            size: 17.0, color: Colors.black)),
                  )
                ],
              ),
            ),
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
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
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
                    children: [
                      Icon(FlutterIcons.graduation_cap_ent,
                          color: Theme.of(context).buttonColor, size: 17.0),
                      SizedBox(width: 5.0),
                      Text(
                        widget.user.university == 'UofT'
                            ? "University of Toronto"
                            : widget.user.university == 'YorkU'
                                ? "York University"
                                : "Western University",
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyBlockedUsers()));
                },
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent,
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                      child: Text('Blocked Users',
                          style: GoogleFonts.questrial(
                            textStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          )),
                    )),
              )
            ],
          ),
          Divider(),
          Text(
            "About myself",
            style: GoogleFonts.questrial(
              textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).accentColor),
            ),
          ),
          about(),
          Divider(),
          Text(
            "What i've accomplished",
            style: GoogleFonts.questrial(
              textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).accentColor),
            ),
          ),
          TextField(
            controller: accomplishmentOneController,
            decoration: new InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding:
                  EdgeInsets.only(left: 0, bottom: 11, top: 11, right: 0),
              hintText: "Insert accomplishment here...",
              hintStyle: GoogleFonts.questrial(
                textStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500]),
              ),
            ),
            style: GoogleFonts.questrial(
              textStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).accentColor),
            ),
          ),
          TextField(
            controller: accomplishmentTwoController,
            decoration: new InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding:
                  EdgeInsets.only(left: 0, bottom: 11, top: 11, right: 0),
              hintText: "Insert accomplishment here...",
              hintStyle: GoogleFonts.questrial(
                textStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500]),
              ),
            ),
            style: GoogleFonts.questrial(
              textStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).accentColor),
            ),
          ),
          TextField(
            controller: accomplishmentThreeController,
            decoration: new InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding:
                  EdgeInsets.only(left: 0, bottom: 11, top: 11, right: 0),
              hintText: "Insert accomplishment here...",
              hintStyle: GoogleFonts.questrial(
                textStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500]),
              ),
            ),
            style: GoogleFonts.questrial(
              textStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).accentColor),
            ),
          ),
          Divider(),
          Text(
            "My socials",
            style: GoogleFonts.questrial(
              textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).accentColor),
            ),
          ),
          TextField(
            controller: snapController,
            decoration: new InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding:
                  EdgeInsets.only(left: 0, bottom: 11, top: 11, right: 0),
              hintText: "Insert Snapchat handle here...",
              hintStyle: GoogleFonts.questrial(
                textStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500]),
              ),
            ),
            style: GoogleFonts.questrial(
              textStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).accentColor),
            ),
          ),
          TextField(
            controller: instaController,
            decoration: new InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding:
                  EdgeInsets.only(left: 0, bottom: 11, top: 11, right: 0),
              hintText: "Insert Instagram handle here...",
              hintStyle: GoogleFonts.questrial(
                textStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500]),
              ),
            ),
            style: GoogleFonts.questrial(
              textStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).accentColor),
            ),
          ),
          TextField(
            controller: linkedinController,
            decoration: new InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding:
                  EdgeInsets.only(left: 0, bottom: 11, top: 11, right: 0),
              hintText: "Insert LinkedIn handle here...",
              hintStyle: GoogleFonts.questrial(
                textStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500]),
              ),
            ),
            style: GoogleFonts.questrial(
              textStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).accentColor),
            ),
          ),
          Divider(),
          interests(),
          Divider(),
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
          : imag != null && f != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(0.0),
                  child: Image.file(f,
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                      height: 400))
              : Container(
                  width: MediaQuery.of(context).size.width,
                  height: 400,
                  color: Colors.grey[300],
                  child: Icon(AntDesign.user, color: Colors.black, size: 30.0)),
    );
  }

  Widget about() {
    return TextField(
      controller: aboutController,
      decoration: new InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.only(left: 0, bottom: 11, top: 11, right: 0),
        hintText: "Insert about here",
        hintStyle: GoogleFonts.questrial(
          textStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.grey[500]),
        ),
      ),
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
    for (var acc in widget.user.accomplishments) {
      if (acc.isNotEmpty) {
        result = result + '• $acc\n\n';
      }
    }
    result.trimRight();
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
    return Column(
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
    );
  }

  Widget socials() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(FlutterIcons.snapchat_faw),
        Icon(FlutterIcons.instagram_faw),
        Icon(FlutterIcons.linkedin_faw)
      ],
    );
  }

  _buildChoicesList() {
    List<Widget> choices = List();
    choices.add(Container(
      padding: const EdgeInsets.only(left: 0.0, right: 2.0),
      child: ChoiceChip(
        selectedColor: Colors.grey,
        label: Text(
          '+ Add Interest',
          style: GoogleFonts.questrial(
            textStyle: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ),
        onSelected: (selected) async {
          var result = await Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (BuildContext context) => MultiSelectChip(
                    Constants.interests,
                    _interests != null
                        ? _interests.cast<String>().toList()
                        : []),
                fullscreenDialog: true,
              ));
          if (this.mounted) {
            setState(() {
              _interests = result;
            });
          }
        },
        selected: true,
      ),
    ));
    if (_interests != null) {
      for (var interest in _interests) {
        choices.add(Container(
          padding: const EdgeInsets.only(left: 0.0, right: 2.0),
          child: ChoiceChip(
            selectedColor: Colors.deepPurpleAccent,
            label: Text(
              interest,
              style: GoogleFonts.questrial(
                textStyle: TextStyle(
                    fontSize: 11,
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

  Widget createButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 30),
      child: InkWell(
        onTap: () async {
          if (isUpdating) {
            return;
          }
          setState(() {
            isUpdating = true;
          });
          if (imag != null && f != null) {
            var url = await uploadImageToStorage(f);
            var res = await updateProfile(
                url,
                '',
                snapController.text,
                linkedinController.text,
                instaController.text,
                aboutController.text,
                accomplishmentOneController.text,
                accomplishmentTwoController.text,
                accomplishmentThreeController.text,
                '',
                _interests);
            if (res) {
              setState(() {
                isUpdating = false;
              });
              Toast.show('Profile Updated!', context);
              Navigator.pop(context);
            } else {
              Toast.show('Error updating your profile.', context);
            }
          } else {
            var res = await updateProfile(
                null,
                '',
                snapController.text,
                linkedinController.text,
                instaController.text,
                aboutController.text,
                accomplishmentOneController.text,
                accomplishmentTwoController.text,
                accomplishmentThreeController.text,
                '',
                _interests.cast<String>().toList());
            if (res) {
              setState(() {
                isUpdating = false;
              });
              Toast.show('Profile Updated!', context);
              Navigator.pop(context);
            } else {
              Toast.show('Error updating your profile.', context);
            }
          }
        },
        child: Container(
            height: 40,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
                borderRadius: BorderRadius.circular(5.0)),
            child: isUpdating
                ? Center(
                    child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.white)),
                  ))
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(FlutterIcons.update_mco,
                        size: 15.0, color: Colors.white),
                    SizedBox(width: 10.0),
                    Text(
                      "UPDATE PROFILE",
                      style: GoogleFonts.questrial(
                        textStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    )
                  ])),
      ),
    );
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

  @override
  void initState() {
    super.initState();
    _interests = widget.user.interests;
    accomplishmentOneController.text = widget.user.accomplishments != null &&
            widget.user.accomplishments.length > 0
        ? widget.user.accomplishments[0] ?? ""
        : '';
    accomplishmentTwoController.text = widget.user.accomplishments != null &&
            widget.user.accomplishments.length > 1
        ? widget.user.accomplishments[1] ?? ""
        : '';
    accomplishmentThreeController.text = widget.user.accomplishments != null &&
            widget.user.accomplishments.length > 2
        ? widget.user.accomplishments[2] ?? ""
        : '';
    aboutController.text =
        widget.user.about != null ? widget.user.about ?? "" : '';
    snapController.text = widget.user.snapchatHandle;
    linkedinController.text = widget.user.linkedinHandle;
    instaController.text = widget.user.instagramHandle;
  }

  bool get wantKeepAlive => true;
}
