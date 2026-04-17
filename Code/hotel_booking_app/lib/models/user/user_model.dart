class User {
  final int? id;
  final String email;
  final String password;
  final String phone;
  final String name;
  final String location;
  final String gender;
  final DateTime dateOfBirth;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.phone,
    required this.name,
    required this.location,
    required this.gender,
    required this.dateOfBirth,
  });

  // Chuyển từ JSON (API) sang Object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      phone: json['phone'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : DateTime.now(),
    );
  }

  // Chuyển từ Object sang Map để gửi lên API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'phone': phone,
      'name': name,
      'location': location,
      'gender': gender,
      'dateOfBirth': dateOfBirth.toIso8601String(),
    };
  }
}