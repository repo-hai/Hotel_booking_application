// Khai báo lớp sử dụng trong trang xem bình luận, đánh giá
class commentRating{

  String username, userURL, comment, time;
  int rating;

  // Khai báo phương thức khởi tạo
  commentRating({required this.username, required this.userURL, required this.comment, required this.time, required this.rating});
}