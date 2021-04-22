import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:unify/Components/Constants.dart';
import 'package:unify/Models/user.dart';

class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  CalendarController _calendarController = CalendarController();
  DateTime dateTimeSelected = DateTime.now();

  Widget build(BuildContext context) {
    TableCalendar tCalendar = TableCalendar(
      availableCalendarFormats: {CalendarFormat.week: 'Week'},
      initialCalendarFormat: CalendarFormat.week,
      onDaySelected: (dt, lst, lst1) async {
        setState(() {
          dateTimeSelected = dt;
        });
        //var assignments = await fetchAllMyAssignments(dt);
      },
      calendarController: _calendarController,
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: GoogleFonts.manrope(
            fontSize: 14, fontWeight: FontWeight.w500, color: Colors.lightBlue),
        weekendStyle: GoogleFonts.manrope(
            fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red),
      ),
      headerStyle: HeaderStyle(
        titleTextStyle: GoogleFonts.manrope(
            fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),
        formatButtonTextStyle: GoogleFonts.manrope(
            fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
      ),
      calendarStyle: CalendarStyle(
        weekdayStyle: GoogleFonts.manrope(
            fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),
        weekendStyle: GoogleFonts.manrope(
            fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),
        holidayStyle: GoogleFonts.manrope(
            fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),
        outsideHolidayStyle: GoogleFonts.manrope(
            fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),
        selectedStyle: GoogleFonts.manrope(
            fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white),
        todayStyle: GoogleFonts.manrope(
            fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),
        outsideStyle: GoogleFonts.manrope(
            fontSize: 17, fontWeight: FontWeight.w500, color: Colors.red),
        outsideWeekendStyle: GoogleFonts.manrope(
            fontSize: 17, fontWeight: FontWeight.w500, color: Colors.red),
        unavailableStyle: GoogleFonts.manrope(
            fontSize: 17, fontWeight: FontWeight.w500, color: Colors.blue),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 15.0),
      child: Card(
        elevation: 5.0,
        child: Column(children: [
          tCalendar,
          SizedBox(height: 10.0),
          Text("Nothing to show here...",
              style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black)),
          SizedBox(height: 10.0),
        ]),
      ),
    );
  }
}
