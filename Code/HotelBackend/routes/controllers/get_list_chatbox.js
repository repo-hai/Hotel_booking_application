const db = require('../../firebase');

// input: id hội thoại, id chính chủ
// output: danh sách tin nhắn hội thoại xếp theo thứ tự thời gian và tên người nhận

// các bước
// b1: lấy danh sách tin nhắn
// - lấy id hội thoại 
module.exports.getListChatbox = async (req, res) => {
  try {
    const body = await req.body;
    const allEntries = [];
    console.log("Lấy ds hội thoại cho người dùng - Thông tin request: ");
    console.log(body);
    const querySnapshot = await db.collection('Conversations').where('user1Id', '==', body.userId).orderBy('updatedAt', 'desc').get();
    querySnapshot.forEach( (doc) => allEntries.push(doc.data()));

    console.log("Lấy danh sách hội thoại phía người dùng thành công");
    return res.status(200).json(allEntries);
  } catch (error) {
    console.log("Lấy danh sách hội thoại phía người dùng - Lỗi hàm thục thi");
    return res.status(500).json(error.message);
  }
};

