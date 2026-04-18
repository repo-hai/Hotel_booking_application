class HotelAmenity {
  final String id;
  final String name;
  final String icon; // Lưu tên icon hoặc URL icon

  HotelAmenity({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory HotelAmenity.fromJson(Map<String, dynamic> json) {
    return HotelAmenity(
      id: (json['ID'] ?? json['id'])?.toString() ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'ID': int.tryParse(id) ?? id,
    'name': name,
    'icon': icon,
  };
}