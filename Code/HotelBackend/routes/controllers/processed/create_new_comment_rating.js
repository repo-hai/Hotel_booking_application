const db = require('../../firebase');

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
