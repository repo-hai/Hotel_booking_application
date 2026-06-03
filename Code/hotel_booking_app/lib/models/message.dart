// Khai báo lớp tin nhắn
class Message {
  String message;
  String senderID;
  String receiverID;
  String time;

  // Định nghĩa phương thức khởi tạo
  Message({required this.message, required this.senderID, required this.time, required this.receiverID});
}