import 'package:cached_network_image/cached_network_image.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmdb_dart/tmdb_dart.dart';
import 'package:unify/Components/Constants.dart';

class SuggestionSwipePage extends StatefulWidget {
  final List<MovieBase> movies;
  final List<TvBase> tvs;
  final int type;

  SuggestionSwipePage({Key key, this.movies, this.tvs, @required this.type})
      : super(key: key);
  @override
  _SuggestionSwipePageState createState() => _SuggestionSwipePageState();
}

class _SuggestionSwipePageState extends State<SuggestionSwipePage> {
  bool started = false;
  CardController _controller = CardController();
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        backgroundColor: Theme.of(context).backgroundColor,
        centerTitle: true,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Theme.of(context).accentColor),
        title: Text(
          widget.type == 0 ? 'Movie Session' : 'Tv Show Session',
          style: TextStyle(
              fontFamily: "Futura1",
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).accentColor),
        ),
        leadingWidth: 60.0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: InkWell(
            onTap: () {},
            child: CircleAvatar(
                radius: 20.0,
                backgroundColor:
                    Theme.of(context).accentColor.withOpacity(0.05),
                child: Icon(FlutterIcons.library_mco,
                    color: Theme.of(context).accentColor)
                // child: Unicon(UniconData.uniUser,
                //     size: 20.0, color: Theme.of(context).accentColor),
                ),
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: InkWell(
              onTap: () async {},
              child: CircleAvatar(
                  radius: 20.0,
                  backgroundColor:
                      Theme.of(context).accentColor.withOpacity(0.05),
                  child: Icon(FlutterIcons.create_mdi,
                      color: Theme.of(context).accentColor)),
            ),
          ),
        ],
      ),
    );
  }

  Widget body() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: TinderSwapCard(
                    cardController: _controller,
                    swipeUp: false,
                    swipeDown: false,
                    animDuration: 200,
                    orientation: AmassOrientation.BOTTOM,
                    swipeEdgeVertical: 10.0,
                    totalNum: widget.type == 0
                        ? widget.movies.length
                        : widget.tvs.length,
                    stackNum: 4,
                    swipeEdge: 4.0,
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                    minWidth: MediaQuery.of(context).size.width * 0.79,
                    minHeight: MediaQuery.of(context).size.height * 0.69,
                    cardBuilder: (context, index) {
                      var details = widget.type == 0
                          ? widget.movies[index]
                          : widget.tvs[index];
                      String title = widget.type == 0
                          ? widget.movies[index].title
                          : widget.tvs[index].name;
                      String overview = details.overview;
                      String image = details.posterPath;
                      int voteCount = details.voteCount;
                      num popularity = details.popularity;
                      return OptionWidget(
                          title: title,
                          description: overview,
                          image: image,
                          votes: voteCount,
                          popularity: popularity);
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
            SizedBox(height: 10.0),
            InkWell(
              onTap: () {
                setState(() {
                  started ? started = false : started = true;
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: started ? Colors.deepPurpleAccent : Colors.green,
                      width: 1.5),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                        started ? 'End Live Session' : 'Start Live Session',
                        style: TextStyle(
                          fontFamily: "Futura",
                          fontSize: 12,
                          color:
                              started ? Colors.deepPurpleAccent : Colors.green,
                        )),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.type);
  }
}

class OptionWidget extends StatefulWidget {
  final String title;
  final String description;
  final int votes;
  final num popularity;
  final String image;

  OptionWidget({
    this.image,
    this.title,
    this.description,
    this.votes,
    this.popularity,
  });
  @override
  _OptionWidgetState createState() => _OptionWidgetState();
}

class _OptionWidgetState extends State<OptionWidget> {
  Color color;
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CachedNetworkImage(
                imageUrl: widget.image,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 5.0),
              Text(widget.title,
                  style: TextStyle(
                    fontFamily: "Futura",
                    fontSize: 17,
                    color: Colors.white,
                  )),
              SizedBox(height: 5.0),
              Flexible(
                child: Text(widget.description,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontFamily: "Futura3",
                      fontSize: 13,
                      color: Colors.white,
                    )),
              ),
              SizedBox(height: 5.0),
              Text(widget.votes.toString() + ' Total Votes',
                  style: TextStyle(
                    fontFamily: "Futura2",
                    fontSize: 12,
                    color: Colors.white,
                  )),
              Text('Popularity: ' + widget.popularity.toString(),
                  style: TextStyle(
                    fontFamily: "Futura2",
                    fontSize: 12,
                    color: Colors.white,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    color = Colors.deepPurpleAccent;
  }
}
