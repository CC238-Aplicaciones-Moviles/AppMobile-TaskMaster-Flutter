
class ProjectCreateRequest {
  final String name;
  final String description;
  final String? imageUrl;
  final double budget;
  final String endDate;

  ProjectCreateRequest({
    required this.name,
    required this.description,
    this.imageUrl,
    required this.budget,
    required this.endDate,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'budget': budget,
    'endDate': endDate,
  };
}

class ProjectUpdateRequest {
  final String name;
  final String description;
  final String imageUrl;
  final double budget;
  final String status;
  final String endDate;

  ProjectUpdateRequest({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.budget,
    required this.status,
    required this.endDate,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'budget': budget,
    'status': status,
    'endDate': endDate,
  };
}

class ProjectCodeRequest {
  final String code;

  ProjectCodeRequest(this.code);

  Map<String, dynamic> toJson() => {'code': code};
}
