import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
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
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          iconTheme: IconThemeData(color: Theme.of(context).accentColor),
          leading: IconButton(
            icon: Icon(FlutterIcons.close_ant,
                color: Theme.of(context).accentColor),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          elevation: 0.0,
          title: Column(
            children: [
              Text(
                isLoading
                    ? "Loading Newspage..."
                    : widget.title.replaceAll("     ", ""),
                style: GoogleFonts.questrial(
                  textStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor),
                ),
              ),
              SizedBox(height: 3.0),
              Text(
                widget.selectedUrl,
                style: GoogleFonts.questrial(
                  textStyle: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[200]),
                ),
              ),
            ],
          ),
        ),
        body: WebView(
          initialUrl: widget.selectedUrl,
          javascriptMode: JavascriptMode.unrestricted,
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
