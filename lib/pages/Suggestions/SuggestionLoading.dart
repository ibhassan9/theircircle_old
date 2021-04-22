import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:tmdb_api/tmdb_api.dart';
import 'package:tmdb_dart/tmdb_dart.dart';
import 'package:unify/pages/Suggestions/SuggestionSwipePage.dart';

class SuggestionLoading extends StatefulWidget {
  final int type;
  SuggestionLoading({Key key, @required this.type}) : super(key: key);
  @override
  _SuggestionLoadingState createState() => _SuggestionLoadingState();
}

class _SuggestionLoadingState extends State<SuggestionLoading> {
  TMDB tmdb = TMDB(ApiKeys('cdb97765a1083aad5b2fee61d77d1cb7',
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJjZGI5Nzc2NWExMDgzYWFkNWIyZmVlNjFkNzdkMWNiNyIsInN1YiI6IjYwMzhhODMyNjdiNjEzMDA0MzVjZmQ1YiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.DdeL5btjigZuyZco8LjcuypBh5qHHb6UGyNMoSgKXUk'));
  TmdbService service = TmdbService('cdb97765a1083aad5b2fee61d77d1cb7');
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
            style: GoogleFonts.manrope(color: Theme.of(context).accentColor),
          ),
        ],
      )),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    service.initConfiguration().then((value) {
      switch (widget.type) {
        case 0:
          MovieSearchSettings settings = MovieSearchSettings(
              quality: QualitySettings(
                  backdropQuality: AssetQuality.High,
                  posterQuality: AssetQuality.High));
          service.movie.getPopular(settings: settings).then((value) {
            value.results.shuffle();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SuggestionSwipePage(
                        movies: value.results, type: widget.type)));
          });
          break;
        case 1:
          TvSearchSettings settings = TvSearchSettings(
              quality: QualitySettings(
                  backdropQuality: AssetQuality.High,
                  posterQuality: AssetQuality.High));
          service.tv.getPopular(settings: settings).then((value) {
            value.results.shuffle();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SuggestionSwipePage(
                        tvs: value.results, type: widget.type)));
          });
          break;
      }
    });
  }
}
