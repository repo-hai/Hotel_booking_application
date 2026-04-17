class Payment{
  int id;
  int total;
  DateTime createdAt;
  String method;
  String status;

  Payment(this.id, this.total, this.createdAt, this.method, this.status);
}