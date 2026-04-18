import 'package:hotel_booking_app/models/user.dart';

class Admin extends User{
  Admin(super.id, super.email, super.password, super.phone, super.name, super.location, super.gender, super.dateOfBirth, super.role);
}