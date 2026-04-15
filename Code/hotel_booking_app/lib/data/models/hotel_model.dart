class AmenityModel {
  final String name;
  final String icon;

  AmenityModel({required this.name, required this.icon});

  factory AmenityModel.fromJson(Map<String, dynamic> json) {
    return AmenityModel(
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
    );
  }
}

class RoomTypeModel {
  final String id;
  final String hotelId;
  final String name;
  final double price;
  final int capacity;
  final List<String> images;

  RoomTypeModel({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.price,
    required this.capacity,
    required this.images,
  });

  factory RoomTypeModel.fromJson(Map<String, dynamic> json) {
    return RoomTypeModel(
      id: json['id'] ?? '',
      hotelId: json['hotelId'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      capacity: json['capacity'] ?? 1,
      images: List<String>.from(json['images'] ?? []),
    );
  }
}

class HotelModel {
  final String id;
  final String name;
  final String city;
  final String address;
  final int star;
  final List<String> images;
  final List<AmenityModel> amenities;
  final List<RoomTypeModel> rooms;
  final double? minRoomPrice;
  final double? rating;

  HotelModel({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.star,
    required this.images,
    this.amenities = const [],
    this.rooms = const [],
    this.minRoomPrice,
    this.rating,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    final amenitiesRaw = json['amenities'] as List<dynamic>? ?? [];
    final roomsRaw = json['rooms'] as List<dynamic>? ?? [];

    return HotelModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      star: json['star'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
      amenities: amenitiesRaw
          .map((e) => AmenityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      rooms: roomsRaw
          .map((e) => RoomTypeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      minRoomPrice: (json['minRoomPrice'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }
}
