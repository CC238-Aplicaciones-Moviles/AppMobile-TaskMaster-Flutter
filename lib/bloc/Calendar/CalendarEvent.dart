part of 'CalendarBloc.dart';

abstract class CalendarEvent {
  const CalendarEvent();
}

class CalendarLoadRequested extends CalendarEvent {
  final int userId;

  const CalendarLoadRequested(this.userId);
}

class CalendarMonthChanged extends CalendarEvent {
  final DateTime month;

  const CalendarMonthChanged(this.month);
}

class CalendarDateSelected extends CalendarEvent {
  final DateTime date;

  const CalendarDateSelected(this.date);
}

class CalendarRefreshRequested extends CalendarEvent {
  const CalendarRefreshRequested();
}
