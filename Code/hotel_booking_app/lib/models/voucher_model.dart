import 'package:flutter/material.dart';

enum VoucherStatus { active, expired, disabled }

enum DiscountType { percent, fixed }

class VoucherModel {
  final int id;
  String code;
  String name;
  DiscountType discountType;
  double discountValue;
  int maxDiscount;
  int minSpend;
  int usageLimit;
  int usedCount;
  DateTime startDate;
  DateTime endDate;
  String targetType;
  VoucherStatus status;

  VoucherModel({
    required this.id,
    required this.code,
    required this.name,
    required this.discountType,
    required this.discountValue,
    required this.maxDiscount,
    required this.minSpend,
    required this.usageLimit,
    required this.usedCount,
    required this.startDate,
    required this.endDate,
    required this.targetType,
    this.status = VoucherStatus.active,
  });

  String get statusLabel {
    switch (status) {
      case VoucherStatus.active:
        return 'Đang hoạt động';
      case VoucherStatus.expired:
        return 'Hết hạn';
      case VoucherStatus.disabled:
        return 'Đã tắt';
    }
  }

  Color get statusColor {
    switch (status) {
      case VoucherStatus.active:
        return const Color(0xFF43A047);
      case VoucherStatus.expired:
        return const Color(0xFFE53935);
      case VoucherStatus.disabled:
        return const Color(0xFF6B7280);
    }
  }

  String get discountLabel {
    if (discountType == DiscountType.percent) {
      return '-${discountValue.toInt()}%';
    }
    return '-${_formatNumber(discountValue.toInt())}đ';
  }

  String get formattedMaxDiscount => '${_formatNumber(maxDiscount)}đ';
  String get formattedMinSpend => '${_formatNumber(minSpend)}đ';

  String get usageText => '$usedCount/$usageLimit';

  double get usagePercent =>
      usageLimit > 0 ? usedCount / usageLimit : 0;

  bool get isActive => status == VoucherStatus.active;

  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
}

class MockVouchers {
  static final List<VoucherModel> all = [
    VoucherModel(
      id: 1,
      code: 'SUMMER2026',
      name: 'Khuyến mãi Hè 2026',
      discountType: DiscountType.percent,
      discountValue: 20,
      maxDiscount: 500000,
      minSpend: 1000000,
      usageLimit: 500,
      usedCount: 324,
      startDate: DateTime(2026, 5, 1),
      endDate: DateTime(2026, 8, 31),
      targetType: 'Tất cả',
      status: VoucherStatus.active,
    ),
    VoucherModel(
      id: 2,
      code: 'NEWUSER50K',
      name: 'Ưu đãi người dùng mới',
      discountType: DiscountType.fixed,
      discountValue: 50000,
      maxDiscount: 50000,
      minSpend: 300000,
      usageLimit: 1000,
      usedCount: 756,
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 12, 31),
      targetType: 'Người dùng mới',
      status: VoucherStatus.active,
    ),
    VoucherModel(
      id: 3,
      code: 'TET2026',
      name: 'Mừng Tết Nguyên Đán',
      discountType: DiscountType.percent,
      discountValue: 30,
      maxDiscount: 800000,
      minSpend: 2000000,
      usageLimit: 200,
      usedCount: 200,
      startDate: DateTime(2026, 1, 20),
      endDate: DateTime(2026, 2, 15),
      targetType: 'Tất cả',
      status: VoucherStatus.expired,
    ),
    VoucherModel(
      id: 4,
      code: 'WEEKEND15',
      name: 'Cuối tuần vui vẻ',
      discountType: DiscountType.percent,
      discountValue: 15,
      maxDiscount: 300000,
      minSpend: 500000,
      usageLimit: 300,
      usedCount: 89,
      startDate: DateTime(2026, 3, 1),
      endDate: DateTime(2026, 6, 30),
      targetType: 'Tất cả',
      status: VoucherStatus.disabled,
    ),
    VoucherModel(
      id: 5,
      code: 'VIP100K',
      name: 'Ưu đãi VIP Member',
      discountType: DiscountType.fixed,
      discountValue: 100000,
      maxDiscount: 100000,
      minSpend: 800000,
      usageLimit: 150,
      usedCount: 42,
      startDate: DateTime(2026, 4, 1),
      endDate: DateTime(2026, 9, 30),
      targetType: 'VIP',
      status: VoucherStatus.active,
    ),
  ];
}
