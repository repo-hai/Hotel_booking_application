const {db} = require('../../firebase');


module.exports.getUser = async (req, res) => {
  try {
    const params = await req.params;

    console.log("Params: ", params)
    console.log("Email: ", params.email);

    const querySnapshot = await db.collection('Users').where("Email", '==', params.email).get();
    let userObject;
    querySnapshot.forEach( (doc) => {
        console.log(doc.data());
        userObject = doc.data();
    });
    console.log("user object is: " + userObject);

    console.log("Lấy thông tin người dùng thành công");

    return res.status(200).json(userObject);

  } catch (error) {
    console.log("Lấy danh sách hội thoại phía người dùng - Lỗi hàm thục thi");
    return res.status(500).json(error.message);
  }
};

