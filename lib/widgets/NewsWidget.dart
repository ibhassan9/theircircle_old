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
      padding: const EdgeInsets.only(left: 10.0, top: 0.0),
      child: imgUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
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
                      color: Theme.of(context).dividerColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15.0)),
                  child: Stack(children: [
                    imgUrl != null || imgUrl != '' || imgUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imgUrl,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            fit: BoxFit.cover,
                          )
                        : Container(),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          height: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10.0),
                                child: Container(
                                  height: 3.0,
                                  width: 20.0,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10.0, top: 5.0),
                                child: Text(
                                  widget.news.title,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.manrope(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
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
        print(value);
        setState(() {
          imgUrl = value;
        });
      });
    }
    color = Constants.color();
  }

  bool get wantKeepAlive => true;
}
