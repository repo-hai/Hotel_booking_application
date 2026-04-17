class Payment {
  final String id;
  final int total;
  final DateTime createdAt;
  final String method;
  final String status;

  Payment({
    required this.id,
    required this.total,
    required this.createdAt,
    required this.method,
    required this.status,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json['id']?.toString() ?? '',
    total: json['total'] ?? json['amount'] ?? 0,
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    method: json['method'] ?? 'Thanh toán trực tuyến',
    status: json['status'] ?? 'Completed',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'total': total,
    'createdAt': createdAt.toIso8601String(),
    'method': method,
    'status': status,
  };
}