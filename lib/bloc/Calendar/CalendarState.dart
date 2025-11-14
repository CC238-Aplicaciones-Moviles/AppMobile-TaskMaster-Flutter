part of 'CalendarBloc.dart';

abstract class CalendarState {
  const CalendarState();
}

class CalendarInitial extends CalendarState {
  const CalendarInitial();
}

class CalendarLoadInProgress extends CalendarState {
  const CalendarLoadInProgress();
}

class CalendarLoadSuccess extends CalendarState {
  final List<CalendarDay> calendarDays;
  final DateTime currentMonth;
  final DateTime? selectedDate;
  final List<TaskDto> selectedDateTasks;

  const CalendarLoadSuccess({
    required this.calendarDays,
    required this.currentMonth,
    this.selectedDate,
    this.selectedDateTasks = const [],
  });

  CalendarLoadSuccess copyWith({
    List<CalendarDay>? calendarDays,
    DateTime? currentMonth,
    DateTime? selectedDate,
    List<TaskDto>? selectedDateTasks,
  }) {
    return CalendarLoadSuccess(
      calendarDays: calendarDays ?? this.calendarDays,
      currentMonth: currentMonth ?? this.currentMonth,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedDateTasks: selectedDateTasks ?? this.selectedDateTasks,
    );
  }
}

class CalendarFailure extends CalendarState {
  final String message;

  const CalendarFailure({required this.message});
}
