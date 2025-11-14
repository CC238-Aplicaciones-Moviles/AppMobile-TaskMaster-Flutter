// lib/features/projects/data/models/project_dto.dart

class ProjectDto {
  final int id;
  final int projectId;
  final String key;
  final int leaderId;
  final String name;
  final String description;
  final String? imageUrl;
  final double budget;
  final String status;
  final String startDate;
  final String endDate;

  ProjectDto({
    required this.id,
    required this.projectId,
    required this.key,
    required this.leaderId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.budget,
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  factory ProjectDto.fromJson(Map<String, dynamic> json) {
    return ProjectDto(
      id: (json['id'] as num).toInt(),
      projectId: (json['projectId'] as num).toInt(),
      key: json['key'] as String,
      leaderId: (json['leaderId'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      budget: (json['budget'] as num).toDouble(),
      status: json['status'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
    );
  }
}
