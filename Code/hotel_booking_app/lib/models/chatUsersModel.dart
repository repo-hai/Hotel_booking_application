// Khai bóa lớp ChatUsers - sử dụng trong trang danh sách cuộc hội thoại
class ChatUsers{
  String name;
  String messageText;
  String imageURL;
  String time;
  bool isRead;
  String userID;
  String chatboxID;

  // Định nghĩa phương thức khởi tạo
  ChatUsers({required this.chatboxID,required this.userID, required this.isRead, required this.name,required this.messageText,required this.imageURL,required this.time});
}

