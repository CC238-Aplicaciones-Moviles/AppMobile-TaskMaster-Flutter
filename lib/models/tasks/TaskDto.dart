enum TaskStatus { TO_DO, IN_PROGRESS, DONE, CANCELED }
enum TaskPriority { LOW, MEDIUM, HIGH }

TaskStatus taskStatusFromString(String value) {
  return TaskStatus.values.firstWhere(
        (e) => e.name == value,
    orElse: () => TaskStatus.TO_DO,
  );
}

TaskPriority taskPriorityFromString(String value) {
  return TaskPriority.values.firstWhere(
        (e) => e.name == value,
    orElse: () => TaskPriority.MEDIUM,
  );
}

class TaskDto {
  final int id;
  final int taskId;
  final int projectId;
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final TaskStatus status;
  final TaskPriority priority;
  final List<int> assignedUserIds;
  final String createdAt;
  final String updatedAt;

  TaskDto({
    required this.id,
    required this.taskId,
    required this.projectId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.priority,
    required this.assignedUserIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskDto.fromJson(Map<String, dynamic> json) {
    return TaskDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      taskId: (json['taskId'] as num?)?.toInt() ?? 0,
      projectId: (json['projectId'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      status: taskStatusFromString(json['status'] as String? ?? 'TO_DO'),
      priority: taskPriorityFromString(json['priority'] as String? ?? 'MEDIUM'),
      assignedUserIds: (json['assignedUserIds'] as List?)
          ?.map((e) => (e as num?)?.toInt() ?? 0)
          .where((id) => id > 0)
          .toList() ?? [],
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }
}
