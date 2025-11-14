class SignUpRequest {
  final String name;
  final String lastName;
  final String email;
  final String password;
  final List<String> roles;

  SignUpRequest({
    required this.name,
    required this.lastName,
    required this.email,
    required this.password,
    required this.roles,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'lastName': lastName,
    'email': email,
    'password': password,
    'roles': roles,
  };
}
