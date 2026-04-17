import 'package:hotel_booking_app/models/user.dart';

class Customer extends User{

  String membershipLevel;
  int point;
  int totalSpent;

  Customer(this.membershipLevel, this.point, this.totalSpent) : super(0, '', '', '', '', '', '', DateTime.now(), '');
}