import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_unicons/unicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/product.dart';
import 'package:unify/pages/MyListingsPage.dart';
import 'package:unify/pages/SellProductPage.dart';
import 'package:unify/widgets/ProductWidget.dart';
import 'package:url_launcher/url_launcher.dart';

class BuyNSell extends StatefulWidget {
  @override
  _BuyNSellState createState() => _BuyNSellState();
}

class _BuyNSellState extends State<BuyNSell>
    with AutomaticKeepAliveClientMixin {
  Future prodFuture;
  List<Product> prodList;
  List<Product> searchList = [];
  bool _isSearching = false;
  bool isDoneLoading = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        backgroundColor: Theme.of(context).backgroundColor,
        centerTitle: true,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Theme.of(context).accentColor),
        title: Text(
          "Store",
          style: TextStyle(
              fontFamily: "Futura",
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).accentColor),
        ),
        leadingWidth: 60.0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: InkWell(
            onTap: () {
              showBarModalBottomSheet(
                  context: context,
                  expand: true,
                  builder: (context) => MyListings());
            },
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
              onTap: () async {
                showBarModalBottomSheet(
                        context: context,
                        expand: true,
                        builder: (context) => SellProductPage())
                    .then((value) async {
                  if (value == true) {
                    await Product.products().then((value) {
                      setState(() {
                        prodList = value;
                      });
                    });
                  }
                });
              },
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
      body: ClipRRect(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0)),
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: Theme.of(context).backgroundColor,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (_) {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Stack(
              children: <Widget>[
                RefreshIndicator(
                  onRefresh: () async {
                    await Product.products().then((value) {
                      setState(() {
                        prodList = value;
                      });
                    });
                  },
                  child: ListView(
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .accentColor
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(5.0)),
                          child: TextField(
                            textAlignVertical: TextAlignVertical.center,
                            onChanged: (value) {
                              searchList.clear();
                              if (value.isEmpty) {
                                setState(() {
                                  _isSearching = false;
                                });
                              } else {
                                setState(() {
                                  searchList = prodList
                                      .where((element) => element.title
                                          .toLowerCase()
                                          .contains(value.toLowerCase()))
                                      .toList();
                                  _isSearching = true;
                                });
                              }
                            },
                            decoration: new InputDecoration(
                                prefixIcon: Icon(FlutterIcons.search_faw5s,
                                    size: 15.0,
                                    color: Theme.of(context).accentColor),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                    left: 0, bottom: 0, top: 0, right: 15),
                                hintText: "Search Products...",
                                hintStyle: GoogleFonts.quicksand(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).accentColor)),
                            style: GoogleFonts.quicksand(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).accentColor),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => launch(Platform.isIOS
                            ? Constants.theircartiOS
                            : Constants.theircartA),
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(colors: [
                            Colors.white,
                            Colors.purple,
                            Colors.blue,
                            Colors.green,
                          ]).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ),
                          child: Text(
                            "Sell or drive with Theircart",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.quicksand(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 15.0),
                      isDoneLoading
                          ? prodList != null && prodList.isNotEmpty
                              ? GridView.builder(
                                  scrollDirection: Axis.vertical,
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 10.0,
                                          mainAxisSpacing: 0.0,
                                          childAspectRatio: 50 / 80),
                                  itemCount:
                                      _isSearching == false && prodList != null
                                          ? prodList.length
                                          : searchList.isNotEmpty
                                              ? searchList.length
                                              : 0,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    Product prod = _isSearching == false &&
                                            prodList != null
                                        ? prodList[index]
                                        : searchList.isNotEmpty
                                            ? searchList[index]
                                            : Product();
                                    Function refresh = () async {
                                      await Product.products().then((value) {
                                        setState(() {
                                          prodList = value;
                                        });
                                      });
                                    };
                                    return index % 2 == 0
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                left: 15.0),
                                            child: ProductWidget(
                                                prod: prod, refresh: refresh))
                                        : Padding(
                                            padding: const EdgeInsets.only(
                                                right: 15.0),
                                            child: ProductWidget(
                                                prod: prod, refresh: refresh),
                                          );
                                  },
                                )
                              : Center(
                                  child: Text('Nothing to see here :(',
                                      style: GoogleFonts.quicksand(
                                          color: Theme.of(context).accentColor,
                                          fontWeight: FontWeight.w500)))
                          : Center(
                              child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: LoadingIndicator(
                                    indicatorType: Indicator.ballClipRotate,
                                    color: Theme.of(context).accentColor,
                                  )))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Product.products().then((value) {
      setState(() {
        prodList = value;
        isDoneLoading = true;
      });
    });
  }

  bool get wantKeepAlive => true;
}
