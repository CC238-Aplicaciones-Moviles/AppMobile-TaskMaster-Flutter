import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui' as ui;
import '../../bloc/Calendar/CalendarBloc.dart';
import '../../models/calendar/CalendarDay.dart';
import '../../models/tasks/TaskDto.dart';
import '../../sharedPreferences/TaskmasterPrefs.dart';
import 'package:intl/intl.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Offset? _tapPosition;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadCalendar();
  }

  Future<void> _loadCalendar() async {
    try {
      print('📅 Calendario: Obteniendo userId de SharedPreferences...');
      final userId = await TaskmasterPrefs().getUserId();
      print(
        '📅 Calendario: userId obtenido = $userId (tipo: ${userId.runtimeType})',
      );

      if (userId != null && userId > 0 && mounted) {
        print(
          '✅ Calendario: UserId válido ($userId), despachando evento CalendarLoadRequested',
        );
        context.read<CalendarBloc>().add(CalendarLoadRequested(userId));
      } else if (mounted) {
        print('❌ Calendario: UserId inválido (null o <= 0)');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, inicia sesión nuevamente'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ Error al cargar calendario: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: BlocBuilder<CalendarBloc, CalendarState>(
          builder: (context, state) {
            if (state is CalendarLoadInProgress) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CalendarFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar el calendario',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (state is CalendarLoadSuccess) {
              return Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _buildCalendarHeader(context, state),
                  const SizedBox(height: 8),
                  _buildWeekDaysHeader(context),
                  const SizedBox(height: 8),
                  _buildCalendarGrid(context, state),
                  const SizedBox(height: 16),
                  Expanded(child: _buildTasksList(context, state)),
                ],
              );
            }

            // Estado inicial - mostrar loading
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            'Calendario',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              context.read<CalendarBloc>().add(
                const CalendarRefreshRequested(),
              );
            },
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader(BuildContext context, CalendarLoadSuccess state) {
    final monthName = DateFormat(
      'MMMM yyyy',
      'es_ES',
    ).format(state.currentMonth);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              final previousMonth = DateTime(
                state.currentMonth.year,
                state.currentMonth.month - 1,
              );
              context.read<CalendarBloc>().add(
                CalendarMonthChanged(previousMonth),
              );
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            monthName[0].toUpperCase() + monthName.substring(1),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () {
              final nextMonth = DateTime(
                state.currentMonth.year,
                state.currentMonth.month + 1,
              );
              context.read<CalendarBloc>().add(CalendarMonthChanged(nextMonth));
            },
            icon: Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDaysHeader(BuildContext context) {
    const weekDays = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekDays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onBackground.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context, CalendarLoadSuccess state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AspectRatio(
        // En Compose usas .aspectRatio(1.2f)
        aspectRatio: 1.2,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            final cellWidth = width / 7;
            final cellHeight = height / 6;

            return GestureDetector(
              onTapDown: (details) {
                final localPosition = details.localPosition;

                final column = (localPosition.dx / cellWidth).floor();
                final row = (localPosition.dy / cellHeight).floor();
                final index = row * 7 + column;

                if (index >= 0 && index < state.calendarDays.length) {
                  setState(() {
                    _tapPosition = localPosition;
                  });
                  _animationController.forward(from: 0.0);

                  context.read<CalendarBloc>().add(
                    CalendarDateSelected(state.calendarDays[index].date),
                  );
                }
              },
              child: CustomPaint(
                painter: CalendarGridPainter(
                  calendarDays: state.calendarDays,
                  selectedDate: state.selectedDate,
                  primaryColor: Theme.of(
                    context,
                  ).colorScheme.primary, // RedWine600
                  textColor: Theme.of(
                    context,
                  ).colorScheme.onBackground, // Brownish900
                  tapPosition: _tapPosition,
                  animation: _animationController,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTasksList(BuildContext context, CalendarLoadSuccess state) {
    if (state.selectedDate == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Selecciona una fecha',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    final dateFormat = DateFormat('d \'de\' MMMM', 'es_ES');
    final formattedDate = dateFormat.format(state.selectedDate!);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Tareas para $formattedDate',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: state.selectedDateTasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 48,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay tareas programadas',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: state.selectedDateTasks.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildTaskItem(
                        context,
                        state.selectedDateTasks[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, TaskDto task) {
    // Colores por prioridad (equivalentes a AlertRed, PriorityYellow, PriorityGreen)
    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.HIGH:
        priorityColor = const Color(0xFFB00020);
        break;
      case TaskPriority.MEDIUM:
        priorityColor = const Color(0xFFFFA726);
        break;
      case TaskPriority.LOW:
        priorityColor = const Color(0xFF66BB6A);
        break;
    }

    // Colores por estado (similar a Compose)
    Color statusBg;
    String statusText;
    switch (task.status) {
      case TaskStatus.TO_DO:
        statusBg = const Color(0xFFA62424).withOpacity(0.2); // RedWine500 aprox
        statusText = 'Por hacer';
        break;
      case TaskStatus.IN_PROGRESS:
        statusBg = const Color(0xFFFFA726).withOpacity(0.3); // PriorityYellow
        statusText = 'En progreso';
        break;
      case TaskStatus.DONE:
        statusBg = const Color(0xFF66BB6A).withOpacity(0.3); // PriorityGreen
        statusText = 'Completada';
        break;
      case TaskStatus.CANCELED:
        statusBg = const Color(0xFFB00020).withOpacity(0.2); // AlertRed
        statusText = 'Cancelada';
        break;
    }

    final priorityBg = priorityColor.withOpacity(0.2);

    return Container(
      decoration: BoxDecoration(
        // Como el Card containerColor = priorityColor.copy(alpha = 0.1f)
        color: priorityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicador de prioridad (cuadradito redondeado, no círculo)
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  // Descripción (opcional)
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  // Chips de estado y prioridad
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusText,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: priorityBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          task.priority == TaskPriority.HIGH
                              ? 'Alta'
                              : task.priority == TaskPriority.MEDIUM
                              ? 'Media'
                              : 'Baja',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
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

class CalendarGridPainter extends CustomPainter {
  final List<CalendarDay> calendarDays;
  final DateTime? selectedDate;
  final Color primaryColor; // equivalente a RedWine600
  final Color textColor; // equivalente a Brownish900
  final Offset? tapPosition;
  final Animation<double> animation;

  CalendarGridPainter({
    required this.calendarDays,
    required this.selectedDate,
    required this.primaryColor,
    required this.textColor,
    this.tapPosition,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    const rows = 6;
    const columns = 7;
    final cellWidth = size.width / columns;
    final cellHeight = size.height / rows;

    // =========================
    // Animación de tap (radial, recortada a la celda) – como en Compose
    // =========================
    if (tapPosition != null && animation.value > 0) {
      final column = (tapPosition!.dx / cellWidth).floor();
      final row = (tapPosition!.dy / cellHeight).floor();

      final cellRect = Rect.fromLTWH(
        column * cellWidth,
        row * cellHeight,
        cellWidth,
        cellHeight,
      );

      final maxSide = cellWidth > cellHeight ? cellWidth : cellHeight;
      final radius = maxSide * 1.0 * animation.value;

      final gradient = RadialGradient(
        colors: [primaryColor.withOpacity(0.8), primaryColor.withOpacity(0.2)],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: tapPosition!, radius: radius),
        )
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.clipRRect(
        RRect.fromRectAndRadius(cellRect, const Radius.circular(12)),
      );
      canvas.drawCircle(tapPosition!, radius, paint);
      canvas.restore();
    }

    // =========================
    // Borde del calendario – grueso y redondeado (como Stroke(15f) en Compose)
    // =========================
    final borderPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4; // más grueso para imitar el 15f de Compose

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(25),
      ),
      borderPaint,
    );

    // =========================
    // Líneas de la grilla – horizontales y verticales
    // =========================
    final gridPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Horizontales
    for (int i = 1; i < rows; i++) {
      final dy = i * cellHeight;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }

    // Verticales
    for (int i = 1; i < columns; i++) {
      final dx = i * cellWidth;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), gridPaint);
    }

    // =========================
    // Días
    // =========================
    for (int i = 0; i < calendarDays.length && i < 42; i++) {
      final day = calendarDays[i];
      final column = i % columns;
      final row = i ~/ columns;

      final cellRect = Rect.fromLTWH(
        column * cellWidth,
        row * cellHeight,
        cellWidth,
        cellHeight,
      );

      final isSelected =
          selectedDate != null &&
          day.date.year == selectedDate!.year &&
          day.date.month == selectedDate!.month &&
          day.date.day == selectedDate!.day;

      // ===== Fondo día seleccionado (rect redondeado dentro de la celda) =====
      if (isSelected) {
        final selectedPaint = Paint()
          ..color = primaryColor
          ..style = PaintingStyle.fill;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            cellRect.deflate(8), // margen interno similar a +8f/-16f
            const Radius.circular(8),
          ),
          selectedPaint,
        );
      }

      // ===== Indicador de tareas (puntito en esquina superior derecha) =====
      if (day.tasks.isNotEmpty) {
        final highestPriority = day.tasks.fold<TaskPriority>(
          TaskPriority.LOW,
          (prev, task) =>
              task.priority.index > prev.index ? task.priority : prev,
        );

        Color indicatorColor;
        switch (highestPriority) {
          case TaskPriority.HIGH:
            indicatorColor = const Color(0xFFB00020); // AlertRed aprox
            break;
          case TaskPriority.MEDIUM:
            indicatorColor = const Color(0xFFFFA726); // PriorityYellow aprox
            break;
          case TaskPriority.LOW:
            indicatorColor = const Color(0xFF66BB6A); // PriorityGreen aprox
            break;
        }

        final indicatorPaint = Paint()
          ..color = indicatorColor
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(cellRect.right - 15, cellRect.top + 15),
          4,
          indicatorPaint,
        );
      }

      // ===== Color del número de día (misma lógica que Compose) =====
      Color dayTextColor;
      if (isSelected) {
        dayTextColor = Colors.white;
      } else if (!day.isCurrentMonth) {
        // RedWine500 con alpha 0.5
        dayTextColor = primaryColor.withOpacity(0.5);
      } else if (day.tasks.isNotEmpty) {
        // RedWine600
        dayTextColor = primaryColor;
      } else {
        // Brownish900
        dayTextColor = textColor;
      }

      final isBold = isSelected || day.tasks.isNotEmpty;

      // ===== Texto del día: arriba a la izquierda (no centrado) =====
      final textSpan = TextSpan(
        text: day.day.toString(),
        style: TextStyle(
          color: dayTextColor,
          fontSize: 14,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: ui.TextDirection.ltr,
      );

      textPainter.layout();

      final textOffset = Offset(cellRect.left + 15, cellRect.top + 15);

      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(CalendarGridPainter oldDelegate) {
    return oldDelegate.calendarDays != calendarDays ||
        oldDelegate.selectedDate != selectedDate ||
        oldDelegate.tapPosition != tapPosition;
  }
}
