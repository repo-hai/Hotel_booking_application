import 'package:flutter/material.dart';

enum UserRole { admin, owner, user }

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final UserRole role;
  final String location;
  final String gender;
  final String? dateOfBirth;
  final String? membershipLevel;
  final int point;
  final int totalSpent;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.location,
    required this.gender,
    this.dateOfBirth,
    this.membershipLevel,
    this.point = 0,
    this.totalSpent = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) {
    return UserModel(
      id: (j['id'] ?? '').toString(),
      name: (j['name'] ?? '') as String,
      phone: (j['phone'] ?? '') as String,
      email: (j['email'] ?? '') as String,
      role: _parseRole(j['role']),
      location: (j['location'] ?? '') as String,
      gender: (j['gender'] ?? '') as String,
      dateOfBirth: j['dateOfBirth'] as String?,
      membershipLevel: j['membershipLevel'] as String?,
      point: _toInt(j['point']),
      totalSpent: _toInt(j['totalSpent']),
    );
  }

  static UserRole _parseRole(dynamic v) {
    final s = (v ?? 'user').toString().toLowerCase();
    switch (s) {
      case 'admin':
        return UserRole.admin;
      case 'owner':
        return UserRole.owner;
      default:
        return UserRole.user;
    }
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? 0;
  }

  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return trimmed.length >= 2
        ? trimmed.substring(0, 2).toUpperCase()
        : trimmed.toUpperCase();
  }

  String get roleLabel {
    switch (role) {
      case UserRole.admin:
        return 'Quản trị viên';
      case UserRole.owner:
        return 'Chủ khách sạn (Owner)';
      case UserRole.user:
        return 'Khách hàng (User)';
    }
  }

  String get membershipLabel => membershipLevel ?? 'Chưa có';

  String get formattedTotalSpent {
    if (totalSpent == 0) return '0đ';
    return '${_formatNumber(totalSpent)}đ';
  }

  static String _formatNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  Color get avatarColor {
    const palette = [
      Color(0xFF1565C0),
      Color(0xFF2E7D32),
      Color(0xFF7B1FA2),
      Color(0xFFE65100),
      Color(0xFF00838F),
      Color(0xFFC62828),
      Color(0xFF4527A0),
    ];
    if (id.isEmpty) return palette.first;
    return palette[id.hashCode.abs() % palette.length];
  }
}
