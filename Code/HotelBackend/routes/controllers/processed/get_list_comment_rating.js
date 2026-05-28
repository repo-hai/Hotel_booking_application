const db = require('../../firebase');

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
