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

class PolicyModel {
  final String name;

  PolicyModel({required this.name});

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    return PolicyModel(name: json['name'] ?? '');
  }
}

class RoomTypeModel {
  final String id;
  final String hotelId;
  final String name;
  final double price;
  final int capacity;
  final List<String> images;
  final int area;
  final String bedType;
  final int bedNum;
  final String description;
  final List<PolicyModel> policies;
  final List<AmenityModel> amenities;
  final List<Map<String, dynamic>> rooms; // phòng vật lý [{ID, roomNumber, status}]

  RoomTypeModel({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.price,
    required this.capacity,
    required this.images,
    this.area = 0,
    this.bedType = '',
    this.bedNum = 1,
    this.description = '',
    this.policies = const [],
    this.amenities = const [],
    this.rooms = const [],
  });

  factory RoomTypeModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'] as List<dynamic>? ?? [];
    final imageUrls = rawImages.map((img) {
      if (img is String) return img;
      if (img is Map) return (img['url'] ?? '') as String;
      return '';
    }).where((s) => s.isNotEmpty).toList();

    final policiesRaw = json['policies'] as List<dynamic>? ?? [];
    final amenitiesRaw = json['amenities'] as List<dynamic>? ?? [];
    final roomsRaw = json['rooms'] as List<dynamic>? ?? [];

    return RoomTypeModel(
      id: json['id']?.toString() ?? '',
      hotelId: json['hotelId']?.toString() ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      capacity: (json['capacity'] as num?)?.toInt() ?? 1,
      images: imageUrls,
      area: (json['area'] as num?)?.toInt() ?? 0,
      bedType: json['bedType'] ?? '',
      bedNum: (json['bedNum'] as num?)?.toInt() ?? 1,
      description: json['description'] ?? '',
      policies: policiesRaw
          .map((e) => PolicyModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      amenities: amenitiesRaw
          .map((e) => AmenityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      rooms: roomsRaw
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }
}

class HotelModel {
  final String id;
  final String name;
  final String city;       // location hoặc city
  final String address;
  final String type;
  final String description;
  final String telephone;
  final String email;
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
    this.type = '',
    this.description = '',
    this.telephone = '',
    this.email = '',
    required this.star,
    required this.images,
    this.amenities = const [],
    this.rooms = const [],
    this.minRoomPrice,
    this.rating,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    final amenitiesRaw = json['amenities'] as List<dynamic>? ?? [];
    // Đọc rooms từ cả 'rooms' lẫn 'availableRoomTypes' (từ search API)
    final roomsRaw = (json['rooms'] as List<dynamic>?) ??
        (json['availableRoomTypes'] as List<dynamic>?) ??
        [];

    // images: backend đã normalize thành [string]
    final rawImages = json['images'] as List<dynamic>? ?? [];
    final imageUrls = rawImages.map((img) {
      if (img is String) return img;
      if (img is Map) return (img['url'] ?? '') as String;
      return '';
    }).where((s) => s.isNotEmpty).toList();

    return HotelModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      city: json['city'] ?? json['location'] ?? '',
      address: json['address'] ?? json['city'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      telephone: json['telephone'] ?? '',
      email: json['email'] ?? '',
      star: (json['star'] as num?)?.toInt() ?? 0,
      images: imageUrls,
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
