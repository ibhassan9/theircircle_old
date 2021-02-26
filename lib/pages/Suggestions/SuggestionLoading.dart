import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:tmdb_dart/tmdb_dart.dart';

class SuggestionLoading extends StatefulWidget {
  @override
  _SuggestionLoadingState createState() => _SuggestionLoadingState();
}

class _SuggestionLoadingState extends State<SuggestionLoading> {
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Theme.of(context).backgroundColor,
        leading: Icon(FlutterIcons.x_fea, color: Theme.of(context).accentColor),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.width / 2,
            width: MediaQuery.of(context).size.width / 2,
            child: LoadingIndicator(
                indicatorType: Indicator.lineScalePulseOut,
                color: Colors.deepOrangeAccent),
          ),
          SizedBox(height: 30.0),
          Text(
            'Curating a list for you...',
            style: TextStyle(
                fontFamily: "Futura3", color: Theme.of(context).accentColor),
          ),
        ],
      )),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
}
