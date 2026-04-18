import 'room_amenity_model.dart';
import 'room_image_model.dart';
import 'room_model.dart';

class RoomType {
  final String id;
  final String hotelId;
  final String name;
  final double area;
  final int price;
  final String description;
  final String bedType;
  final int capacity;
  final int bedNum;
  final String cancellationPolicy;
  
  // Quan hệ 1..* từ sơ đồ
  final List<RoomAmenity> amenities;
  final List<RoomImage> images;
  final List<Room> rooms;

  RoomType({
    required this.id,
    this.hotelId = "",
    required this.name,
    required this.area,
    required this.price,
    required this.description,
    required this.bedType,
    required this.capacity,
    required this.bedNum,
    this.cancellationPolicy = "Không thể hoàn trả",
    this.amenities = const [],
    this.images = const [],
    this.rooms = const [],
  });

  factory RoomType.fromJson(Map<String, dynamic> json) {
    return RoomType(
      id: (json['id'] ?? json['ID'])?.toString() ?? '',
      hotelId: (json['hotelId'] ?? json['hotelID'])?.toString() ?? '',
      name: json['name'] ?? '',
      area: (json['area'] as num?)?.toDouble() ?? 0.0,
      price: json['price'] is int ? json['price'] : int.tryParse(json['price']?.toString() ?? '0') ?? 0,
      description: json['description'] ?? '',
      bedType: json['bedType'] ?? '',
      capacity: json['capacity'] is int ? json['capacity'] : int.tryParse(json['capacity']?.toString() ?? '0') ?? 0,
      bedNum: json['bedNum'] ?? 0,
      cancellationPolicy: json['cancellationPolicy'] 
          ?? (json['policies'] is List && (json['policies'] as List).isNotEmpty 
              ? (json['policies'] as List)[0]['name'] 
              : 'Không thể hoàn trả'),
      // Map list amenities (Hỗ trợ cả List<String> từ Firestore và List<Map> cũ)
      amenities: (json['amenities'] as List? ?? [])
          .map((e) {
            if (e is String) return RoomAmenity(id: '', name: e, icon: '');
            return RoomAmenity.fromJson(e);
          }).toList(),
      // Map list images (Hỗ trợ cả List<String> từ Firestore và List<Map> cũ)
      images: (json['images'] as List? ?? [])
          .map((e) {
            if (e is String) return RoomImage(id: '', url: e);
            return RoomImage.fromJson(e);
          }).toList(),
      rooms: (json['rooms'] as List? ?? [])
          .map((e) => Room.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': int.tryParse(id) ?? id,
      'hotelId': hotelId,
      'name': name,
      'area': area,
      'price': price,
      'description': description,
      'bedType': bedType,
      'capacity': capacity,
      'bedNum': bedNum,
      'cancellationPolicy': cancellationPolicy,
      'amenities': amenities.map((e) => e.toJson()).toList(),
      'images': images.map((e) => e.toJson()).toList(),
      'rooms': rooms.map((e) => e.toJson()).toList(),
    };
  }

  RoomType copyWith({
    String? id,
    String? hotelId,
    String? name,
    double? area,
    int? price,
    String? description,
    String? bedType,
    int? capacity,
    int? bedNum,
    String? cancellationPolicy,
    List<RoomAmenity>? amenities,
    List<RoomImage>? images,
    List<Room>? rooms,
  }) {
    return RoomType(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      name: name ?? this.name,
      area: area ?? this.area,
      price: price ?? this.price,
      description: description ?? this.description,
      bedType: bedType ?? this.bedType,
      capacity: capacity ?? this.capacity,
      bedNum: bedNum ?? this.bedNum,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      amenities: amenities ?? this.amenities,
      images: images ?? this.images,
      rooms: rooms ?? this.rooms,
    );
  }
}