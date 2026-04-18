const {db} = require('../../firebase');

module.exports.commentRating = async (req, res) => {
  try {
    const body = await req.body;
    console.log(`Tao comment - rating moi. Thong tin: `);
    console.log(body);
    const myCollection = db.collection('Reviews');
    
    const snap = await myCollection.count().get();
    const reviewId = snap._data.count + 1;
    const reviewObject = {
      'bookingId': body.bookingId,
      'how': body.comment,
      'createdAt': Date(),
      'id': reviewId,
      'rating': body.rating
    };
    console.log(reviewObject);

    await myCollection.doc().set(reviewObject);

    console.log(`Tạo review ${reviewId} thành công`);

    return res.status(200).send({
      message: 'create review successfully',
    });
  } catch (error) {
    console.log("Register - Đã có lỗi khi thực thi hàm");
    return res.status(500).json(error.message).send();
  }
};
