import 'package:flutter/material.dart';

enum UserType { customer, owner }

enum UserStatus { active, locked }

class UserModel {
  final int id;
  final String name;
  final String phone;
  final String email;
  final UserType type;
  UserStatus status;
  final DateTime joinDate;
  final Color avatarColor;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.type,
    required this.status,
    required this.joinDate,
    required this.avatarColor,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  String get typeLabel =>
      type == UserType.customer ? 'Khách hàng (User)' : 'Chủ nhà (Owner)';

  String get statusLabel =>
      status == UserStatus.active ? 'Đang hoạt động' : 'Đã khóa';

  bool get isActive => status == UserStatus.active;
}

class MockUsers {
  static final List<UserModel> customers = [
    UserModel(
      id: 1,
      name: 'Trần Anh Tuấn',
      phone: '0904 123 456',
      email: 'tuan.tran@example.com',
      type: UserType.customer,
      status: UserStatus.active,
      joinDate: DateTime(2025, 5, 12),
      avatarColor: const Color(0xFF1565C0),
    ),
    UserModel(
      id: 2,
      name: 'Lê Thanh Hoa',
      phone: '0988 765 432',
      email: 'hoa.le@example.com',
      type: UserType.customer,
      status: UserStatus.active,
      joinDate: DateTime(2025, 6, 20),
      avatarColor: const Color(0xFF2E7D32),
    ),
    UserModel(
      id: 3,
      name: 'Phạm Văn Hùng',
      phone: '0912 345 678',
      email: 'hung.pham@example.com',
      type: UserType.customer,
      status: UserStatus.locked,
      joinDate: DateTime(2025, 3, 8),
      avatarColor: const Color(0xFF7B1FA2),
    ),
    UserModel(
      id: 4,
      name: 'Đỗ Minh Trang',
      phone: '0933 111 222',
      email: 'trang.do@example.com',
      type: UserType.customer,
      status: UserStatus.active,
      joinDate: DateTime(2025, 8, 15),
      avatarColor: const Color(0xFFE65100),
    ),
  ];

  static final List<UserModel> owners = [
    UserModel(
      id: 5,
      name: 'Nguyễn Văn A',
      phone: '0901 222 333',
      email: 'a.nguyen@example.com',
      type: UserType.owner,
      status: UserStatus.active,
      joinDate: DateTime(2025, 1, 10),
      avatarColor: const Color(0xFF00838F),
    ),
    UserModel(
      id: 6,
      name: 'Trần Thị B',
      phone: '0977 444 555',
      email: 'b.tran@example.com',
      type: UserType.owner,
      status: UserStatus.active,
      joinDate: DateTime(2025, 4, 22),
      avatarColor: const Color(0xFFC62828),
    ),
    UserModel(
      id: 7,
      name: 'Hoàng Minh Đức',
      phone: '0966 777 888',
      email: 'duc.hoang@example.com',
      type: UserType.owner,
      status: UserStatus.locked,
      joinDate: DateTime(2025, 2, 5),
      avatarColor: const Color(0xFF4527A0),
    ),
  ];
}
