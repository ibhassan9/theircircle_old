import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toast/toast.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/user.dart';
import 'package:unify/pages/MultiSelectChip.dart';

class MatchWidgetPersonal extends StatefulWidget {
  final PostUser user;
  final Function swipe;
  MatchWidgetPersonal({Key key, this.user, this.swipe}) : super(key: key);
  @override
  _MatchWidgetPersonalState createState() => _MatchWidgetPersonalState();
}

class _MatchWidgetPersonalState extends State<MatchWidgetPersonal> {
  TextEditingController aboutMyselfController = TextEditingController();
  TextEditingController acc1C = TextEditingController();
  TextEditingController acc2C = TextEditingController();
  TextEditingController acc3C = TextEditingController();
  TextEditingController whyC = TextEditingController();
  int aboutlength = 300;
  int acc1length = 200;
  int acc2length = 200;
  int acc3length = 200;
  int whylength = 300;
  String aboutTitle = 'Talk briefly about yourself here...';
  String accTitle = 'Insert accomplishment here...';
  String whyTitle = 'Talk about why you\'re looking to network';
  String about;
  String accomplishment1;
  String accomplishment2;
  String accomplishment3;
  String why;

  List<dynamic> interests = [];
  bool isUpdating = false;

  Widget build(BuildContext context) {
    Padding addWidget = Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey[400], borderRadius: BorderRadius.circular(3.0)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(FlutterIcons.add_mdi, color: Colors.white, size: 17.0),
                SizedBox(width: 5.0),
                Text(
                  "Add interest",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.kulimPark(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 5,
          blurRadius: 7,
          offset: Offset(0, 3), // changes position of shadow
        ),
      ], color: Colors.white, borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: Container(
                              child: Image.network(
                                widget.user.profileImgUrl == null
                                    ? Constants.dummyImageUrl
                                    : widget.user.profileImgUrl,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return SizedBox(
                                    height: 70,
                                    width: 70,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                Colors.grey.shade600),
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 10.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.user.name,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.kulimPark(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black),
                              ),
                              Text(
                                widget.user.university == 'UofT'
                                    ? 'University of Toronto'
                                    : widget.user.university == 'YorkU'
                                        ? 'York University'
                                        : 'Western University',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.kulimPark(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 15.0),
                  Text(
                    'About Myself',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.kulimPark(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey),
                  ),
                  Divider(),
                  TextField(
                    controller: aboutMyselfController,
                    textInputAction: TextInputAction.done,
                    maxLines: null,
                    onChanged: (value) {
                      var newLength = 300 - value.length;
                      setState(() {
                        aboutlength = newLength;
                      });
                    },
                    decoration: new InputDecoration(
                        suffix: Text(
                          aboutlength.toString(),
                          style: GoogleFonts.kulimPark(
                              color:
                                  aboutlength < 0 ? Colors.red : Colors.grey),
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintStyle: GoogleFonts.kulimPark(color: Colors.grey),
                        hintText: aboutTitle),
                    style: GoogleFonts.kulimPark(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                  SizedBox(height: 15.0),
                  Text(
                    'My Accomplishments',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.kulimPark(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey),
                  ),
                  Divider(),
                  Column(
                    children: [
                      TextField(
                        controller: acc1C,
                        textInputAction: TextInputAction.done,
                        maxLines: null,
                        onChanged: (value) {
                          var newLength = 200 - value.length;
                          setState(() {
                            acc1length = newLength;
                          });
                        },
                        decoration: new InputDecoration(
                            suffix: Text(
                              acc1length.toString(),
                              style: GoogleFonts.kulimPark(
                                  color: acc1length < 0
                                      ? Colors.red
                                      : Colors.grey),
                            ),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintStyle:
                                GoogleFonts.kulimPark(color: Colors.grey),
                            hintText: accTitle),
                        style: GoogleFonts.kulimPark(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      TextField(
                        controller: acc2C,
                        textInputAction: TextInputAction.done,
                        maxLines: null,
                        onChanged: (value) {
                          var newLength = 200 - value.length;
                          setState(() {
                            acc2length = newLength;
                          });
                        },
                        decoration: new InputDecoration(
                            suffix: Text(
                              acc2length.toString(),
                              style: GoogleFonts.kulimPark(
                                  color: acc2length < 0
                                      ? Colors.red
                                      : Colors.grey),
                            ),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintStyle:
                                GoogleFonts.kulimPark(color: Colors.grey),
                            hintText: accTitle),
                        style: GoogleFonts.kulimPark(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      TextField(
                        controller: acc3C,
                        textInputAction: TextInputAction.done,
                        maxLines: null,
                        onChanged: (value) {
                          var newLength = 200 - value.length;
                          setState(() {
                            acc3length = newLength;
                          });
                        },
                        decoration: new InputDecoration(
                            suffix: Text(
                              acc3length.toString(),
                              style: GoogleFonts.kulimPark(
                                  color: acc3length < 0
                                      ? Colors.red
                                      : Colors.grey),
                            ),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintStyle:
                                GoogleFonts.kulimPark(color: Colors.grey),
                            hintText: accTitle),
                        style: GoogleFonts.kulimPark(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.0),
                  Text(
                    'Why am I here?',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.kulimPark(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey),
                  ),
                  Divider(),
                  TextField(
                    controller: whyC,
                    textInputAction: TextInputAction.done,
                    maxLines: null,
                    onChanged: (value) {
                      var newLength = 300 - value.length;
                      setState(() {
                        whylength = newLength;
                      });
                    },
                    decoration: new InputDecoration(
                        suffix: Text(
                          whylength.toString(),
                          style: GoogleFonts.kulimPark(
                              color: whylength < 0 ? Colors.red : Colors.grey),
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintStyle: GoogleFonts.kulimPark(color: Colors.grey),
                        hintText: whyTitle),
                    style: GoogleFonts.kulimPark(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                  ),
                  SizedBox(height: 15.0),
                  Text(
                    'My interests',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.kulimPark(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey),
                  ),
                  Divider(),
                  interests != null && interests.isNotEmpty
                      ? Wrap(children: _buildChoicesList())
                      // ? Container(
                      //     height: 30,
                      //     width: MediaQuery.of(context).size.width,
                      //     child: ListView.builder(
                      //       shrinkWrap: true,
                      //       scrollDirection: Axis.horizontal,
                      //       physics: AlwaysScrollableScrollPhysics(),
                      //       itemCount: interests != null && interests.isNotEmpty
                      //           ? interests.length
                      //           : 0,
                      //       itemBuilder: (context, index) {
                      //         var interest = interests[index];
                      //         if (index == 0) {
                      //           return Row(
                      //             children: [
                      //               InkWell(
                      //                   onTap: () async {
                      //                     var result = await Navigator.push(
                      //                         context,
                      //                         new MaterialPageRoute(
                      //                           builder:
                      //                               (BuildContext context) =>
                      //                                   MultiSelectChip(
                      //                                       Constants.interests,
                      //                                       interests
                      //                                           .cast<String>()
                      //                                           .toList()),
                      //                           fullscreenDialog: true,
                      //                         ));
                      //                     if (this.mounted) {
                      //                       setState(() {
                      //                         interests = result;
                      //                       });
                      //                     }
                      //                   },
                      //                   child: addWidget),
                      //               HashtagWidget(
                      //                 title: interest,
                      //               ),
                      //             ],
                      //           );
                      //         } else {
                      //           //return HashtagWidget(title: interest);
                      //         }
                      //       },
                      //     ),
                      //   )
                      : InkWell(
                          onTap: () async {
                            var result = await Navigator.push(
                                context,
                                new MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      MultiSelectChip(
                                          Constants.interests,
                                          interests != null &&
                                                  interests.isNotEmpty
                                              ? interests
                                                  .cast<String>()
                                                  .toList()
                                              : []),
                                  fullscreenDialog: true,
                                ));
                            if (this.mounted) {
                              setState(() {
                                interests = result;
                              });
                            }
                          },
                          child: Text(
                            'Select my interests',
                            textAlign: TextAlign.left,
                            style: GoogleFonts.kulimPark(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black),
                          ),
                        ),
                  SizedBox(height: 30.0),
                ],
              ),
            ),
            Container(
              height: 50.0,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(5.0)),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon(FlutterIcons.save_ant, color: Colors.black),
                    // SizedBox(width: 10.0),
                    isUpdating
                        ? Container(
                            height: 30.0,
                            width: 30.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.black),
                            ))
                        : InkWell(
                            onTap: () async {
                              setState(() {
                                isUpdating = true;
                              });
                              var res = await updateNetworkProfile(
                                  aboutMyselfController.text ?? "",
                                  acc1C.text ?? "",
                                  acc2C.text ?? "",
                                  acc3C.text,
                                  whyC.text,
                                  interests);
                              if (res) {
                                setState(() {
                                  isUpdating = false;
                                });
                                widget.swipe();
                              } else {
                                setState(() {
                                  isUpdating = false;
                                });
                                Toast.show(
                                    'Problem updating your networking profile.',
                                    context);
                              }
                            },
                            child: Text(
                              'Update my profile',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.kulimPark(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                            ),
                          ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildChoicesList() {
    List<Widget> choices = List();
    choices.add(Container(
      padding: const EdgeInsets.only(left: 0.0, right: 2.0),
      child: ChoiceChip(
        selectedColor: Colors.grey,
        label: Text(
          '+ Add interest',
          style: GoogleFonts.kulimPark(
              fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        onSelected: (selected) async {
          var result = await Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (BuildContext context) => MultiSelectChip(
                    Constants.interests, interests.cast<String>().toList()),
                fullscreenDialog: true,
              ));
          if (this.mounted) {
            setState(() {
              interests = result;
            });
          }
        },
        selected: true,
      ),
    ));
    for (var interest in interests) {
      choices.add(Container(
        padding: const EdgeInsets.only(left: 0.0, right: 2.0),
        child: ChoiceChip(
          selectedColor: Colors.deepPurpleAccent,
          label: Text(
            interest,
            style: GoogleFonts.kulimPark(
                fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    interests = widget.user.interests;
    about = widget.user.about != null && widget.user.about.isNotEmpty
        ? widget.user.about
        : '';
    aboutMyselfController.text = about;
    accomplishment1 = widget.user.accomplishments != null &&
            widget.user.accomplishments.isNotEmpty
        ? widget.user.accomplishments[0] != null &&
                widget.user.accomplishments[0].isNotEmpty
            ? widget.user.accomplishments[0]
            : ''
        : '';
    acc1C.text = accomplishment1;
    accomplishment2 = widget.user.accomplishments != null &&
            widget.user.accomplishments.isNotEmpty
        ? widget.user.accomplishments[1] != null &&
                widget.user.accomplishments[1].isNotEmpty
            ? widget.user.accomplishments[1]
            : ''
        : '';
    acc2C.text = accomplishment2;
    accomplishment3 = widget.user.accomplishments != null &&
            widget.user.accomplishments.isNotEmpty
        ? widget.user.accomplishments[2] != null &&
                widget.user.accomplishments[2].isNotEmpty
            ? widget.user.accomplishments[2]
            : ''
        : '';
    acc3C.text = accomplishment3;
    why = widget.user.why != null && widget.user.why.isNotEmpty
        ? widget.user.why
        : '';
    whyC.text = why;
    setState(() {});
  }
}
