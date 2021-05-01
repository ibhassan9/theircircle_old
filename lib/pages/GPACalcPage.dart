import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_unicons/unicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:unify/pages/GradeNeededPage.dart';
import 'package:unify/pages/DB.dart';

class GPACalculator extends StatefulWidget {
  @override
  _GPACalculatorState createState() => _GPACalculatorState();
}

class _GPACalculatorState extends State<GPACalculator> {
  List<Map<String, dynamic>> rows = [];

  List<Map<String, dynamic>> westernU = [
    {'letter': 'A+', 'percentage': '90-100', 'gpa': 4.0},
    {'letter': 'A', 'percentage': '85-89', 'gpa': 3.9},
    {'letter': 'A-', 'percentage': '80-84', 'gpa': 3.7},
    {'letter': 'B+', 'percentage': '77-79', 'gpa': 3.3},
    {'letter': 'B', 'percentage': '73-76', 'gpa': 3.0},
    {'letter': 'B-', 'percentage': '70-72', 'gpa': 2.7},
    {'letter': 'C+', 'percentage': '67-69', 'gpa': 2.3},
    {'letter': 'C', 'percentage': '63-66', 'gpa': 2.0},
    {'letter': 'C-', 'percentage': '60-62', 'gpa': 1.7},
    {'letter': 'D+', 'percentage': '57-59', 'gpa': 1.3},
    {'letter': 'D', 'percentage': '53-56', 'gpa': 1.0},
    {'letter': 'D-', 'percentage': '50-52', 'gpa': 0.7},
    {'letter': 'E, F', 'percentage': '0-49', 'gpa': 0.0},
  ];

  List<double> yuweight = [1, 1.5, 2, 3, 4, 6, 8, 9, 15];
  List<double> westernweight = [0.5, 1.0, 2.0];
  List<double> uoftweight = [0.5, 1.0];

