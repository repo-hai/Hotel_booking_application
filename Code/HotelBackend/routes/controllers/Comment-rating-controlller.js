const db = require('../../firebase');

// cần lấy ra tất cả các đánh giá ứng với khách sạn được chọn
// đầu tiên cần lấy được tất cả booking với hotel id là khách sạn được chọn
// sau đó duyệt từng phần tử trong danh sách booking và lấy ra tất cả các đánh giá ứng với booking id
module.exports.getAvgRating = async (req, res) => {
  try {
    const params = req.params;
    const querySnapshot = await db.collection('Comment-rating').where("hotelID", '==', params.hotelID).get();

    console.log(querySnapshot);

    let sum = 0;
    let one_star_rating = 0;
    let two_star_rating = 0;
    let three_star_rating = 0;
    let four_star_rating = 0;
    let five_star_rating = 0;
    let count = 0;
    let allRating = [];

    querySnapshot.forEach((doc) => {
      allRating.push(doc.data());
    })

    for(const o of allRating){
      count += 1;
      if(o.rating == 1){
        console.log("rating is 1");
        sum += 1;
        one_star_rating += 1;
      } else if (o.rating == 2){
        sum += 2;
        two_star_rating += 1;
      } else if (o.rating == 3){
        sum += 3;
        three_star_rating += 1;
      } else if (o.rating == 4){
        sum += 4;
        four_star_rating += 1;
      } else{
        sum += 5;
        five_star_rating += 1;
      } 
    }

    let avg = (count == 0) ? 0 : sum / count;
    console.log(`total review: ${count}`);
    console.log(`avg rating of hotel ${params.hotelId} is: ${avg}`);

    return res.status(200).json({
      'count': count,
      'avg': Number.parseFloat(avg).toFixed(1),
      'one_star_rating': one_star_rating,
      'two_star_rating': two_star_rating,
      'three_star_rating': three_star_rating,
      'four_star_rating': four_star_rating,
      'five_star_rating': five_star_rating
    });
  } catch (error) {
    console.log("Get avg rating - Đã có lỗi khi thực thi hàm");
    console.log(error.message);
    return res.status(500).json(error.message);
  }
};

module.exports.get_list_comment_rating = async (req, res) => {
  try {
    const params = await req.params;

    console.log("Params: ", params)
    console.log("HotelID: ", params.hotelID);
    let allCommentRating = [];

    const querySnapshot = await db.collection('Comment-rating').where("hotelID", '==', params.hotelID).get();
    let myUserCollection = db.collection("Users");
    for (let doc of querySnapshot.docs) {
      const data = doc.data();
      let userName = "";
      let userSnapshot = await myUserCollection.where("ID", "==", Number.parseInt(data.userID)).get();
      userSnapshot.forEach((user) => {
        userName = user.data().Name;
      })
      console.log(data);
      allCommentRating.push({
        hotelID: data.hotelID,
        userID: data.userID,
        userName: userName,
        user_url: "https://cdn-icons-png.flaticon.com/512/9187/9187604.png",
        comment: data.comment,
        rating: data.rating,
        time: data.time
      });
    };

    console.log(allCommentRating);

    return res.status(200).json(allCommentRating);

  } catch (error) {
    console.log("Lấy danh sách hội thoại phía người dùng - Lỗi hàm thục thi");
    console.log(error.message);
    return res.status(500).json(error.message);
  }
};

module.exports.create_new_comment_rating = async (req, res) => {
  try {
    const body = req.body;
    const hotelId = body.hotelId;
    const comment = body.comment;
    const rating = body.rating;
    const userId = body.userId;
    const time = Date.now();

    const CommentRatingObject = {
      hotelID: hotelId,
      comment: comment,
      rating: rating,
      time: time.toString(),
      userID: userId
    };
    console.log(CommentRatingObject);

    const myCollection = db.collection('Comment-rating');

    const count = myCollection.get().size + 1;

    await myCollection.doc("comment-rating-" + toString(count)).set(CommentRatingObject);
    console.log("Ghi vào bảng CommentRating thành công");

    return res.status(200).send({
      message: 'create comment rating successfully',});
  } catch (error) {
    console.log("Register - Đã có lỗi khi thực thi hàm");
    return res.status(500).json(error.message).send();
  }
};
