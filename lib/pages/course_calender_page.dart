import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:toast/toast.dart';
import 'package:unify/Widgets/AssignmentWidget.dart';
import 'package:unify/Models/assignment.dart';
import 'package:unify/Models/club.dart';
import 'package:unify/Models/course.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:unify/Models/notification.dart';
import 'package:unify/pages/DB.dart';

class CourseCalendarPage extends StatefulWidget {
  final Course course;
  final Club club;
  CourseCalendarPage({Key key, this.course, this.club}) : super(key: key);

  @override
  _CourseCalendarPage createState() => _CourseCalendarPage();
}

class _CourseCalendarPage extends State<CourseCalendarPage> {
  DateTime dateTimeSelected;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController timeDueController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dateTimeSelected = DateTime.now();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    timeDueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TableCalendar tCalendar = TableCalendar(
      onDaySelected: (dt, lst) {
        setState(() {
          dateTimeSelected = dt;
        });
      },
      // onDaySelected: (dt, lst) {
      //   setState(() {
      //     dateTimeSelected = dt;
      //   });
      // },

      // TODO: CHECK TO FIX HERE

      focusedDay: dateTimeSelected,
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
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
        defaultTextStyle: GoogleFonts.quicksand(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).accentColor),
        weekendTextStyle: GoogleFonts.quicksand(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).accentColor),
        holidayTextStyle: GoogleFonts.quicksand(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).accentColor),
        outsideTextStyle: GoogleFonts.quicksand(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).accentColor),
        selectedTextStyle: GoogleFonts.quicksand(
            fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white),
        todayTextStyle: GoogleFonts.quicksand(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).accentColor),
        disabledTextStyle: GoogleFonts.quicksand(
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
                  "${widget.course != null ? 'Date:' : 'Date:'} ${dateTimeSelected.year} ${dateTimeSelected.month} ${dateTimeSelected.day}",
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
                    hintText: widget.course != null
                        ? "Title. Eg: Study session"
                        : "Title. Eg: Lunch meeting"),
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
                    hintText: widget.course != null
                        ? "Description..."
                        : "Description..."),
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
                    hintText:
                        widget.course != null ? "When is it?" : "When is it?"),
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
            var res = widget.course != null
                ? await createAssignment(
                    assignment, widget.course, formattedDate)
                : await createEventReminder(
                    assignment, widget.club, formattedDate);
            if (res) {
              titleController.clear();
              descriptionController.clear();
              timeDueController.clear();
              setState(() {});
              if (widget.course != null) {
                for (var member in widget.course.memberList) {
                  if (member.id != FIR_UID) {
                    var token = member.deviceToken;
                    await sendPushCourse(widget.course, 4, token,
                        assignment.title, null, member.id);
                  }
                }
              } else {
                for (var member in widget.club.memberList) {
                  if (member.id != FIR_UID) {
                    var token = member.deviceToken;
                    await sendPushClub(widget.club, 4, token, assignment.title,
                        null, member.id);
                  }
                }
              }
            } else {}
          })
        ..show();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        brightness: Theme.of(context).brightness,
        title: Text(
          widget.course != null
              ? "${widget.course.code} Calendar"
              : "${widget.club.name} Calendar",
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
            InkWell(
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
                          widget.course != null
                              ? "Create note for ${widget.course.code}"
                              : "Create note for ${widget.club.name}",
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
            FutureBuilder(
              future: widget.course != null
                  ? fetchAssignments(dateTimeSelected, widget.course)
                  : fetchEventReminders(dateTimeSelected, widget.club),
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
                        var res = await deleteAssignment(widget.club,
                            widget.course, assignment, formattedDate);
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
