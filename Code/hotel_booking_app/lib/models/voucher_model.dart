import 'package:flutter/material.dart';

enum VoucherStatus { active, expired, disabled }

enum DiscountType { percentage, fixed }

class VoucherModel {
  final String id;
  String code;
  DiscountType discountType;
  double value; // decimal: 0.05 = 5%, 0.25 = 25%
  int maxDiscountValue;
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
    required this.discountType,
    required this.value,
    required this.maxDiscountValue,
    required this.minSpend,
    required this.usageLimit,
    required this.usedCount,
    required this.startDate,
    required this.endDate,
    required this.targetType,
    this.status = VoucherStatus.active,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> j) {
    return VoucherModel(
      id: (j['id'] ?? '').toString(),
      code: (j['code'] ?? '') as String,
      discountType: _parseDiscountType(j['discountType']),
      value: _toDouble(j['value']),
      maxDiscountValue: _toInt(j['maxDiscountValue']),
      minSpend: _toInt(j['minSpend']),
      usageLimit: _toInt(j['usageLimit']),
      usedCount: _toInt(j['usedCount']),
      startDate: _parseDate(j['startDate']) ?? DateTime.now(),
      endDate: _parseDate(j['endDate']) ?? DateTime.now().add(const Duration(days: 30)),
      targetType: (j['targetType'] ?? 'all') as String,
      status: _parseStatus(j['status']),
    );
  }

  Map<String, dynamic> toRequestBody() {
    return {
      'code': code,
      'discountType': discountType == DiscountType.percentage ? 'Percentage' : 'Fixed',
      'value': value,
      'maxDiscountValue': maxDiscountValue,
      'minSpend': minSpend,
      'usageLimit': usageLimit,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'targetType': targetType,
      'status': _statusToString(status),
    };
  }

  static String _statusToString(VoucherStatus s) {
    switch (s) {
      case VoucherStatus.active:
        return 'Active';
      case VoucherStatus.expired:
        return 'Expired';
      case VoucherStatus.disabled:
        return 'Disabled';
    }
  }

  static DiscountType _parseDiscountType(dynamic v) {
    final s = (v ?? 'Percentage').toString().toLowerCase();
    return s == 'fixed' ? DiscountType.fixed : DiscountType.percentage;
  }

  static VoucherStatus _parseStatus(dynamic v) {
    final s = (v ?? 'Active').toString().toLowerCase();
    switch (s) {
      case 'expired':
        return VoucherStatus.expired;
      case 'disabled':
        return VoucherStatus.disabled;
      default:
        return VoucherStatus.active;
    }
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? 0.0;
  }

  // value is decimal (0.05 = 5%), display as percent int
  int get displayPercent => (value * 100).round();

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
    if (discountType == DiscountType.percentage) {
      return '-$displayPercent%';
    }
    return '-${_formatNumber(value.toInt())}đ';
  }

  String get formattedMaxDiscount => '${_formatNumber(maxDiscountValue)}đ';
  String get formattedMinSpend => '${_formatNumber(minSpend)}đ';

  String get usageText => '$usedCount/$usageLimit';

  double get usagePercent => usageLimit > 0 ? usedCount / usageLimit : 0;

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
