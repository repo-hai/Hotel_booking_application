import 'package:flutter/material.dart';
import 'package:rating_summary/rating_summary.dart';
import 'package:hotel_booking_app/presentation/screens/comment_rating.dart';

class ViewCommentRating extends StatelessWidget{
  const ViewCommentRating({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Đánh giá"),
          leading: IconButton(
              onPressed: (){
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_outlined)
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _MyRatingSection(),
            _MyCommentSection(),
          ],
        )
    );
  }
}

class _MyRatingSection extends StatelessWidget {
  // @override
  // State<StatefulWidget> createState() {
  //   return _MyRatingState();
  // }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: RatingSummary(
        backgroundColor: Colors.white,
        counter: 13,
        label: "Đánh giá từ khách hàng",
        average: 3.5,
        counterFiveStars: 5,
        counterFourStars: 4,
        counterThreeStars: 2,
        counterTwoStars: 1,
        counterOneStars: 1,
      ),
    );
  }
}

class _MyCommentSection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyCommentState();
  }
}

class _MyCommentState extends State<_MyCommentSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text("Đánh giá(500)"),
            Padding(
              padding: EdgeInsetsGeometry.fromLTRB(300, 0, 0, 0),
              child: IconButton(
                onPressed: (){
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return CommentRatingView();
                      },
                    ),
                  );
                },
                icon: Icon(
                    Icons.edit
                ),
                color: Colors.white,
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.green),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}