import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/product.dart';
import 'package:unify/pages/SellProductPage.dart';
import 'package:unify/widgets/ProductWidget.dart';

class MyListings extends StatefulWidget {
  @override
  _MyListingsState createState() => _MyListingsState();
}

class _MyListingsState extends State<MyListings> {
  List<Product> prodList;
  List<Product> searchList = [];
  bool _isSearching = false;
  bool isDoneLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        backgroundColor: Theme.of(context).backgroundColor,
        centerTitle: false,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Theme.of(context).accentColor),
        title: Text(
          "My Listings",
          style: GoogleFonts.manrope(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).accentColor),
        ),
        actions: <Widget>[],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (_) {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Stack(
          children: <Widget>[
            RefreshIndicator(
              onRefresh: () async {
                await Product.myListings().then((value) {
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
                          color: Theme.of(context).accentColor.withOpacity(0.1),
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
                            hintStyle: GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).accentColor)),
                        style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).accentColor),
                      ),
                    ),
                  ),
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
                                      childAspectRatio: 50 / 75),
                              itemCount:
                                  _isSearching == false && prodList != null
                                      ? prodList.length
                                      : searchList.isNotEmpty
                                          ? searchList.length
                                          : 0,
                              itemBuilder: (BuildContext context, int index) {
                                Product prod =
                                    _isSearching == false && prodList != null
                                        ? prodList[index]
                                        : searchList.isNotEmpty
                                            ? searchList[index]
                                            : Product();
                                Function refresh = () async {
                                  await Product.myListings().then((value) {
                                    setState(() {
                                      prodList = value;
                                    });
                                  });
                                };
                                return index % 2 == 0
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(left: 15.0),
                                        child: ProductWidget(
                                            prod: prod, refresh: refresh))
                                    : Padding(
                                        padding:
                                            const EdgeInsets.only(right: 15.0),
                                        child: ProductWidget(
                                            prod: prod, refresh: refresh),
                                      );
                              },
                            )
                          : Center(child: Text('No products found'))
                      : Center(
                          child: SizedBox(
                              width: 15,
                              height: 15,
                              child: LoadingIndicator(
                                indicatorType: Indicator.circleStrokeSpin,
                                color: Theme.of(context).accentColor,
                              )))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Product.myListings().then((value) {
      setState(() {
        prodList = value;
        isDoneLoading = true;
      });
    });
  }
}
