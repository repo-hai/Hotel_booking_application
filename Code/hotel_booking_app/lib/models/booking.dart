class Booking {
  Booking(this.id, this.voucherUsageHistoryID, this.userID, this.checkin,
      this.checkout, this.total, this.bookedAt, this.cancellationReason,
      this.customerEmail, this.customerPhone, this.customerCountry,
      this.customerNmae, this.cancelledAt, this.cancelledBy, this.status);

  int id;
  int voucherUsageHistoryID;
  int userID;
  DateTime checkin;
  DateTime checkout;
  int total;
  DateTime bookedAt;
  String cancellationReason;
  String customerEmail;
  String customerPhone;
  String customerCountry;
  String customerNmae;
  DateTime cancelledAt;
  String cancelledBy;
  String status;
}