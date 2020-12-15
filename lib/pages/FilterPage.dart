import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:unify/Widgets/FilterWidget.dart';
import 'package:unify/pages/ReportPage.dart';

class FilterPage extends StatefulWidget {
  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  TextEditingController filterController = TextEditingController();

  List<String> filters = [];

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        centerTitle: false,
        elevation: 0.5,
        iconTheme: IconThemeData(color: Theme.of(context).accentColor),
        actions: [
          IconButton(
              icon: Icon(FlutterIcons.report_mdi),
              color: Colors.red,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ReportPage()));
              }),
        ],
        title: Text(
          "Filters",
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).accentColor),
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(children: [
            Container(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                      child: TextField(
                    controller: filterController,
                    decoration: new InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                            left: 15, bottom: 11, top: 11, right: 15),
                        hintText: "Insert word filter here..."),
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).accentColor),
                    ),
                  )),
                  IconButton(
                    icon: Icon(
                      FlutterIcons.add_mdi,
                      color: Theme.of(context).accentColor,
                    ),
                    onPressed: () async {
                      if (filterController.text.isEmpty) {
                        Toast.show('Please add a word.', context);
                        return;
                      }
                      await addFilter(filterController.text);
                    },
                  )
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Words added here will not appear in your timeline.',
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey),
                ),
              ),
            ),
            ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: NeverScrollableScrollPhysics(),
                itemCount: filters.length > 0 ? filters.length : 0,
                itemBuilder: (BuildContext context, int index) {
                  Function remove = () async {
                    await removeFilter(filters[index]);
                  };
                  return FilterWidget(text: filters[index], remove: remove);
                }),
          ]),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getFilters();
  }

  getFilters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var filterList = prefs.getStringList('filters');
    if (filterList != null) {
      setState(() {
        filters = filterList;
      });
    }
  }

  Future<Null> addFilter(String text) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var filterList = prefs.getStringList('filters');
    if (filterList == null) {
      filterList = [];
    }
    filterList.add(text);
    prefs.setStringList('filters', filterList);
    setState(() {
      filters = filterList;
    });
    filterController.clear();
  }

  Future<Null> removeFilter(String text) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var filterList = prefs.getStringList('filters');
    filterList.removeWhere((element) => element == text);
    prefs.setStringList('filters', filterList);
    setState(() {
      filters = filterList;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    filterController.dispose();
  }
}
