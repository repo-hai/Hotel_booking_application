/// Model chứa thông tin khách hàng khi đặt phòng
class BookingCustomerInfo {
  final String firstName;
  final String lastName;
  final String email;
  final String country;
  final String phone;
  final bool saveAsDefault;

  const BookingCustomerInfo({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.country = 'Việt Nam',
    this.phone = '',
    this.saveAsDefault = false,
  });

  BookingCustomerInfo copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? country,
    String? phone,
    bool? saveAsDefault,
  }) {
    return BookingCustomerInfo(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      saveAsDefault: saveAsDefault ?? this.saveAsDefault,
    );
  }

  bool get isValid =>
      firstName.trim().isNotEmpty &&
      lastName.trim().isNotEmpty &&
      email.trim().isNotEmpty &&
      email.contains('@') &&
      phone.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'country': country,
        'phone': phone,
      };
}
