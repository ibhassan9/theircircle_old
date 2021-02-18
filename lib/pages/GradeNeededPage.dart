import 'package:flutter/material.dart';
import 'package:flutter_unicons/unicons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:toast/toast.dart';

class GradeNeededPage extends StatefulWidget {
  @override
  _GradeNeededPageState createState() => _GradeNeededPageState();
}

class _GradeNeededPageState extends State<GradeNeededPage> {
  List<Map<String, dynamic>> rows = [];
  List<TextEditingController> weightTECs = [];
  List<TextEditingController> gradeTECs = [];
  TextEditingController finalGradeController = TextEditingController();

  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        //FocusScope.of(context).requestFocus(FocusNode());
      },
      onPanDown: (_) {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            centerTitle: false,
            title: Text(
              'Final Grade Needed Calculator',
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
                            'Sections',
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
                            'Grade (%)',
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
                            'Weight (%)',
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
              ))),
    );
  }

  Widget bottomBar() {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15.0, left: 10.0, right: 10.0),
        child: Container(
          height: 100,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Final grade you wish to receive: ',
                    style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).accentColor),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Container(
                    width: 90,
                    height: 30,
                    decoration: BoxDecoration(
                        color: Colors.pink,
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10.0, left: 10.0),
                      child: Center(
                          child: Row(
                        children: [
                          Flexible(
                            child: TextField(
                              controller: finalGradeController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: new InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                    left: 11, bottom: 11, top: 11, right: 11),
                                hintText: '0.0',
                                hintStyle: GoogleFonts.quicksand(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                              style: GoogleFonts.quicksand(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                          ),
                          Text(
                            '%',
                            style: GoogleFonts.quicksand(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          )
                        ],
                      )),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              InkWell(
                onTap: () {
                  double totalGrade = 0.0;
                  double totalWeight = 0.0;
                  for (var i = 0; i < weightTECs.length; i++) {
                    if (weightTECs[i].text.isNotEmpty &&
                        gradeTECs[i].text.isNotEmpty) {
                      var weight = double.parse(weightTECs[i].text);
                      var grade = double.parse(gradeTECs[i].text);
                      totalGrade += grade * weight;
                      totalWeight += weight;
                    }
                  }

                  var currentGrade = totalGrade / totalWeight;

                  if (finalGradeController.text.isNotEmpty) {
                    // ( required grade - (100% - w)×current grade ) / w
                    var finalExamWeight = 100.0 - totalWeight;
                    var requiredGrade =
                        ((double.parse(finalGradeController.text) / 100) -
                                (1 - (finalExamWeight / 100)) *
                                    (currentGrade / 100)) /
                            (finalExamWeight / 100);
                    FocusScope.of(context).unfocus();
                    print('Required Grade is ' +
                        (requiredGrade * 100).toStringAsFixed(2));
                    print('Current Grade is ' + currentGrade.toString());
                    showBarModalBottomSheet(
                        context: context,
                        builder: (context) => resultContainer(
                            false,
                            requiredGrade,
                            double.parse(finalGradeController.text)));
                  } else {
                    FocusScope.of(context).unfocus();
                    showBarModalBottomSheet(
                        context: context,
                        builder: (context) => resultContainer(
                            true, totalGrade / totalWeight, null));
                  }
                },
                child: Container(
                  height: 50.0,
                  decoration: BoxDecoration(
                      color: Colors.indigo[700],
                      borderRadius: BorderRadius.circular(45.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'CALCULATE',
                          style: GoogleFonts.quicksand(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container resultContainer(
      bool isCurrent, double value, double requiredValue) {
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
                isCurrent
                    ? '${value.toStringAsFixed(1)}%'
                    : '${(value * 100).toStringAsFixed(1)}%',
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
                isCurrent
                    ? 'Your Current Grade is ${value.toStringAsFixed(1)}%'
                    : 'You need ${(value * 100).toStringAsFixed(1)}% in your upcoming assignments/quizzes/tests to achieve a final grade of ${requiredValue.toStringAsFixed(1)}%',
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
                'Section #$index',
                style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.3,
          height: 40,
          decoration: BoxDecoration(
              color: Colors.pink, borderRadius: BorderRadius.circular(3.0)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 5.0),
            child: Center(
                child: Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: gradeTECs[index],
                    textAlign: TextAlign.center,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: new InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                          left: 11, bottom: 11, top: 11, right: 11),
                      hintText: '0.0',
                      hintStyle: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                    style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ),
                Text(
                  '%',
                  style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                )
              ],
            )),
          ),
        ),
        Container(
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
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: weightTECs[index],
                      textAlign: TextAlign.center,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: new InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.only(
                            left: 11, bottom: 11, top: 11, right: 11),
                        hintText: '0.0',
                        hintStyle: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                      style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                  ),
                  Text(
                    '%',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget createRowBtn() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              double grade = 0.0;
              double weight = 0.0;
              this.setState(() {
                weightTECs.add(new TextEditingController());
                gradeTECs.add(new TextEditingController());
                rows.add({'weight': weight, 'grade': grade});
              });
            },
            child: Row(
              children: [
                Unicon(UniconData.uniPlusCircle,
                    color: Theme.of(context).accentColor),
                SizedBox(width: 7.0),
                Text(
                  'Add Section',
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
                weightTECs.removeLast();
                gradeTECs.removeLast();
                rows.removeLast();
              });
            },
            child: Row(
              children: [
                Text(
                  'Remove Section',
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    for (var tec in weightTECs) {
      tec.dispose();
    }
    for (var tec in gradeTECs) {
      tec.dispose();
    }
  }
}
