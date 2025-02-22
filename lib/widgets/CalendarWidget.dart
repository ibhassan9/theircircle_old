import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime dateTimeSelected = DateTime.now();

  Widget build(BuildContext context) {
    TableCalendar tCalendar = TableCalendar(
      focusedDay: dateTimeSelected,
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      availableCalendarFormats: {CalendarFormat.week: 'Week'},
      onDaySelected: (dt, lst) async {
        setState(() {
          dateTimeSelected = dt;
        });
        //var assignments = await fetchAllMyAssignments(dt);
      },
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: GoogleFonts.quicksand(
            fontSize: 14, fontWeight: FontWeight.w500, color: Colors.lightBlue),
        weekendStyle: GoogleFonts.quicksand(
            fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red),
      ),
      headerStyle: HeaderStyle(
        titleTextStyle: GoogleFonts.quicksand(
            fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),
        formatButtonTextStyle: GoogleFonts.quicksand(
            fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
      ),
      calendarStyle: CalendarStyle(
        defaultTextStyle: GoogleFonts.quicksand(
            fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),
        weekendTextStyle: GoogleFonts.quicksand(
            fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),
        holidayTextStyle: GoogleFonts.quicksand(
            fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),
        outsideTextStyle: GoogleFonts.quicksand(
            fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),
        selectedTextStyle: GoogleFonts.quicksand(
            fontSize: 17, fontWeight: FontWeight.w500, color: Colors.white),
        todayTextStyle: GoogleFonts.quicksand(
            fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),
        disabledTextStyle: GoogleFonts.quicksand(
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
              style: GoogleFonts.quicksand(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black)),
          SizedBox(height: 10.0),
        ]),
      ),
    );
  }
}
