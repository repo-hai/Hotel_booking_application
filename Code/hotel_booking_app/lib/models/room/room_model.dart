class Room {
  final String id;
  final String roomNumber;
  final String status; // Ví dụ: 'Available', 'Booked', 'Maintenance'

  Room({required this.id, required this.roomNumber, required this.status});

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        id: (json['roomId'] ?? json['id'] ?? json['ID'] ?? '')?.toString() ?? '',
        roomNumber: (json['roomNumber'] ?? json['name'] ?? '')?.toString() ?? '',
        status: json['status'] ?? 'Available',
      );

  Map<String, dynamic> toJson() => {
        'roomId': id,
        'roomNumber': roomNumber,
        'status': status,
      };
}

class RoomStat {
  final int totalRoom;

  RoomStat({required this.totalRoom});

  factory RoomStat.fromJson(Map<String, dynamic> json) => RoomStat(
        totalRoom: json['totalRoom'] ?? 0,
      );
}