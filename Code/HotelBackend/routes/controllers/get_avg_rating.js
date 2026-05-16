const db = require('../../firebase');

// cần lấy ra tất cả các đánh giá ứng với khách sạn được chọn
// đầu tiên cần lấy được tất cả booking với hotel id là khách sạn được chọn
// sau đó duyệt từng phần tử trong danh sách booking và lấy ra tất cả các đánh giá ứng với booking id
module.exports.getAvgRating = async (req, res) => {
  try {
    const body = await req.body;
    console.log(`Lấy avg rating của khách sạn ${body.hotelId}`);
    const queryBookingSnapshot = await db.collection('Bookings').where("hotelId", '==', body.hotelId).get();

    let sum = 0;
    let one_star_rating = 0;
    let two_star_rating = 0;
    let three_star_rating = 0;
    let four_star_rating = 0;
    let five_star_rating = 0;
    let count = 0;
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

    for(const o of allReviews){
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
    console.log(`avg rating of hotel ${body.hotelId} is: ${avg}`);

    return res.status(200).json({
      'avg': Number.parseFloat(avg).toFixed(1),
      'one_star_rating': one_star_rating,
      'two_star_rating': two_star_rating,
      'three_star_rating': three_star_rating,
      'four_star_rating': four_star_rating,
      'five_star_rating': five_star_rating
    });
  } catch (error) {
    console.log("Get avg rating - Đã có lỗi khi thực thi hàm");
    return res.status(500).json(error.message);
  }
};
