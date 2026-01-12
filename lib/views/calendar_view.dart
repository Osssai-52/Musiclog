import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('2026',
                          maxLines: 1,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            height: 1.2,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nanum',
                          ),
                          ),
                          Text('January',
                            maxLines: 1,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              height: 0.9,
                              fontSize: 50,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Nanum',
                            ),

                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                SizedBox(height: 10.0,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: TableCalendar(
                        focusedDay: DateTime.now(),
                        firstDay: DateTime.utc(2026, 1, 1),
                        lastDay: DateTime.utc(2026, 1, 31),
                        headerVisible: false,
                        calendarBuilders: CalendarBuilders(
                          dowBuilder: (context, date) {
                            String text;
                            switch (date.weekday) {
                              case 1: text = 'M';
                              case 2: text = 'T';
                              case 3: text = 'W';
                              case 4: text = 'T';
                              case 5: text = 'F';
                              case 6: text = 'S';
                              case 7: text = 'S';
                              default: text = DateFormat.E('en_US').format(date);
                            }

                            return Center(
                              child: Text(
                                text,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: "Nanum"),
                              ),
                            );
                          },
                        ),
                        calendarStyle: CalendarStyle(
                          defaultTextStyle: TextStyle(fontFamily: "Nanum", fontSize: 20, fontWeight: FontWeight.bold),
                          weekendTextStyle: TextStyle(fontFamily: "Nanum", fontSize: 20, fontWeight: FontWeight.bold),
                          selectedTextStyle: TextStyle(fontFamily: "Nanum"),
                          todayTextStyle: TextStyle(fontFamily: "Nanum", fontSize: 20, fontWeight: FontWeight.bold),
                          outsideDaysVisible: false,
                        ),
                    ),
                  ),
                )
              ],
            )
        ),
      ),
    );
  }
}
