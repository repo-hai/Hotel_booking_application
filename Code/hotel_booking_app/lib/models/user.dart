// Khai báo dối tượng user
class User{
  int id;
  String email;
  String password;
  String phone;
  String name;
  String location;
  String gender;
  DateTime dateOfBirth;
  String role;

  // Định nghĩa hàm khởi tạo
  User(this.id, this.email, this.password, this.phone, this.name, this.location,
      this.gender, this.dateOfBirth, this.role);

}