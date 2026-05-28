const db = require('../../firebase');

module.exports.getDetailChatbox = async (req, res) => {
  const params = await req.params;
  try {

    /*
    messageObject={
      chatboxID,
      message,
      time,
      sender,
      receiver,
    }
    */

    const ChatboxID = params.chatboxid;
    const allMessage = [];
    console.log("Lấy ds hội thoại cho người dùng - Thông tin request: ");
    console.log(params);
    const querySnapshot = await db.collection('Message').where('chatboxID', '==', ChatboxID).get();

    for (let doc of querySnapshot.docs) {
      allMessage.push({
        "time": doc.data().time,
        "message": doc.data()["message"],
        "receiverID": doc.data()["receiverID"].toString(),
        "senderID": doc.data()["senderID"].toString()
      })
    }

    console.log("Lấy danh sách tin nhắn thành công");
    return res.status(200).json(allMessage);
  } catch (error) {
    console.log("Lấy danh sách hội thoại phía người dùng - Lỗi hàm thục thi");
    return res.status(500).json(error.message);
  }
};

