import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../class/event.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key, required this.period_list, required this.newest_day, required this.newest_end_day}) : super(key: key);
  final period_list;
  final newest_day;
  final newest_end_day;
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<DateTime> mark_days = [];
  List<dynamic> _selectedEvent = [];
  String for_print_selected_day = DateFormat('yyyy년 MM월 dd일').format(DateTime.now());
  String for_print_explain = '';
  void FindBetweenDay(DateTime startDate, DateTime endDate) {
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      mark_days.add(startDate.add(Duration(days: i)));
    }
  }
  List<DateTime> predict_days = [];
  void PredictDay(DateTime Newest_Date) {
    if (widget.period_list.length ~/ 3 == 1) {
      int temp_days = int.parse(widget.period_list[2]);
      for (int i = 0; i <= temp_days; i++) {
        predict_days.add(Newest_Date.add(Duration(days: 28+i)));
      }
    }
    else {
      int temp_days = 0;
      for (int j = 2; j < widget.period_list.length; j = j+3) {
        temp_days = temp_days + int.parse(widget.period_list[j]);
      }
      temp_days = (temp_days / (int.parse(widget.period_list.length) / 3)).round(); //평균 생리기간
      for (int i = 0; i <= temp_days; i++) {
        predict_days.add(Newest_Date.add(Duration(days: 28+i)));
      }
    }
  }
  Map<DateTime, List<Event>> events = {};
  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }
  DateTime selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime focusedDay = DateTime.now();
  @override
  void initState() {
    // TODO: implement initState
    for (int i=0; i<widget.period_list.length; i=i+3) {
      String temp_start = widget.period_list[i];
      String temp_end = widget.period_list[i+1];
      int temp_start_year =int.parse(temp_start.substring(0,4));
      int temp_start_mon =int.parse(temp_start.substring(5,7));
      int temp_start_day =int.parse(temp_start.substring(8,10));
      int temp_end_year =int.parse(temp_end.substring(0,4));
      int temp_end_mon =int.parse(temp_end.substring(5,7));
      int temp_end_day =int.parse(temp_end.substring(8,10));
      FindBetweenDay(DateTime.utc(temp_start_year, temp_start_mon, temp_start_day),
        DateTime.utc(temp_end_year, temp_end_mon, temp_end_day));

    }
    for (int j=0; j<mark_days.length; j++) {
      events[mark_days[j]] = [Event('생리일')];
    }
    String temp_newest_start = widget.newest_day;
    int temp_newest_year =int.parse(temp_newest_start.substring(0,4));
    int temp_newest_mon =int.parse(temp_newest_start.substring(5,7));
    int temp_newest_day =int.parse(temp_newest_start.substring(8,10));
    PredictDay(DateTime.utc(temp_newest_year, temp_newest_mon, temp_newest_day));
    for (int j=0; j<predict_days.length; j++) {
      events[predict_days[j]] = [Event('생리예정일')];
    }
    super.initState();

  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Diary'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              locale: 'ko_KR',
              firstDay: DateTime.utc(1900, 1, 1),
              lastDay: DateTime.utc(2037, 12, 31),
              focusedDay: focusedDay,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              //rangeStartDay: DateFormat('yyyy-MM-dd').parse(widget.period_list[0]),
              //rangeEndDay: DateFormat('yyyy-MM-dd').parse(widget.period_list[1]),
              eventLoader: _getEventsForDay,
              onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                setState((){
                  this.selectedDay = selectedDay;
                  this.focusedDay = focusedDay;
                  for_print_selected_day = DateFormat('yyyy년 MM월 dd일').format(selectedDay);
                  if (_getEventsForDay(selectedDay).length != 0) {
                    print(_getEventsForDay(selectedDay)[0].title);
                    for_print_explain = _getEventsForDay(selectedDay)[0].title;
                  }
                  else {
                    for_print_explain = '';
                  }
                });
              },
              selectedDayPredicate: (DateTime day) {
                return isSameDay(selectedDay, day);
              },
              calendarStyle: CalendarStyle(
                outsideDaysVisible : false,
                isTodayHighlighted : false,
                rangeStartDecoration: BoxDecoration(
                  color : const Color(0xFFF48FB1),
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: BoxDecoration(
                  color: const Color(0xFFF48FB1),
                  shape: BoxShape.circle,
                ),
                rangeHighlightColor: const Color(0xFFF48FB1),
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration : const BoxDecoration(
                  color: const Color(0xFFB2EBF2),
                  shape: BoxShape.circle,
                ),
                markerSizeScale : 0.15,
                //markersAlignment : Alignment.topCenter,
                markerDecoration : const BoxDecoration(
                  color: const Color(0xFFF48FB1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Divider(height: 2),
            Container(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    for_print_selected_day,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 25,),
                  Text(
                    for_print_explain,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
