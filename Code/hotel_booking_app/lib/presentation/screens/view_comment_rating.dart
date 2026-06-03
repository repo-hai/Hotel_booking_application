import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hotel_booking_app/models/commentRating.dart';
import 'package:http/http.dart' as http;
import 'package:rating_summary/rating_summary.dart';
import 'package:hotel_booking_app/presentation/screens/comment_rating.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Khai báo một StatefulWidget cho giao diện xem bình luận đánh giá
class ViewCommentRating extends StatefulWidget {
  const ViewCommentRating({super.key});

  // Định nghĩa lại phương thức createState()
  @override
  State<StatefulWidget> createState() {
    return _MyRatingCommentSection();
  }
}

// Khai báo State cho giao diện xem bình luận, đánh giá
class _MyRatingCommentSection extends State<ViewCommentRating> {
  late int numberOfRating = 10;
  late int ratingOneStar = 0;
  late int ratingTwoStar = 0;
  late int ratingThreeStar = 0;
  late int ratingFourStar = 0;
  late int ratingFiveStar = 0;
  late double avgRating = 0.0;
  List<commentRating> listCommentRating = [];

  // Lấy dữ liệu bình luận, đánh giá từ server để hiển thị
  Future<void> fetchCommentRating() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //var hotelId = prefs.getString('hotelId')!;
    var hotelId = 1;
    var response = await http.get(
      Uri.parse(
        'http://localhost:3000/comment-rating-controller/get-list-comment-rating/$hotelId',
      ),
    );

    var jsonData = jsonDecode(response.body);
    print(jsonData);

    if (response.statusCode == 200) {
      setState(() {
        for (var jsonObject in jsonData) {
          print(jsonObject);
          var date = DateTime.fromMillisecondsSinceEpoch(
            int.parse(jsonObject["time"]),
          );
          print(date);
          var now = DateTime.now();
          var time = "";
          if (now.year == date.year &&
              now.month == date.month &&
              now.day == date.day) {
            time = date.hour.toString() + ":" + date.minute.toString();
          } else {
            time =
                date.day.toString() +
                "/" +
                date.month.toString() +
                " " +
                date.hour.toString() +
                ":" +
                date.minute.toString();
          }
          var new_comment_rating = commentRating(
            comment: jsonObject["comment"],
            rating: jsonObject["rating"],
            time: time,
            username: jsonObject["userName"],
            userURL: jsonObject["user_url"],
          );
          setState(() {
            listCommentRating.add(new_comment_rating);
          });
        }
      });

      response = await http.get(
        Uri.parse(
          'http://localhost:3000/comment-rating-controller/get-avg-rating/$hotelId',
        ),
      );

      jsonData = jsonDecode(response.body);
      print(jsonData);

      if (response.statusCode == 200) {
        setState(() {
          numberOfRating = jsonData["count"];
          ratingOneStar = jsonData["one_star_rating"];
          ratingTwoStar = jsonData["two_star_rating"];
          ratingThreeStar = jsonData["three_star_rating"];
          ratingFourStar = jsonData["four_star_rating"];
          ratingFiveStar = jsonData["five_star_rating"];
          avgRating = double.parse(jsonData["avg"]);
        });
      } else {
        print("Mã phản hồi: ");
        print(response.statusCode);
      }
    } else {
      print("Mã phản hồi: ");
      print(response.statusCode);
    }
  }

  // Định nghĩa lại hàm initState() - khởi gán giá trị ban đầu cho các biến
  @override
  void initState() {
    super.initState();
    fetchCommentRating();
  }

  // Ghi đè phương thức build - tự định nghĩa lại phương thức build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Đánh giá"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_outlined),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.fromLTRB(20, 20, 20, 20),
            child: RatingSummary(
              backgroundColor: Colors.white,
              counter: numberOfRating,
              label: "Đánh giá từ khách hàng",
              average: avgRating,
              counterFiveStars: ratingFiveStar,
              counterFourStars: ratingFourStar,
              counterThreeStars: ratingThreeStar,
              counterTwoStars: ratingTwoStar,
              counterOneStars: ratingOneStar,
            ),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsetsGeometry.fromLTRB(20, 0, 0, 0),
                child: Text("Đánh giá ($numberOfRating)"),
              ),
              Padding(
                padding: EdgeInsetsGeometry.fromLTRB(250, 0, 0, 0),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return CommentRatingView();
                        },
                      ),
                    );
                  },
                  icon: Icon(Icons.edit),
                  color: Colors.white,
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.green),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SizedBox(
              height: 500,
              width: 500,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      itemCount: listCommentRating.length,
                      shrinkWrap: true,
                      padding: EdgeInsetsGeometry.fromLTRB(20, 0, 0, 0),
                      physics: AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return CommentList(
                          userURL: listCommentRating[index].userURL,
                          userName: listCommentRating[index].username,
                          comment: listCommentRating[index].comment,
                          rating: listCommentRating[index].rating,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Định nghĩa một đối tượng bình luận - mỗi đối tượng là một dòng bình luận của người dùng
class CommentList extends StatelessWidget {
  String userName, comment, userURL;
  int rating;

  // Khai báo phương thức khởi tạo
  CommentList({
    required this.userURL,
    required this.userName,
    required this.comment,
    required this.rating,
  });

  // Ghi đè phương thức build - tự định nghĩa lại phương thức build
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.fromLTRB(0, 10, 20, 20),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(userURL), maxRadius: 20),
          SizedBox(
            width: 300,
            child: Padding(
              padding: EdgeInsetsGeometry.fromLTRB(10, 0, 0, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(fontWeight: FontWeight(700)),
                        overflow: TextOverflow.clip,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                          comment
                      )
                    ],
                  ),
                ],
              ),
            )
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsetsGeometry.fromLTRB(0, 0, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(rating.toString()),
                  Icon(Icons.star, color: Colors.amber),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
