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
    print('📅 CalendarBloc: Iniciando carga con userId=${event.userId}');
    emit(const CalendarLoadInProgress());
    try {
      _currentUserId = event.userId;
      
      // Validar userId
      if (event.userId <= 0) {
        print('❌ CalendarBloc: UserId inválido (${event.userId})');
        emit(const CalendarFailure(
          message: 'No se pudo obtener el ID del usuario. Por favor, inicia sesión nuevamente.',
        ));
        return;
      }
      
      print('📅 CalendarBloc: Llamando API getByUser para userId=$_currentUserId');
      _allTasks = await _repository.getByUser(event.userId);
      print('✅ CalendarBloc: ${_allTasks.length} tareas obtenidas exitosamente');
      
      if (_allTasks.isNotEmpty) {
        print('📋 Primera tarea: "${_allTasks[0].title}" (${_allTasks[0].startDate} - ${_allTasks[0].endDate})');
      }

      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month);
      print('📅 CalendarBloc: Generando calendario para mes: ${currentMonth.year}-${currentMonth.month}');
      final calendarDays = _generateCalendarDays(currentMonth, _allTasks);
      
      print('✅ CalendarBloc: Calendario generado con ${calendarDays.length} días');
      final daysWithTasks = calendarDays.where((d) => d.tasks.isNotEmpty).length;
      print('📊 CalendarBloc: $daysWithTasks días tienen tareas asignadas');

      emit(
        CalendarLoadSuccess(
          calendarDays: calendarDays,
          currentMonth: currentMonth,
        ),
      );
      print('✅ CalendarBloc: Estado CalendarLoadSuccess emitido exitosamente');
    } catch (e, stackTrace) {
      print('❌ CalendarBloc Error: $e');
      print('❌ Stack trace: $stackTrace');
      emit(CalendarFailure(message: 'Error al cargar el calendario: ${e.toString()}'));
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

    final matchingTasks = tasks.where((task) {
      try {
        final startDate = DateTime.parse(task.startDate);
        final endDate = DateTime.parse(task.endDate);

        final startDateOnly = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        );
        final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);

        // Solo coincide si es la fecha de inicio O la fecha de fin
        final matches = dateOnly.isAtSameMomentAs(startDateOnly) ||
            dateOnly.isAtSameMomentAs(endDateOnly);
        
        if (matches) {
          print('✅ Tarea "${task.title}" coincide con fecha ${dateOnly.year}-${dateOnly.month}-${dateOnly.day}');
        }
        
        return matches;
      } catch (e) {
        print('⚠️ Error al parsear fechas de tarea: $e');
        return false;
      }
    }).toList();
    
    print('📅 Tareas para ${dateOnly.year}-${dateOnly.month}-${dateOnly.day}: ${matchingTasks.length}');
    return matchingTasks;
  }
}
