import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_unicons/unicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:toast/toast.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/post.dart';
import 'package:unify/Models/product.dart';

class SellProductPage extends StatefulWidget {
  @override
  _SellProductPageState createState() => _SellProductPageState();
}

class _SellProductPageState extends State<SellProductPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  bool isPosting = false;
  Image imag1, imag2, imag3, imag4;
  File f1, f2, f3, f4;
  int clength = 100;
  int dlength = 200;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Theme.of(context).backgroundColor,
        iconTheme: IconThemeData(color: Theme.of(context).accentColor),
        brightness: Theme.of(context).brightness,
        leading: IconButton(
            icon: Icon(FlutterIcons.arrow_back_mdi,
                color: Theme.of(context).accentColor),
            onPressed: () => Navigator.pop(context, false)),
        title: Text(
          "Post Product",
          style: GoogleFonts.quicksand(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).accentColor),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: body(),
      // bottomNavigationBar: Padding(
      //   padding:
      //       EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      //   child: createButton(),
      // ),
    );
  }

  Widget body() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (_) {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [descriptionField()],
                    ),
                  ),
                ),
              ],
            ),
            // Divider(
            //   indent: 0.0,
            //   color: Colors.grey[400],
            // ),
            SizedBox(height: 15.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [picture(0), picture(1), picture(2), picture(3)],
            ),
            SizedBox(height: 20.0),
            createButton()
          ],
        ),
      ),
    );
  }

  Widget createButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0),
      child: InkWell(
        onTap: () async {
          if (titleController.text.isEmpty ||
              descriptionController.text.isEmpty ||
              priceController.text.isEmpty) {
            return;
          }
          List<File> files = [];
          if (imag1 != null) {
            files.add(f1);
          }
          if (imag2 != null) {
            files.add(f2);
          }
          if (imag3 != null) {
            files.add(f3);
          }
          if (imag4 != null) {
            files.add(f4);
          }

          if (files.length == 0) {
            return;
          }
          setState(() {
            isPosting = true;
          });
          Product prod = Product(
              title: titleController.text,
              description: descriptionController.text,
              price: priceController.text);
          var res = await Product.createListing(prod, files);
          if (res) {
            setState(() {
              isPosting = false;
            });

            Toast.show('Listing Posted!', context);
            Navigator.pop(context, true);
          }
        },
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Center(
            child: isPosting
                ? SizedBox(
                    width: 40,
                    height: 40,
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballClipRotate,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Post Product',
                    style: GoogleFonts.quicksand(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }

  Widget picture(int id) {
    return Stack(
      children: [
        InkWell(
          onTap: () async {
            var res = await getImage();
            if (res.isNotEmpty) {
              var image = res[0] as Image;
              var file = res[1] as File;
              setState(() {
                switch (id) {
                  case 0:
                    imag1 = image;
                    f1 = file;
                    break;
                  case 1:
                    imag2 = image;
                    f2 = file;
                    break;
                  case 2:
                    imag3 = image;
                    f3 = file;
                    break;
                  case 3:
                    imag4 = image;
                    f4 = file;
                    break;
                  default:
                    break;
                }
              });
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3.0),
            child: Container(
              height: 100.0,
              width: 85.0,
              decoration: BoxDecoration(
                color: Colors.grey[300],
              ),
              child: id == 0
                  ? imag1 != null
                      ? Image(
                          image: imag1.image,
                          fit: BoxFit.cover,
                        )
                      : Unicon(UniconData.uniCameraPlus, color: Colors.black)
                  : id == 1
                      ? imag2 != null
                          ? Image(
                              image: imag2.image,
                              fit: BoxFit.cover,
                            )
                          : Unicon(UniconData.uniCameraPlus,
                              color: Colors.black)
                      : id == 2
                          ? imag3 != null
                              ? Image(
                                  image: imag3.image,
                                  fit: BoxFit.cover,
                                )
                              : Unicon(UniconData.uniCameraPlus,
                                  color: Colors.black)
                          : id == 3
                              ? imag4 != null
                                  ? Image(
                                      image: imag4.image,
                                      fit: BoxFit.cover,
                                    )
                                  : Unicon(UniconData.uniCameraPlus,
                                      color: Colors.black)
                              : Unicon(UniconData.uniCameraPlus,
                                  color: Colors.black),
            ),
          ),
        ),
        Visibility(
          visible: id == 0
              ? imag1 != null && f1 != null
              : id == 1
                  ? imag2 != null && f2 != null
                  : id == 2
                      ? imag3 != null && f3 != null
                      : id == 3
                          ? imag4 != null && f4 != null
                          : false,
          child: Positioned(
              top: 6,
              left: 6,
              child: InkWell(
                onTap: () {
                  this.setState(() {
                    switch (id) {
                      case 0:
                        imag1 = null;
                        f1 = null;
                        break;
                      case 1:
                        imag2 = null;
                        f2 = null;
                        break;
                      case 2:
                        imag3 = null;
                        f3 = null;
                        break;
                      case 3:
                        imag4 = null;
                        f4 = null;
                        break;
                      default:
                        break;
                    }
                  });
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 10,
                  child: Icon(
                    Icons.close,
                    size: 15,
                    color: Colors.black,
                  ),
                ),
              )),
        ),
      ],
    );
  }

  Widget descriptionField() {
    return Flexible(
      child: Column(
        children: [
          field1(),
          field2(),
          field3(),
        ],
      ),
    );
  }

  Widget field1() {
    return TextField(
      controller: titleController,
      textInputAction: TextInputAction.done,
      maxLines: null,
      onChanged: (value) {
        var newLength = 100 - value.length;
        setState(() {
          clength = newLength;
        });
      },
      decoration: new InputDecoration(
          suffix: Text(
            clength.toString(),
            style: GoogleFonts.quicksand(
                color: clength < 0 ? Colors.red : Colors.grey),
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding:
              EdgeInsets.only(left: 0, bottom: 11, top: 11, right: 15),
          hintText: 'Product title'),
      style: GoogleFonts.quicksand(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).accentColor),
    );
  }

  Widget field2() {
    return TextField(
      controller: descriptionController,
      textInputAction: TextInputAction.done,
      maxLines: null,
      onChanged: (value) {
        var newLength = 200 - value.length;
        setState(() {
          dlength = newLength;
        });
      },
      decoration: new InputDecoration(
          suffix: Text(
            dlength.toString(),
            style: GoogleFonts.quicksand(
                color: dlength < 0 ? Colors.red : Colors.grey),
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding:
              EdgeInsets.only(left: 0, bottom: 11, top: 11, right: 15),
          hintText: "Describe your product here"),
      style: GoogleFonts.quicksand(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).accentColor),
    );
  }

  Widget field3() {
    return TextField(
      controller: priceController,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.number,
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
          hintText: "Price" + r' ($)'),
      style: GoogleFonts.quicksand(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).accentColor),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
  }
}
