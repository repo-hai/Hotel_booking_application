class VoucherModel {
  final String id;
  final String code;
  final String discountType; // Percentage | Fixed
  final double value;        // 0.03 = 3% hoặc 50000 VND
  final double maxDiscountValue;
  final double minSpend;
  final String targetType;
  final String? startDate;
  final String? endDate;
  final int usageLimit;
  final int usedCount;
  final double discountAmount; // Số tiền giảm thực tế (tính sẵn từ backend)

  VoucherModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.value,
    required this.maxDiscountValue,
    required this.minSpend,
    required this.targetType,
    this.startDate,
    this.endDate,
    required this.usageLimit,
    required this.usedCount,
    required this.discountAmount,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      discountType: json['discountType'] ?? 'Percentage',
      value: (json['value'] as num?)?.toDouble() ?? 0,
      maxDiscountValue: (json['maxDiscountValue'] as num?)?.toDouble() ?? 0,
      minSpend: (json['minSpend'] as num?)?.toDouble() ?? 0,
      targetType: json['targetType'] ?? 'all',
      startDate: json['startDate'],
      endDate: json['endDate'],
      usageLimit: (json['usageLimit'] as num?)?.toInt() ?? 0,
      usedCount: (json['usedCount'] as num?)?.toInt() ?? 0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Mô tả giảm giá ngắn gọn
  String get discountLabel {
    if (discountType == 'Percentage') {
      final pct = (value * 100).toStringAsFixed(0);
      if (maxDiscountValue > 0) {
        return 'Giảm $pct% (tối đa ${_fmt(maxDiscountValue)} VND)';
      }
      return 'Giảm $pct%';
    }
    return 'Giảm ${_fmt(value)} VND';
  }

  String _fmt(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (c > 0 && c % 3 == 0) buf.write('.');
      buf.write(s[i]);
      c++;
    }
    return buf.toString().split('').reversed.join();
  }
}
