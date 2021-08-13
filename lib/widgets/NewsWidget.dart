import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/news.dart';
import 'package:unify/pages/WebPage.dart';

class NewsWidget extends StatefulWidget {
  final News news;
  NewsWidget({Key key, this.news}) : super(key: key);
  @override
  _NewsWidgetState createState() => _NewsWidgetState();
}

class _NewsWidgetState extends State<NewsWidget>
    with AutomaticKeepAliveClientMixin {
  String url;
  String imgUrl;
  Color color;

  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0),
      child: imgUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: InkWell(
                onTap: () {
                  showBarModalBottomSheet(
                    context: context,
                    enableDrag: false,
                    expand: true,
                    builder: (context) => WebPage(
                        title: widget.news.title, selectedUrl: widget.news.url),
                  );
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => WebPage(
                  //           title: widget.news.title, selectedUrl: widget.news.url)),
                  // );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 3,
                  decoration: BoxDecoration(
                      color: Theme.of(context).buttonColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(0.0)),
                  child: Stack(children: [
                    imgUrl != null || imgUrl != '' || imgUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imgUrl,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            fit: BoxFit.cover,
                          )
                        : Container(),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.black.withOpacity(0.2),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10.0, top: 10.0),
                                child: Container(
                                  height: 3.0,
                                  width: 20.0,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0,
                                    right: 10.0,
                                    top: 5.0,
                                    bottom: 5.0),
                                child: Text(
                                  widget.news.title
                                      .replaceAll('             ', ' '),
                                  maxLines: 6,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.quicksand(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    shadows: <Shadow>[
                                      Shadow(
                                        offset: Offset(2.0, 2.0),
                                        blurRadius: 3.0,
                                        color: Colors.black.withOpacity(0.05),
                                      ),
                                      // Shadow(
                                      //   offset: Offset(5.0, 5.0),
                                      //   blurRadius: 8.0,
                                      //   color: Color.fromARGB(125, 0, 0, 255),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            )
          : Container(),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    url = widget.news.url;
    imgUrl = widget.news.imgUrl;
    if (Constants.checkUniversity() == 1) {
      grabImgUrl(url: url).then((value) {
        print("NEW VALUE: " + value);
        setState(() {
          imgUrl = value;
        });
      });
    }
    color = Constants.color();
  }

  bool get wantKeepAlive => true;
}
