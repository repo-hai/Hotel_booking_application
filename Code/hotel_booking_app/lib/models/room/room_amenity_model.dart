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
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
  };
}