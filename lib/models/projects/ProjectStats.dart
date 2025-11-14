
class ProjectStats {
  final int totalTasks;
  final int overdueTasks;
  final String bestMember;
  final String worstMember;
  final int todoTasks;
  final int inProgressTasks;
  final int doneTasks;
  final int highPriorityTasks;
  final int mediumPriorityTasks;
  final int lowPriorityTasks;
  final double budget;
  final double usedBudget;

  const ProjectStats({
    this.totalTasks = 0,
    this.overdueTasks = 0,
    this.bestMember = 'Ninguno',
    this.worstMember = 'Ninguno',
    this.todoTasks = 0,
    this.inProgressTasks = 0,
    this.doneTasks = 0,
    this.highPriorityTasks = 0,
    this.mediumPriorityTasks = 0,
    this.lowPriorityTasks = 0,
    this.budget = 0.0,
    this.usedBudget = 0.0,
  });

  ProjectStats copyWith({
    int? totalTasks,
    int? overdueTasks,
    String? bestMember,
    String? worstMember,
    int? todoTasks,
    int? inProgressTasks,
    int? doneTasks,
    int? highPriorityTasks,
    int? mediumPriorityTasks,
    int? lowPriorityTasks,
    double? budget,
    double? usedBudget,
  }) {
    return ProjectStats(
      totalTasks: totalTasks ?? this.totalTasks,
      overdueTasks: overdueTasks ?? this.overdueTasks,
      bestMember: bestMember ?? this.bestMember,
      worstMember: worstMember ?? this.worstMember,
      todoTasks: todoTasks ?? this.todoTasks,
      inProgressTasks: inProgressTasks ?? this.inProgressTasks,
      doneTasks: doneTasks ?? this.doneTasks,
      highPriorityTasks: highPriorityTasks ?? this.highPriorityTasks,
      mediumPriorityTasks: mediumPriorityTasks ?? this.mediumPriorityTasks,
      lowPriorityTasks: lowPriorityTasks ?? this.lowPriorityTasks,
      budget: budget ?? this.budget,
      usedBudget: usedBudget ?? this.usedBudget,
    );
  }
}
