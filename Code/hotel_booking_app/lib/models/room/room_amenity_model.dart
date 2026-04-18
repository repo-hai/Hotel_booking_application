class RoomAmenity {
  final String id;
  final String name;
  final String icon;

  RoomAmenity({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory RoomAmenity.fromJson(Map<String, dynamic> json) {
    return RoomAmenity(
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