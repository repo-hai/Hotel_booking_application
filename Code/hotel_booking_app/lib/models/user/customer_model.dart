import 'user_model.dart';

class Customer extends User {
  final String membershipLevel;
  final int point;
  final int totalSpent;

  Customer({
    // Các thuộc tính kế thừa từ User
    super.id,
    required super.email,
    required super.password,
    required super.phone,
    required super.name,
    required super.location,
    required super.gender,
    required super.dateOfBirth,
    // Các thuộc tính riêng của Customer
    required this.membershipLevel,
    required this.point,
    required this.totalSpent,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    // Khởi tạo User trước để lấy các thông tin chung
    final user = User.fromJson(json);
    
    return Customer(
      id: user.id,
      email: user.email,
      password: user.password,
      phone: user.phone,
      name: user.name,
      location: user.location,
      gender: user.gender,
      dateOfBirth: user.dateOfBirth,
      // Lấy thông tin riêng của Customer
      membershipLevel: json['membershipLevel'] ?? 'Standard',
      point: json['point'] ?? 0,
      totalSpent: json['totalSpent'] ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    // Kết hợp map của User và map của Customer
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'membershipLevel': membershipLevel,
      'point': point,
      'totalSpent': totalSpent,
    });
    return data;
  }
}