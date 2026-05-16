class HotelStat {
  final int income;
  final DateTime startTime;
  final DateTime endTime;
  final String bestsellerRoom;
  final int totalBooking;

  HotelStat({
    required this.income,
    required this.startTime,
    required this.endTime,
    required this.bestsellerRoom,
    required this.totalBooking,
  });

  factory HotelStat.fromJson(Map<String, dynamic> json) {
    return HotelStat(
      income: json['income'] ?? 0,
      startTime: json['startTime'] != null 
          ? DateTime.parse(json['startTime']) 
          : DateTime.now(),
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime']) 
          : DateTime.now(),
      bestsellerRoom: json['bestsellerRoom'] ?? '',
      totalBooking: json['totalBooking'] ?? 0,
    );
  }
}