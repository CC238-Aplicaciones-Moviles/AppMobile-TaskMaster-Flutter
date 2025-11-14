class UserUpdateRequest {
  final String name;
  final String lastName;
  final String? imageUrl;
  final double? salary;

  UserUpdateRequest({
    required this.name,
    required this.lastName,
    this.imageUrl,
    this.salary,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'lastName': lastName,
    'imageUrl': imageUrl,
    'salary': salary,
  };
}
