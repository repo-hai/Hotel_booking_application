import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:star_rating/star_rating.dart';

// Khai báo một StatefulWidget cho giao diện viết bình luận, đánh giá
class CommentRatingView extends StatefulWidget {

  // Định nghĩa lại phương thức createState()
  @override
  State<StatefulWidget> createState() {
    return _MyCommentRatingState();
  }
}

// Khai báo State cho giao diện viết bình luận, đánh giá
class _MyCommentRatingState extends State<CommentRatingView> {
  TextEditingController? controller = TextEditingController();
  late double rating = 1;
  String comment = "";

  // Định nghĩa lại hàm initState() - khởi gán giá trị ban đầu cho các biến
  @override
  void initState() {
    super.initState();
    setState(() {
      rating=1;
      comment="";
    });
  }

  // Ghi đè phương thức build - tự định nghĩa lại phương thức build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_sharp),
        ),
        title: Text("Đánh giá và bình luận"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsetsGeometry.fromLTRB(0, 30, 0, 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StarRating(
                    length: 5,
                    starSize: 55,
                    color: Colors.amber,
                    onRaitingTap: (value) {
                      setState(() {
                        rating = (value as int) as double;
                      });
                    },
                    rating: rating,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.fromLTRB(20, 0, 20, 0),
              child: SizedBox(
                width: 450,
                child: TextField(
                  onChanged: (value) {
                    comment = value;
                  },
                  decoration: InputDecoration(
                    fillColor: Color.fromRGBO(224, 232, 237, 1),
                    filled: true,
                    hintText: "Nhập vào bình luận của bạn",
                    contentPadding: EdgeInsetsGeometry.fromLTRB(30, 50, 30, 50),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(60)),
                    ),
                  ),
                  maxLines: 8,
                  controller: controller,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.fromLTRB(30, 50, 30, 50),
              child: ElevatedButton(
                // Thực thi thêm bình luận, đánh giá mới
                onPressed: () async {
                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                  String userID = prefs.getString("userID")!;
                  String hotelId = prefs.getString("hotelId")!;
                  print(comment);
                  print(rating);

                  final response = await http.post(
                    Uri.parse('http://localhost:3000/comment-rating-controller/create-new-comment-rating'),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: jsonEncode(<String, dynamic>{
                      'hotelId': userID,
                      'userId': hotelId,
                      'comment': comment,
                      'rating': rating as int,
                    }),
                  );

                  if (response.statusCode == 200) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(
                          "Tạo đánh giá bình luận mới thành công",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                            },
                            child: Text("OK"),
                          ),
                        ],
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text("Lỗi hệ thống, vui lòng thử lại"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                            },
                            child: Text("OK"),
                          ),
                        ],
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(40, 83, 175, 1),
                  padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                  fixedSize: Size(150, 70),
                ),
                child: Text(
                  "Gửi",
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
