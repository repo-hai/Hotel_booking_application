import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:star_rating/star_rating.dart';

class CommentRatingView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyCommentRatingState();
  }
}

class _MyCommentRatingState extends State<CommentRatingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: (){
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
                padding: EdgeInsetsGeometry.fromLTRB(130, 30, 50, 50),
                child: StarRating(
                  length: 5,
                  starSize: 50,
                  color: Color.fromRGBO(227, 233, 237, 1),
                ),
              ),
              SizedBox(
                width: 450,
                child: CupertinoTextField(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(224, 232, 237, 1),
                    border: BoxBorder.all(
                        color: Color.fromRGBO(224, 232, 237, 1)
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(60)),
                  ),
                  maxLines: 8,
                  padding: EdgeInsetsGeometry.fromLTRB(20, 40, 20, 40),
                  placeholder: "Viết đánh giá của bạn",
                ),
              ),
              Padding(
                padding: EdgeInsetsGeometry.fromLTRB(10, 50, 10, 50),
                child: ElevatedButton(
                  onPressed: (){},
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll<Color>(Color.fromRGBO(40, 83, 175, 1)),
                    padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(EdgeInsetsGeometry.fromLTRB(30, 20, 30, 20)),
                  ),
                  child: Text(
                    "Gửi",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
}