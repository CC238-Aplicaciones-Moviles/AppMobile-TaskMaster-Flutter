import 'package:flutter/material.dart';
import '../../models/tasks/TaskDto.dart';

class ProjectStatistics extends StatelessWidget {
  final List<TaskDto> tasks;

  const ProjectStatistics({
    Key? key,
    required this.tasks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalTasks = tasks.length;
    final overdueTasks = _calculateOverdueTasks();
    final averageCompletionTime = _calculateAverageCompletionTime();
    final statusDistribution = _calculateStatusDistribution();
    final priorityDistribution = _calculatePriorityDistribution();

    final done = statusDistribution[TaskStatus.DONE] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tres tarjetas en fila
          Row(
            children: [
              Expanded(
                child: _buildSummaryTile(
                  title: 'Total',
                  subtitle: '$totalTasks tareas',
                  icon: Icons.assignment_outlined,
                  color: const Color(0xFF4B90E2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryTile(
                  title: 'Vencidas',
                  subtitle: '$overdueTasks tareas',
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFE05757),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryTile(
                  title: 'Velocidad',
                  subtitle: averageCompletionTime,
                  icon: Icons.speed,
                  color: const Color(0xFFB07BE6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'Estado de las tareas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Card grande para estado + dona
          Card(
            color: const Color(0xFFF4F4F4),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
              child: Row(
                children: [
                  // Leyenda a la izquierda
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusLegendItem(
                          'Por hacer',
                          statusDistribution[TaskStatus.TO_DO] ?? 0,
                          const Color(0xFF87201F),
                        ),
                        const SizedBox(height: 14),
                        _buildStatusLegendItem(
                          'En proceso',
                          statusDistribution[TaskStatus.IN_PROGRESS] ?? 0,
                          const Color(0xFFF5D76A),
                        ),
                        const SizedBox(height: 14),
                        _buildStatusLegendItem(
                          'Terminadas',
                          statusDistribution[TaskStatus.DONE] ?? 0,
                          const Color(0xFF7EDC8F),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Dona a la derecha
                  _buildDonutChart(
                    total: totalTasks,
                    done: done,
                    color: const Color(0xFF87201F),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Prioridad de las tareas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Card grande para prioridad
          Card(
            color: const Color(0xFFF4F4F4),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                children: [
                  // "Ejes" con barras (parecido al diseño)
                  SizedBox(
                    height: 150,
                    child: Stack(
                      children: [
                        // líneas horizontales (3, 2, 1)
                        Align(
                          alignment: Alignment.topLeft,
                          child: _buildPriorityLine(label: '3'),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _buildPriorityLine(label: '2'),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: _buildPriorityLine(label: '1'),
                        ),
                        // Barras de prioridad
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 30.0, right: 10.0),
                            child: _buildPriorityBars(priorityDistribution),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Etiquetas de prioridad en el eje X
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Alta'),
                      Text('Media'),
                      Text('Baja'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------- Cálculos ---------

  int _calculateOverdueTasks() {
    final now = DateTime.now();
    return tasks.where((task) {
      if (task.status == TaskStatus.DONE || task.status == TaskStatus.CANCELED) {
        return false;
      }
      try {
        final endDate = DateTime.parse(task.endDate);
        return endDate.isBefore(now);
      } catch (_) {
        return false;
      }
    }).length;
  }

  String _calculateAverageCompletionTime() {
    final doneTasks =
        tasks.where((task) => task.status == TaskStatus.DONE).toList();
    if (doneTasks.isEmpty) return 'N/A';

    int totalDurationInDays = 0;
    int count = 0;

    for (var task in doneTasks) {
      try {
        final start = DateTime.parse(task.startDate);
        final end = DateTime.parse(task.updatedAt);
        final duration = end.difference(start).inHours; // horas como en imagen
        if (duration >= 0) {
          totalDurationInDays += duration;
          count++;
        }
      } catch (_) {}
    }

    if (count == 0) return 'N/A';

    final average = totalDurationInDays / count;
    return '${average.toStringAsFixed(1)} h';
  }

  Map<TaskStatus, int> _calculateStatusDistribution() {
    final distribution = <TaskStatus, int>{
      TaskStatus.TO_DO: 0,
      TaskStatus.IN_PROGRESS: 0,
      TaskStatus.DONE: 0,
    };

    for (var task in tasks) {
      if (distribution.containsKey(task.status)) {
        distribution[task.status] = (distribution[task.status] ?? 0) + 1;
      }
    }
    return distribution;
  }

  Map<TaskPriority, int> _calculatePriorityDistribution() {
    final distribution = <TaskPriority, int>{
      TaskPriority.HIGH: 0,
      TaskPriority.MEDIUM: 0,
      TaskPriority.LOW: 0,
    };

    for (var task in tasks) {
      if (distribution.containsKey(task.priority)) {
        distribution[task.priority] = (distribution[task.priority] ?? 0) + 1;
      }
    }
    return distribution;
  }

  // --------- Widgets de UI ---------

  Widget _buildSummaryTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusLegendItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$label\n$count tareas',
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildDonutChart({
    required int total,
    required int done,
    required Color color,
  }) {
    final value = total == 0 ? 0.0 : done / total;
    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 16,
              valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.25)),
            ),
          ),
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 16,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              backgroundColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityLine({required String label}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              height: 1,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBars(Map<TaskPriority, int> distribution) {
    final maxCount =
        distribution.values.fold<int>(0, (prev, curr) => curr > prev ? curr : prev);
    final high = distribution[TaskPriority.HIGH] ?? 0;
    final medium = distribution[TaskPriority.MEDIUM] ?? 0;
    final low = distribution[TaskPriority.LOW] ?? 0;

    double _height(int count) =>
        maxCount == 0 ? 0 : (count / maxCount) * 90.0; // altura en px

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _priorityBar(_height(high), const Color(0xFFE05757)),
        _priorityBar(_height(medium), const Color(0xFFB07BE6)),
        _priorityBar(_height(low), const Color(0xFF7EDC8F)),
      ],
    );
  }

  Widget _priorityBar(double height, Color color) {
    final h = height == 0 ? 4.0 : height;
    return Container(
      width: 26,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      ),
    );
  }
}
