// import 'package:flutter/material.dart';
// import 'package:firebase_ml_vision/firebase_ml_vision.dart';
// import 'dart:io';
// import 'dart:ui';
// import 'dart:async';

// import 'package:google_fonts/google_fonts.dart';

// class CameraDetailScreen extends StatefulWidget {
//   final String imagePath;
//   CameraDetailScreen(this.imagePath);

//   @override
//   _CameraDetailScreenState createState() =>
//       new _CameraDetailScreenState(imagePath);
// }

// class _CameraDetailScreenState extends State<CameraDetailScreen> {
//   _CameraDetailScreenState(this.path);

//   final String path;

//   Size _imageSize;
//   String recognizedText = "Loading ...";

//   void _initializeVision() async {
//     final File imageFile = File(path);

//     if (imageFile != null) {
//       await _getImageSize(imageFile);
//     }

//     final FirebaseVisionImage visionImage =
//         FirebaseVisionImage.fromFile(imageFile);

//     final TextRecognizer textRecognizer =
//         FirebaseVision.instance.textRecognizer();

//     final VisionText visionText =
//         await textRecognizer.processImage(visionImage);

//     String note = "";

//     for (TextBlock block in visionText.blocks) {
//       for (TextLine line in block.lines) {
//         note += line.text + '\n';
//       }
//     }

//     if (this.mounted) {
//       setState(() {
//         recognizedText = note;
//       });
//     }
//   }

//   Future<void> _getImageSize(File imageFile) async {
//     final Completer<Size> completer = Completer<Size>();

//     // Fetching image from path
//     final Image image = Image.file(imageFile);

//     // Retrieving its size
//     image.image.resolve(const ImageConfiguration()).addListener(
//       ImageStreamListener((ImageInfo info, bool _) {
//         completer.complete(Size(
//           info.image.width.toDouble(),
//           info.image.height.toDouble(),
//         ));
//       }),
//     );

//     final Size imageSize = await completer.future;
//     setState(() {
//       _imageSize = imageSize;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initializeVision();
//   }

//   @override
//   Widget build(BuildContext context) {
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
//       body: _imageSize != null
//           ? Stack(
//               children: <Widget>[
//                 Center(
//                   child: Container(
//                     width: double.maxFinite,
//                     color: Colors.black,
//                     child: AspectRatio(
//                       aspectRatio: _imageSize.aspectRatio,
//                       child: Image.file(
//                         File(path),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Align(
//                   alignment: Alignment.bottomCenter,
//                   child: Card(
//                     elevation: 8,
//                     color: Colors.white,
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: <Widget>[
//                           Row(),
//                           Padding(
//                             padding: const EdgeInsets.only(bottom: 8.0),
//                             child: Text(
//                               "Identified text",
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           Container(
//                             height: 60,
//                             child: SingleChildScrollView(
//                               child: Text(
//                                 recognizedText,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             )
//           : Container(
//               color: Colors.black,
//               child: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//     );
//   }
// }
