import 'package:bloc/bloc.dart';
import '../../models/calendar/CalendarDay.dart';
import '../../models/tasks/TaskDto.dart';
import '../../repository/TasksRepository.dart';

part 'CalendarEvent.dart';
part 'CalendarState.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final TasksRepository _repository;
  List<TaskDto> _allTasks = [];
  int? _currentUserId;

  CalendarBloc({TasksRepository? repository})
    : _repository = repository ?? TasksRepository(),
      super(const CalendarInitial()) {
    on<CalendarLoadRequested>(_onLoadRequested);
    on<CalendarMonthChanged>(_onMonthChanged);
    on<CalendarDateSelected>(_onDateSelected);
    on<CalendarRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    CalendarLoadRequested event,
    Emitter<CalendarState> emit,
  ) async {
    emit(const CalendarLoadInProgress());
    try {
      _currentUserId = event.userId;
      _allTasks = await _repository.getByUser(event.userId);

      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month);
      final calendarDays = _generateCalendarDays(currentMonth, _allTasks);

      emit(
        CalendarLoadSuccess(
          calendarDays: calendarDays,
          currentMonth: currentMonth,
        ),
      );
    } catch (e) {
      emit(CalendarFailure(message: e.toString()));
    }
  }

  Future<void> _onMonthChanged(
    CalendarMonthChanged event,
    Emitter<CalendarState> emit,
  ) async {
    if (state is CalendarLoadSuccess) {
      final currentState = state as CalendarLoadSuccess;
      final calendarDays = _generateCalendarDays(event.month, _allTasks);

      emit(
        currentState.copyWith(
          calendarDays: calendarDays,
          currentMonth: event.month,
          selectedDate: null,
          selectedDateTasks: [],
        ),
      );
    }
  }

  Future<void> _onDateSelected(
    CalendarDateSelected event,
    Emitter<CalendarState> emit,
  ) async {
    if (state is CalendarLoadSuccess) {
      final currentState = state as CalendarLoadSuccess;
      final selectedDateTasks = _getTasksForDate(event.date, _allTasks);

      emit(
        currentState.copyWith(
          selectedDate: event.date,
          selectedDateTasks: selectedDateTasks,
        ),
      );
    }
  }

  Future<void> _onRefreshRequested(
    CalendarRefreshRequested event,
    Emitter<CalendarState> emit,
  ) async {
    if (state is CalendarLoadSuccess && _currentUserId != null) {
      try {
        _allTasks = await _repository.getByUser(_currentUserId!);
        final currentState = state as CalendarLoadSuccess;
        final calendarDays = _generateCalendarDays(
          currentState.currentMonth,
          _allTasks,
        );

        final selectedDateTasks = currentState.selectedDate != null
            ? _getTasksForDate(currentState.selectedDate!, _allTasks)
            : <TaskDto>[];

        emit(
          currentState.copyWith(
            calendarDays: calendarDays,
            selectedDateTasks: selectedDateTasks,
          ),
        );
      } catch (e) {
        emit(CalendarFailure(message: e.toString()));
      }
    }
  }

  List<CalendarDay> _generateCalendarDays(DateTime month, List<TaskDto> tasks) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);

    // Obtener el día de la semana del primer día (0 = domingo, 6 = sábado)
    final firstWeekday = firstDayOfMonth.weekday % 7;

    // Calcular días del mes anterior
    final previousMonthStart = firstDayOfMonth.subtract(
      Duration(days: firstWeekday),
    );

    // Generar días (6 semanas x 7 días = 42 días)
    final calendarDays = <CalendarDay>[];
    for (int i = 0; i < 42; i++) {
      final date = previousMonthStart.add(Duration(days: i));
      final isCurrentMonth = date.month == month.month;
      final tasksForDate = _getTasksForDate(date, tasks);

      calendarDays.add(
        CalendarDay(
          date: date,
          day: date.day,
          isCurrentMonth: isCurrentMonth,
          tasks: tasksForDate,
        ),
      );
    }

    return calendarDays;
  }

  List<TaskDto> _getTasksForDate(DateTime date, List<TaskDto> tasks) {
    final dateOnly = DateTime(date.year, date.month, date.day);

    return tasks.where((task) {
      try {
        final startDate = DateTime.parse(task.startDate);
        final endDate = DateTime.parse(task.endDate);

        final startDateOnly = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        );
        final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);

        return dateOnly.isAtSameMomentAs(startDateOnly) ||
            dateOnly.isAtSameMomentAs(endDateOnly) ||
            (dateOnly.isAfter(startDateOnly) && dateOnly.isBefore(endDateOnly));
      } catch (e) {
        return false;
      }
    }).toList();
  }
}
