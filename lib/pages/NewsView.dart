import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:unify/Models/news.dart';

class NewsView extends StatelessWidget {
  final List<News> news;
  NewsView({Key key, this.news}) : super(key: key);

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionListener =
      ItemPositionsListener.create();

  Widget build(BuildContext context) {
    var currentIndex = 0;
    return Scaffold(
      body: Stack(children: [
        ScrollablePositionedList.builder(
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionListener,
          scrollDirection: Axis.horizontal,
          itemCount: news.length,
          itemBuilder: (context, index) {
            return Image.network(
              news[index].imgUrl,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: new AlwaysStoppedAnimation<Color>(
                          Colors.grey.shade600),
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes
                          : null,
                    ),
                  ),
                );
              },
            );
          },
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: FlatButton(
            child: Text("NEXT"),
            onPressed: () {
              itemScrollController.scrollTo(
                  index: currentIndex,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic);
              currentIndex += 1;
            },
          ),
        ),
      ]),
    );
  }
}
