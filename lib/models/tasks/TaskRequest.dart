
class TaskCreateRequest {
  final int projectId;
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final String status;
  final String priority;
  final List<int> assignedUserIds;

  TaskCreateRequest({
    required this.projectId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.priority,
    required this.assignedUserIds,
  });

  Map<String, dynamic> toJson() => {
    'projectId': projectId,
    'title': title,
    'description': description,
    'startDate': startDate,
    'endDate': endDate,
    'status': status,
    'priority': priority,
    'assignedUserIds': assignedUserIds,
  };
}

class TaskUpdateRequest {
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final String priority;
  final String status;

  TaskUpdateRequest({
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.priority,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'startDate': startDate,
    'endDate': endDate,
    'priority': priority,
    'status': status,
  };
}

class TaskAssignRequest {
  final int userId;

  TaskAssignRequest(this.userId);

  Map<String, dynamic> toJson() => {
    'userId': userId,
  };
}

class TaskStatusUpdateRequest {
  final String status;

  TaskStatusUpdateRequest(this.status);

  Map<String, dynamic> toJson() => {
    'status': status,
  };
}
