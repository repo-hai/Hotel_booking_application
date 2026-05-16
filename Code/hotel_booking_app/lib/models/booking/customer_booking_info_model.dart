class CustomerBookingInfo {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String country;
  final bool isDefault;

  CustomerBookingInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.country,
    this.isDefault = false,
  });

  factory CustomerBookingInfo.fromJson(Map<String, dynamic> json) => CustomerBookingInfo(
    id: json['id']?.toString() ?? '',
    name: json['name'] ?? json['customerName'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    country: json['country'] ?? '',
    isDefault: json['isDefault'] ?? false,
  );
}