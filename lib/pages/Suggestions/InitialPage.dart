import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/pages/Suggestions/SuggestionLoading.dart';

class InitialSuggestionsPage extends StatefulWidget {
  @override
  _InitialSuggestionsPageState createState() => _InitialSuggestionsPageState();
}

class _InitialSuggestionsPageState extends State<InitialSuggestionsPage> {
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Center(
              child: Text(
                'What are you looking for?',
                style: TextStyle(
                    fontFamily: "Futura3",
                    color: Theme.of(context).accentColor),
              ),
            ),
            SizedBox(height: 10.0),
            actionButton(type: 0),
            actionButton(type: 1),
            actionButton(type: 2),
            actionButton(type: 3),
          ],
        ),
      ),
    );
  }

  Widget actionButton({int type}) {
    return Center(
      child: InkWell(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SuggestionLoading()));
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 60,
            width: MediaQuery.of(context).size.width / 1.5,
            decoration: BoxDecoration(
                color: Constants.color(),
                borderRadius: BorderRadius.circular(5.0)),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                      type == 0
                          ? FlutterIcons.movie_mco
                          : type == 1
                              ? FlutterIcons.tv_ent
                              : type == 2
                                  ? FlutterIcons.food_apple_mco
                                  : FlutterIcons.games_mdi,
                      color: Colors.white),
                  SizedBox(width: 10.0),
                  Text(
                    type == 0
                        ? 'Movies'
                        : type == 1
                            ? 'TV Shows'
                            : type == 2
                                ? 'Food'
                                : 'Activities/Games',
                    style:
                        TextStyle(fontFamily: "Futura3", color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
