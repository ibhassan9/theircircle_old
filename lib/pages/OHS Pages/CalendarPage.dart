import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:toast/toast.dart';
import 'package:unify/Models/OHS.dart';
import 'package:unify/Widgets/AssignmentWidget.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/assignment.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:unify/Models/notification.dart';
import 'package:unify/Models/user.dart';

class OHSCalendarPage extends StatefulWidget {
  final Club club;
  OHSCalendarPage({Key key, this.club}) : super(key: key);

  @override
  _OHSCalendarPage createState() => _OHSCalendarPage();
}

class _OHSCalendarPage extends State<OHSCalendarPage> {
  CalendarController _calendarController;
  DateTime dateTimeSelected;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController timeDueController = TextEditingController();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _calendarController = CalendarController();
    dateTimeSelected = DateTime.now();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    timeDueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TableCalendar tCalendar = TableCalendar(
      onDaySelected: (dt, lst, lst1) {
        setState(() {
          dateTimeSelected = dt;
        });
      },
      // onDaySelected: (dt, lst) {
      //   setState(() {
      //     dateTimeSelected = dt;
      //   });
      // },
      calendarController: _calendarController,
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: GoogleFonts.quicksand(
            fontSize: 14, fontWeight: FontWeight.w500, color: Colors.lightBlue),
        weekendStyle: GoogleFonts.quicksand(
            fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red),
      ),
      headerStyle: HeaderStyle(
        titleTextStyle: GoogleFonts.quicksand(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).accentColor),
        formatButtonTextStyle: GoogleFonts.quicksand(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).accentColor),
      ),
      calendarStyle: CalendarStyle(
        weekdayStyle: GoogleFonts.quicksand(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).accentColor),
        weekendStyle: GoogleFonts.quicksand(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).accentColor),
        holidayStyle: GoogleFonts.quicksand(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).accentColor),
        outsideHolidayStyle: GoogleFonts.quicksand(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).accentColor),
        selectedStyle: GoogleFonts.quicksand(
            fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white),
        todayStyle: GoogleFonts.quicksand(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).accentColor),
        outsideStyle: GoogleFonts.quicksand(
            fontSize: 17, fontWeight: FontWeight.w500, color: Colors.red),
        outsideWeekendStyle: GoogleFonts.quicksand(
            fontSize: 17, fontWeight: FontWeight.w500, color: Colors.red),
        unavailableStyle: GoogleFonts.quicksand(
            fontSize: 17, fontWeight: FontWeight.w500, color: Colors.blue),
      ),
    );

    showAddDialog() {
      AwesomeDialog(
          context: context,
          animType: AnimType.SCALE,
          dialogType: DialogType.NO_HEADER,
          body: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Date: ${dateTimeSelected.year} ${dateTimeSelected.month} ${dateTimeSelected.day}",
                  style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).accentColor),
                ),
              ),
              TextField(
                controller: titleController,
                decoration: new InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                        left: 15, bottom: 11, top: 11, right: 15),
                    hintText: "Title. Eg: Weekly seminar"),
                style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              ),
              TextField(
                controller: descriptionController,
                decoration: new InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                        left: 15, bottom: 11, top: 11, right: 15),
                    hintText: "Description..."),
                style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              ),
              TextField(
                controller: timeDueController,
                decoration: new InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                        left: 15, bottom: 11, top: 11, right: 15),
                    hintText: "When is it?"),
                style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).accentColor),
              ),
            ],
          ),
          btnOkColor: Colors.deepPurpleAccent,
          btnOkOnPress: () async {
            if (titleController.text.isEmpty ||
                descriptionController.text.isEmpty ||
                timeDueController.text.isEmpty) {
              Toast.show("All fields are required.", context);
              return;
            }
            var assignment = Assignment(
                title: titleController.text,
                description: descriptionController.text,
                timeDue: timeDueController.text);
            String formattedDate =
                DateFormat('yyyy-MM-dd').format(dateTimeSelected);
            var res =
                await OneHealingSpace.createReminder(assignment, formattedDate);
            if (res) {
              titleController.clear();
              descriptionController.clear();
              timeDueController.clear();
              setState(() {});
              // TODO: send push notification
              // if (widget.course != null) {
              //   for (var member in widget.course.memberList) {
              //     if (member.id != firebaseAuth.currentUser.uid) {
              //       var token = member.device_token;
              //       await sendPushCourse(
              //           widget.course, 4, token, assignment.title, null);
              //     }
              //   }
              // } else {
              //   for (var member in widget.club.memberList) {
              //     if (member.id != firebaseAuth.currentUser.uid) {
              //       var token = member.device_token;
              //       await sendPushClub(
              //           widget.club, 4, token, assignment.title, null);
              //     }
              //   }
              // }
            } else {}
          })
        ..show();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        title: Text(
          "${widget.club.name} Calendar",
          style: GoogleFonts.quicksand(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).accentColor),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
        iconTheme: IconThemeData(color: Theme.of(context).accentColor),
      ),
      body: Stack(children: [
        ListView(
          children: <Widget>[
            tCalendar,
            Visibility(
              visible: widget.club.admin,
              child: InkWell(
                onTap: () {
                  showAddDialog();
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.0),
                        color: Colors.deepPurpleAccent),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.add, color: Colors.white),
                          Text(
                            "Create reminder for ${widget.club.name}",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.quicksand(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            FutureBuilder(
              future: OneHealingSpace.fetchReminders(dateTimeSelected),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data != null ? snapshot.data.length : 0,
                    itemBuilder: (BuildContext context, int index) {
                      Assignment assignment = snapshot.data[index];

                      Function delete = () async {
                        String formattedDate =
                            DateFormat('yyyy-MM-dd').format(dateTimeSelected);
                        var res = await OneHealingSpace.deleteReminder(
                            widget.club, assignment, formattedDate);
                        if (res) {
                          setState(() {});
                        }
                      };
                      var timeAgo = new DateTime.fromMillisecondsSinceEpoch(
                          assignment.timeStamp);
                      return AssignmentWidget(
                          club: widget.club,
                          assignment: assignment,
                          timeAgo: timeago.format(timeAgo),
                          delete: delete);
                    },
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        )
      ]),
    );
  }
}
