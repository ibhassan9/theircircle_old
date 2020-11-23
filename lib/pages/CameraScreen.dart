// import 'dart:io';

// import 'package:camera/camera.dart';
// import 'package:firebase_ml_vision/firebase_ml_vision.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_icons/flutter_icons.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:unify/Models/post.dart';
// import 'package:unify/main.dart';
// import 'package:unify/pages/CameraDetailScreen.dart';

// class CameraScreen extends StatefulWidget {
//   @override
//   _CameraScreenState createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State<CameraScreen> {
//   File pickedImage;
//   ImagePicker imagePicker = ImagePicker();
//   bool isLoaded = false;

//   Widget build(BuildContext context) {
//     if (pickedImage != null) {
//       scanText();
//     }
//     return Scaffold(
//       appBar: AppBar(
//         brightness: Brightness.light,
//         backgroundColor: Colors.white,
//         centerTitle: false,
//         elevation: 0.0,
//         iconTheme: IconThemeData(color: Colors.black),
//         title: Row(
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Note Scanner",
//                   style: GoogleFonts.quicksand(
//                     textStyle: TextStyle(
//                         fontSize: 17,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.black),
//                   ),
//                 ),
//                 Text(
//                   "Save & edit your notes!",
//                   style: GoogleFonts.quicksand(
//                     textStyle: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.black),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       body: Center(
//         child: Container(
//             child: InkWell(
//           onTap: () {
//             pickImage();
//           },
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(FlutterIcons.photo_library_mdi,
//                   color: Colors.grey, size: 40),
//               SizedBox(height: 10.0),
//               Text(
//                 "Upload a Photo",
//                 style: GoogleFonts.quicksand(
//                   textStyle: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.grey),
//                 ),
//               ),
//             ],
//           ),
//         )),
//       ),
//     );
//   }

//   Future pickImage() async {
//     var tempStore = await imagePicker.getImage(source: ImageSource.gallery);
//     var image = File(tempStore.path);

//     setState(() {
//       pickedImage = image;
//       isLoaded = true;
//     });

//     await scanText();
//   }

//   Future scanText() async {
//     FirebaseVisionImage visionImage =
//         FirebaseVisionImage.fromFilePath(pickedImage.path);
//     TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
//     VisionText visionText = await textRecognizer.processImage(visionImage);
//     for (TextBlock block in visionText.blocks) {
//       for (TextLine line in block.lines) {
//         for (TextElement word in line.elements) {}
//       }
//     }
//   }
// }