  List<Map<String, dynamic>> uoft = [
    {'letter': 'A+', 'percentage': '90-100', 'gpa': 4.0},
    {'letter': 'A', 'percentage': '85-89', 'gpa': 4.0},
    {'letter': 'A-', 'percentage': '80-84', 'gpa': 3.7},
    {'letter': 'B+', 'percentage': '77-79', 'gpa': 3.3},
    {'letter': 'B', 'percentage': '73-76', 'gpa': 3.0},
    {'letter': 'B-', 'percentage': '70-72', 'gpa': 2.7},
    {'letter': 'C+', 'percentage': '67-69', 'gpa': 2.3},
    {'letter': 'C', 'percentage': '63-66', 'gpa': 2.0},
    {'letter': 'C-', 'percentage': '60-62', 'gpa': 1.7},
    {'letter': 'D+', 'percentage': '57-59', 'gpa': 1.3},
    {'letter': 'D', 'percentage': '53-56', 'gpa': 1.0},
    {'letter': 'D-', 'percentage': '50-52', 'gpa': 0.7},
    {'letter': 'E, F, NC', 'percentage': '0-49', 'gpa': 0.0},
  ];
  List<Map<String, dynamic>> yorkU = [
    {'letter': 'A+', '9-point': 9, 'percentage': '90-100', 'gpa': 4.0},
    {'letter': 'A', '9-point': 8, 'percentage': '80-89', 'gpa': 3.8},
    {'letter': 'B+', '9-point': 7, 'percentage': '75-79', 'gpa': 3.3},
    {'letter': 'B', '9-point': 6, 'percentage': '70-74', 'gpa': 3.0},
    {'letter': 'C+', '9-point': 5, 'percentage': '65-69', 'gpa': 2.3},
    {'letter': 'C', '9-point': 4, 'percentage': '60-64', 'gpa': 2.0},
    {'letter': 'D+', '9-point': 3, 'percentage': '55-59', 'gpa': 1.3},
    {'letter': 'D', '9-point': 2, 'percentage': '50-54', 'gpa': 1.0},
    {'letter': 'E', '9-point': 1, 'percentage': '40-49', 'gpa': 0.7},
    {'letter': 'F, NC', '9-point': 0, 'percentage': '0-39', 'gpa': 0},
  ];
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          centerTitle: false,
          title: Text(
            'GPA Calculator',
            style: GoogleFonts.quicksand(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).accentColor),
          ),
          elevation: 0.0,
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        bottomNavigationBar: bottomBar(),
        body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView(
              physics: AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: 40,
                      child: Center(
                        child: Text(
                          'Courses',
                          style: GoogleFonts.quicksand(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).accentColor),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: 40,
                      child: Center(
                        child: Text(
                          'Weight',
                          style: GoogleFonts.quicksand(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).accentColor),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: 40,
                      child: Center(
                        child: Text(
                          'Final Grade',
                          style: GoogleFonts.quicksand(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).accentColor),
                        ),
                      ),
                    )
                  ],
                ),
                ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: rows.length == 0 ? 1 : rows.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data =
                          rows.length == 0 ? {} : rows[index];
                      return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: rows.length == 0
                              ? createRowBtn()
                              : index == rows.length - 1
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        createRow(data, index),
                                        createRowBtn()
                                      ],
                                    )
                                  : createRow(data, index));
                    }),
              ],
            )));
  }

  Widget createRowBtn() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              var grade = uniKey == 0
                  ? uoft.length - 2
                  : uniKey == 1
                      ? yorkU.length - 2
                      : westernU.length - 2;
              var weight = uniKey == 0
                  ? uoftweight[0]
                  : uniKey == 1
                      ? yuweight[0]
                      : westernU[0];
              this.setState(() {
                rows.add({'weight': weight, 'grade': grade});
              });
            },
            child: Row(
              children: [
                Unicon(UniconData.uniPlusCircle,
                    color: Theme.of(context).accentColor),
                SizedBox(width: 7.0),
                Text(
                  'Add Course',
                  style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).accentColor),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              this.setState(() {
                rows.removeLast();
              });
            },
            child: Row(
              children: [
                Text(
                  'Remove Course',
                  style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.red),
                ),
                SizedBox(width: 7.0),
                Unicon(UniconData.uniMinusCircle, color: Colors.red),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- START HERE ----

  Widget bottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
      child: Container(
        height: 120,
        child: Column(
          children: [
            InkWell(
              onTap: () {
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => GradeNeededPage()));
                showBarModalBottomSheet(
                    context: context, builder: (context) => GradeNeededPage());
              },
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Center(
                    child: Text(
                      'Final Grade Needed Calculator',
                      style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).accentColor),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            InkWell(
              onTap: () {
                showBarModalBottomSheet(
                    context: context, builder: (context) => resultContainer());
              },
              child: Container(
                height: 50.0,
                decoration: BoxDecoration(
                    color: Colors.indigo[700],
                    borderRadius: BorderRadius.circular(45.0)),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Unicon(UniconData.uniCalculatorAlt,
                            color: Colors.white),
                        SizedBox(width: 10.0),
                        Text(
                          'CALCULATE',
                          style: GoogleFonts.quicksand(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- END HERE ----

  Container resultContainer() {
    return Container(
      height: MediaQuery.of(context).size.height / 4,
      color: Colors.deepPurpleAccent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 30, 40, 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                calculateGPA().toStringAsFixed(2),
                textAlign: TextAlign.center,
                maxLines: null,
                style: GoogleFonts.quicksand(
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
            ),
            SizedBox(height: 15.0),
            Center(
              child: Text(
                'Your current GPA is ' + calculateGPA().toStringAsFixed(2),
                textAlign: TextAlign.center,
                maxLines: null,
                style: GoogleFonts.quicksand(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
            ),
            Center(
              child: Text(
                'You have ' + countCredits().toString() + ' credit(s) achieved',
                textAlign: TextAlign.center,
                maxLines: null,
                style: GoogleFonts.quicksand(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> generateWeightSheet(int index) {
    List<Widget> sheetOptions = [];
    switch (uniKey) {
      case 0:
        for (var item in uoftweight) {
          sheetOptions.add(weightOption(item, index));
        }
        break;
      case 1:
        for (var item in yuweight) {
          sheetOptions.add(weightOption(item, index));
        }
        break;
      default:
        for (var item in westernweight) {
          sheetOptions.add(weightOption(item, index));
        }
        break;
    }
    return sheetOptions;
  }

  List<Widget> generateGradeSheet(int index) {
    List<Widget> sheetOptions = [];
    switch (uniKey) {
      case 0:
        for (var item in uoft) {
          var letter = item['letter'];
          var percentage = item['percentage'];
          var value = letter + ' (' + percentage + ')';
          int gradeIndex =
              uoft.indexWhere((element) => element['letter'] == letter);
          print(gradeIndex);
          sheetOptions.add(gradeOption(value, index, gradeIndex));
        }
        break;
      case 1:
        for (var item in yorkU) {
          var letter = item['letter'];
          var percentage = item['percentage'];
          var value = letter + ' (' + percentage + ')';
          int gradeIndex =
              yorkU.indexWhere((element) => element['letter'] == letter);
          sheetOptions.add(gradeOption(value, index, gradeIndex));
        }
        break;
      default:
        for (var item in westernU) {
          var letter = item['letter'];
          var percentage = item['percentage'];
          var value = letter + ' (' + percentage + ')';
          int gradeIndex =
              westernU.indexWhere((element) => element['letter'] == letter);
          sheetOptions.add(gradeOption(value, index, gradeIndex));
        }
        break;
    }
    return sheetOptions;
  }

  void showSelectionSheetGrade(int index) {
    final act = CupertinoActionSheet(
        title: Text('Grade Selection'),
        message: Text('Which grade did you achieve?'),
        actions: generateGradeSheet(index),
        cancelButton: CupertinoActionSheetAction(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ));
    showCupertinoModalPopup(
        context: context, builder: (BuildContext context) => act);
  }

  void showSelectionSheetWeight(int index) {
    final act = CupertinoActionSheet(
        title: Text('Weight Selection'),
        message: Text('What was the weight of this course?'),
        actions: generateWeightSheet(index),
        cancelButton: CupertinoActionSheetAction(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ));
    showCupertinoModalPopup(
        context: context, builder: (BuildContext context) => act);
  }

  Widget weightOption(double value, int index) {
    print(index);
    return CupertinoActionSheetAction(
      child: Text(
        value.toString(),
        style: GoogleFonts.quicksand(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).accentColor),
      ),
      onPressed: () {
        print(value);
        this.setState(() {
          rows[index]['weight'] = value;
          Navigator.pop(context);
        });
      },
    );
  }

  Widget gradeOption(String value, int index, int gradeIndex) {
    return CupertinoActionSheetAction(
      child: Text(
        value,
        style: GoogleFonts.quicksand(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).accentColor),
      ),
      onPressed: () {
        setState(() {
          rows[index]['grade'] = gradeIndex;
        });
        Navigator.pop(context);
      },
    );
  }

  double countCredits() {
    double creds = 0.0;
    for (var row in rows) {
      creds += row['weight'];
    }
    return creds;
  }

  double calculateGPA() {
    double totalGPA = 0.0;
    for (var row in rows) {
      totalGPA += getGPA(row['grade'], row['weight']);
    }
    var result = totalGPA / countCredits();
    if (result.isNaN) {
      return 0.0;
    }
    return totalGPA / countCredits();
  }

  double getGPA(int index, double credit) {
    var gpa = uniKey == 0
        ? uoft[index]['gpa']
        : uniKey == 1
            ? yorkU[index]['9-point']
            : westernU[index]['gpa'];
    return gpa * credit;
  }

  String getGrade(int index) {
    String grade = '';
    var letter = uniKey == 0
        ? uoft[index]['letter']
        : uniKey == 1
            ? yorkU[index]['letter']
            : westernU[index]['letter'];
    var percentage = uniKey == 0
        ? uoft[index]['percentage']
        : uniKey == 1
            ? yorkU[index]['percentage']
            : westernU[index]['percentage'];
    grade = letter + ' (' + percentage + ')';
    return grade;
  }

  Row createRow(Map<String, dynamic> data, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.3,
          height: 40,
          decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0))),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 5.0),
            child: Center(
              child: Text(
                'Course #$index',
                style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            showSelectionSheetWeight(index);
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.3,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.pink, borderRadius: BorderRadius.circular(3.0)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 5.0),
              child: Center(
                child: Text(
                  rows[index]['weight'].toString(),
                  style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            showSelectionSheetGrade(index);
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.3,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0))),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 5.0),
              child: Center(
                child: Text(
                  getGrade(rows[index]['grade']),
                  style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
