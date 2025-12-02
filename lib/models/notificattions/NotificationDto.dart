import '../projects/ProjectDto.dart';

class NotificationDto {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String sentAt;
  final ProjectDto? project;

  NotificationDto({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.sentAt,
    this.project,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      title: json['title'] as String,
      message: json['message'] as String,
      sentAt: json['sentAt'] as String,
      project: json['project'] != null ? ProjectDto.fromJson(json['project'] as Map<String, dynamic>) : null,
    );
  }
}
