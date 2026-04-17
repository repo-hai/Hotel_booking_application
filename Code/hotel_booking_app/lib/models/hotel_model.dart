import 'package:flutter/material.dart';

class HotelImage {
  final int id;
  final String url;
  HotelImage({required this.id, required this.url});

  factory HotelImage.fromJson(Map<String, dynamic> j) => HotelImage(
        id: (j['ID'] ?? 0) is int ? j['ID'] as int : int.tryParse('${j['ID']}') ?? 0,
        url: (j['url'] ?? '') as String,
      );
}

class HotelAmenity {
  final int id;
  final String name;
  final String icon;
  HotelAmenity({required this.id, required this.name, required this.icon});

  factory HotelAmenity.fromJson(Map<String, dynamic> j) => HotelAmenity(
        id: (j['ID'] ?? 0) is int ? j['ID'] as int : int.tryParse('${j['ID']}') ?? 0,
        name: (j['name'] ?? '') as String,
        icon: (j['icon'] ?? '') as String,
      );
}

class RoomPolicy {
  final int id;
  final String name;
  RoomPolicy({required this.id, required this.name});

  factory RoomPolicy.fromJson(Map<String, dynamic> j) => RoomPolicy(
        id: (j['ID'] ?? 0) is int ? j['ID'] as int : 0,
        name: (j['name'] ?? '') as String,
      );
}

class PhysicalRoom {
  final int id;
  final String roomNumber;
  final String status;
  PhysicalRoom({required this.id, required this.roomNumber, required this.status});

  factory PhysicalRoom.fromJson(Map<String, dynamic> j) => PhysicalRoom(
        id: (j['ID'] ?? 0) is int ? j['ID'] as int : 0,
        roomNumber: (j['roomNumber'] ?? '') as String,
        status: (j['status'] ?? '') as String,
      );
}

class HotelRoomType {
  final String id;
  final int hotelID;
  final String name;
  final double area;
  final int price;
  final String description;
  final String bedType;
  final int capacity;
  final int bedNum;
  final List<HotelImage> images;
  final List<RoomPolicy> policies;
  final List<HotelAmenity> amenities;
  final List<PhysicalRoom> rooms;

  HotelRoomType({
    required this.id,
    required this.hotelID,
    required this.name,
    required this.area,
    required this.price,
    required this.description,
    required this.bedType,
    required this.capacity,
    required this.bedNum,
    required this.images,
    required this.policies,
    required this.amenities,
    required this.rooms,
  });

  factory HotelRoomType.fromJson(Map<String, dynamic> j) => HotelRoomType(
        id: (j['id'] ?? j['ID'] ?? '').toString(),
        hotelID: _toInt(j['hotelID']),
        name: (j['name'] ?? '') as String,
        area: _toDouble(j['area']),
        price: _toInt(j['price']),
        description: (j['description'] ?? '') as String,
        bedType: (j['bedType'] ?? '') as String,
        capacity: _toInt(j['capacity']),
        bedNum: _toInt(j['bedNum']),
        images: _parseList(j['images'], (e) => HotelImage.fromJson(Map<String, dynamic>.from(e))),
        policies: _parseList(j['policies'], (e) => RoomPolicy.fromJson(Map<String, dynamic>.from(e))),
        amenities: _parseList(j['amenities'], (e) => HotelAmenity.fromJson(Map<String, dynamic>.from(e))),
        rooms: _parseList(j['rooms'], (e) => PhysicalRoom.fromJson(Map<String, dynamic>.from(e))),
      );

  int get availableRoomCount => rooms.where((r) => r.status == 'Available').length;

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? 0.0;
  }

  static List<T> _parseList<T>(dynamic raw, T Function(Map) mapper) {
    if (raw is! List) return [];
    return raw.whereType<Map>().map(mapper).toList();
  }
}

class HotelModel {
  final String id;
  final int hotelNumericId;
  final String type;
  final String name;
  final String description;
  final String telephone;
  final String location;
  final String email;
  final int star;
  final List<HotelImage> images;
  final List<HotelAmenity> amenities;
  final List<HotelRoomType> rooms;

  HotelModel({
    required this.id,
    required this.hotelNumericId,
    required this.type,
    required this.name,
    required this.description,
    required this.telephone,
    required this.location,
    required this.email,
    required this.star,
    required this.images,
    required this.amenities,
    required this.rooms,
  });

  factory HotelModel.fromJson(Map<String, dynamic> j) {
    return HotelModel(
      id: (j['id'] ?? j['ID'] ?? '').toString(),
      hotelNumericId: _toInt(j['ID']),
      type: (j['type'] ?? '') as String,
      name: (j['name'] ?? '') as String,
      description: (j['description'] ?? '') as String,
      telephone: (j['telephone'] ?? '') as String,
      location: (j['location'] ?? '') as String,
      email: (j['email'] ?? '') as String,
      star: _toInt(j['star']),
      images: _parseList(j['images'], (e) => HotelImage.fromJson(Map<String, dynamic>.from(e))),
      amenities: _parseList(j['amenities'], (e) => HotelAmenity.fromJson(Map<String, dynamic>.from(e))),
      rooms: _parseList(j['rooms'], (e) => HotelRoomType.fromJson(Map<String, dynamic>.from(e))),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? 0;
  }

  static List<T> _parseList<T>(dynamic raw, T Function(Map) mapper) {
    if (raw is! List) return [];
    return raw.whereType<Map>().map(mapper).toList();
  }

  String? get firstImageUrl => images.isNotEmpty ? images.first.url : null;

  int? get minRoomPrice {
    if (rooms.isEmpty) return null;
    return rooms.map((r) => r.price).reduce((a, b) => a < b ? a : b);
  }

  String get formattedMinPrice {
    final p = minRoomPrice;
    if (p == null) return 'Chưa có giá';
    return '${_formatNumber(p)}đ / đêm';
  }

  Color get accentColor {
    const palette = [
      Color(0xFF00838F),
      Color(0xFFC62828),
      Color(0xFF4527A0),
      Color(0xFF1565C0),
      Color(0xFFE65100),
    ];
    if (id.isEmpty) return palette.first;
    return palette[id.hashCode.abs() % palette.length];
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
