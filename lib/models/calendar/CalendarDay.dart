import '../tasks/TaskDto.dart';

class CalendarDay {
  final DateTime date;
  final int day;
  final bool isCurrentMonth;
  final List<TaskDto> tasks;

  CalendarDay({
    required this.date,
    required this.day,
    required this.isCurrentMonth,
    required this.tasks,
  });

  CalendarDay copyWith({
    DateTime? date,
    int? day,
    bool? isCurrentMonth,
    List<TaskDto>? tasks,
  }) {
    return CalendarDay(
      date: date ?? this.date,
      day: day ?? this.day,
      isCurrentMonth: isCurrentMonth ?? this.isCurrentMonth,
      tasks: tasks ?? this.tasks,
    );
  }
}
