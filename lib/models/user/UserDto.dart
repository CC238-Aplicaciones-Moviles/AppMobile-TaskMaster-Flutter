class UserDto {
  final int id;
  final String email;
  final List<String> roles;
  final String name;
  final String lastName;
  final String? imageUrl;
  final double? salary;
  final List<dynamic> projectIds;

  UserDto({
    required this.id,
    required this.email,
    required this.roles,
    required this.name,
    required this.lastName,
    this.imageUrl,
    this.salary,
    required this.projectIds,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as int,
      email: json['email'] as String,
      roles: (json['roles'] as List).cast<String>(),
      name: json['name'] as String,
      lastName: json['lastName'] as String,
      imageUrl: json['imageUrl'] as String?,
      salary: (json['salary'] as num?)?.toDouble(),
      projectIds: (json['projectIds'] as List?) ?? const [],
    );
  }
}
