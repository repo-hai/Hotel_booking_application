const { isReadable } = require('nodemailer/lib/xoauth2');
const db = require('../../firebase');
const { all } = require('../hotel');

module.exports.pushUpNewMessage = async (req, res) => {
  try {
    const body = req.body;
    const chatboxID = body.chatboxID;
    const message = body.message;
    const senderUserId = body.senderUserId;
    const receiverUserId = body.receiverUserId;
    const time = Date.now();

    const MessageObject = {
      "chatboxID": chatboxID,
      "message": message,
      "senderID": senderUserId,
      "receiverID": receiverUserId,
      "time": time
    };

    console.log(MessageObject);

    const myCollection = db.collection('Message');

    const allMessage = await myCollection.get();
    const count = allMessage.size + 1;
    console.log(count);
    await myCollection.doc("message" + "_" + count.toString()).set(MessageObject);
    console.log("Ghi vào bảng Message thành công");

    const myChatboxCollection = db.collection("Chatbox");
    // get object
    const listChatbox = await myChatboxCollection.get();
    let chatboxObject;

    listChatbox.forEach((doc) => {
      if(doc.id == chatboxID){
        chatboxObject = doc.data();
      }
    });

    console.log(chatboxObject);
    // edit object
    const newChatBoxObject={
      lastMessage: message,
      time: time.toString(),
      isRead: true,
      userID_1: chatboxObject["userID_1"],
      userID_2: chatboxObject["userID_2"]
    }
    console.log(newChatBoxObject);
    // set
    await myChatboxCollection.doc(chatboxID).set(newChatBoxObject);

    return res.status(200).send();
  } catch (error) {
    console.log("Push up new message - Đã có lỗi khi thực thi hàm");
    console.log(error.message);
    return res.status(500).json(error.message).send();
  }
};