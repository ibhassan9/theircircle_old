import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:webview_flutter/webview_flutter.dart';

class WebPage extends StatefulWidget {
  final String title;
  final String selectedUrl;

  WebPage({
    @required this.title,
    @required this.selectedUrl,
  });

  @override
  _WebPageState createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    print(widget.selectedUrl);
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          centerTitle: true,
          elevation: 0.0,
          title: Text(
            isLoading
                ? "Loading Newspage..."
                : widget.title.replaceAll("     ", ""),
            style: GoogleFonts.quicksand(
              textStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
          ),
        ),
        body: WebView(
          initialUrl: widget.selectedUrl,
          javascriptMode: JavascriptMode.disabled,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
        ));
  }
}
