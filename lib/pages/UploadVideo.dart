import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:toast/toast.dart';
import 'package:unify/Home/main_screen.dart';
import 'package:unify/Models/post.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class UploadVideo extends StatefulWidget {
  final File videoFile;

  UploadVideo({Key key, this.videoFile}) : super(key: key);
  @override
  _UploadVideoState createState() => _UploadVideoState();
}

class _UploadVideoState extends State<UploadVideo> {
  bool allow = true;
  Image thumbnail;
  bool isUploading = false;

  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setThumbnail().then((_) {
      setState(() {});
    });
  }

  setThumbnail() async {
    var bytes = await VideoThumbnail.thumbnailData(
      video: widget.videoFile.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 0,
      quality: 100,
    );
    thumbnail = Image.memory(bytes);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Theme.of(context).backgroundColor,
        iconTheme: IconThemeData(color: Theme.of(context).accentColor),
        title: Text('Create',
            style: GoogleFonts.pacifico(
              textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).accentColor),
            )),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: body(),
      bottomNavigationBar: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: createButton(this.context),
      ),
    );
  }

  Widget allowComments() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
            child: Row(
          children: [
            Icon(Icons.message_rounded,
                size: 17.0, color: Theme.of(context).accentColor),
            SizedBox(width: 10.0),
            Text('Allow comments',
                style: GoogleFonts.quicksand(
                  textStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor),
                )),
          ],
        )),
        InkWell(
          onTap: () {
            if (allow) {
              this.setState(() {
                allow = false;
              });
            } else {
              this.setState(() {
                allow = true;
              });
            }
          },
          child: Icon(
              allow == false
                  ? FlutterIcons.md_radio_button_off_ion
                  : FlutterIcons.md_radio_button_on_ion,
              size: 20,
              color: allow == false ? Colors.grey[400] : Colors.pink),
        ),
      ],
    );
  }

  Widget body() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [descriptionField(), tagWidget()],
                  ),
                ),
              ),
              video()
            ],
          ),
          SizedBox(height: 5.0),
          Divider(
            indent: 0.0,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20.0),
          allowComments()
        ],
      ),
    );
  }

  Widget createButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          10.0, 10.0, 10.0, kBottomNavigationBarHeight),
      child: InkWell(
        onTap: () async {
          if (isUploading) {
            return;
          }
          if (descriptionController.text.isEmpty) {
            Toast.show('Description is required', context);
            return;
          }
          this.setState(() {
            isUploading = true;
          });
          var result = await VideoApi.createVideo(
              f: widget.videoFile,
              caption: descriptionController.text,
              allowComments: allow);
          if (result) {
            this.setState(() {
              isUploading = false;
            });
            Navigator.pop(context);
            // Navigator.of(context).popUntil((route) => route.isFirst);
            // Navigator.pushReplacement(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => MainScreen(
            //               initialPage: 2,
            //             )));
          } else {
            this.setState(() {
              isUploading = false;
            });
          }
        },
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue, Colors.pink]),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Center(
            child: isUploading
                ? SizedBox(
                    height: 40.0,
                    width: 40.0,
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballScaleMultiple,
                      color: Colors.white,
                    ))
                : Text('PUBLISH',
                    style: GoogleFonts.quicksand(
                      textStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    )),
          ),
        ),
      ),
    );
  }

  Widget video() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3.0),
      child: Container(
        height: 100.0,
        width: 85.0,
        decoration: BoxDecoration(
          color: Colors.grey[300],
        ),
        child: thumbnail != null
            ? Image(
                image: thumbnail.image,
                fit: BoxFit.cover,
              )
            : Container(),
      ),
    );
  }

  Widget tagWidget() {
    return Container();
    // return Container(
    //   padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
    //   decoration: BoxDecoration(
    //       border: Border.all(color: Colors.grey[500], width: 0.3),
    //       borderRadius: BorderRadius.circular(
    //           3.0)), //             <--- BoxDecoration here
    //   child: Text('@ Friends',
    //       style: GoogleFonts.quicksand(
    //         textStyle: TextStyle(
    //             fontSize: 11,
    //             fontWeight: FontWeight.w400,
    //             color: Theme.of(context).accentColor),
    //       )),
    // );
  }

  Widget descriptionField() {
    return Flexible(
      child: TextField(
        controller: descriptionController,
        textInputAction: TextInputAction.done,
        maxLines: null,
        onChanged: (value) {},
        decoration: new InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding:
                EdgeInsets.only(left: 0, bottom: 11, top: 11, right: 15),
            hintText: 'Describe your video'),
        style: GoogleFonts.quicksand(
          textStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).accentColor),
        ),
      ),
    );
  }
}
