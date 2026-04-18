const db = require('../../firebase');

module.exports.getCommentRating = async (req, res) => {
  try {
    const body = await req.body;
    console.log(`Lấy rating của khách sạn ${body.hotelId}`);
    const queryBookingSnapshot = await db.collection('Bookings').where("hotelId", '==', body.hotelId).get();

    let allReviews = [];
    let allBookings = [];
    const myReviewsCollection = await db.collection('Reviews');
    queryBookingSnapshot.forEach( async (doc) => {
      const bookingId = doc.id;
      allBookings.push(doc.id);
    });

    for(const o of allBookings){
      const queryReviewSnapshot = await myReviewsCollection.where("bookingId", '==', o).get();
      queryReviewSnapshot.forEach((review) => {
        allReviews.push(review.data());
      });
    }
    console.log(allReviews);

    console.log('Lấy review của khách sạn thành công');
    return res.status(200).json(allReviews);
  } catch (error) {
    console.log("Get avg rating - Đã có lỗi khi thực thi hàm");
    return res.status(500).json(error.message);
  }
};
