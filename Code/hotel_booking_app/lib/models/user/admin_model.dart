import 'user_model.dart';

class Admin extends User {
  Admin({
    super.id,
    required super.email,
    required super.password,
    required super.phone,
    required super.name,
    required super.location,
    required super.gender,
    required super.dateOfBirth,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    final user = User.fromJson(json);
    return Admin(
      id: user.id,
      email: user.email,
      password: user.password,
      phone: user.phone,
      name: user.name,
      location: user.location,
      gender: user.gender,
      dateOfBirth: user.dateOfBirth,
    );
  }
}