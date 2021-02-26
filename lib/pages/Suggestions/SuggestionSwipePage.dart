import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmdb_dart/tmdb_dart.dart';

class SuggestionSwipePage extends StatefulWidget {
  final List<MovieBase> data;

  SuggestionSwipePage({Key key, this.data}) : super(key: key);
  @override
  _SuggestionSwipePageState createState() => _SuggestionSwipePageState();
}

class _SuggestionSwipePageState extends State<SuggestionSwipePage> {
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
    );
  }

  Widget body() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: TinderSwapCard(
                    swipeUp: false,
                    swipeDown: false,
                    animDuration: 200,
                    orientation: AmassOrientation.BOTTOM,
                    swipeEdgeVertical: 10.0,
                    totalNum: widget.data.length,
                    stackNum: 4,
                    swipeEdge: 4.0,
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                    maxHeight: MediaQuery.of(context).size.height * 0.9,
                    minWidth: MediaQuery.of(context).size.width * 0.8,
                    minHeight: MediaQuery.of(context).size.height * 0.8,
                    cardBuilder: (context, index) {
                      var details = widget.data[index];
                      String title = details.originalTitle;
                      String overview = details.overview;
                      return Column(
                        children: [Text(title), Text(overview)],
                      );
                    },
                    swipeUpdateCallback:
                        (DragUpdateDetails details, Alignment align) {
                      /// Get swiping card's alignment
                      if (align.x < 0) {
                        //Card is LEFT swiping
                      } else if (align.x > 0) {
                        //Card is RIGHT swiping
                      }
                    },
                    swipeCompleteCallback:
                        (CardSwipeOrientation orientation, int index) async {},
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
