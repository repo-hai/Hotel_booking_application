const db = require('../../firebase');

// input: id hội thoại, id chính chủ
// output: danh sách hội thoại xếp theo thứ tự thời gian

// các bước
// b1: lấy danh sách tin nhắn
// - lấy id hội thoại 
module.exports.getListChatbox = async (req, res) => {

  const params = await req.params;
  console.log(params);

  try {

    /*
    chatboxObject={
      chatboxID,
      lastMessage,
      time,
      isRead,
      userid1,
      userid2,
    }
    */

    const allEntries = [];
    console.log("Lấy ds hội thoại cho người dùng");
    let querySnapshot = await db.collection('Chatbox').where('userID_1', '==', params.userid).get();
    let check = true;
    if(querySnapshot.empty){
      querySnapshot = await db.collection('Chatbox').where('userID_2', '==', params.userid).get();
      check = false;
    }
    for(let doc of querySnapshot.docs){
      let collaborative_name="";
      let collaborativeID="";
      if(check){
        console.log("userID_2: " + doc.data().userID_2.toString());
        const queryUsers = await db.collection('Users').where("ID", "==", Number.parseInt(doc.data().userID_2)).get();
        console.log("query size is: " + queryUsers.size);
        queryUsers.forEach((doc)=>{
          //console.log(doc.data());
          collaborative_name = doc.data().Name;
          collaborativeID = doc.data().ID.toString();
        });
      } else {
        console.log("userID_1: " + doc.data().userID_1.toString());
        const queryUsers = await db.collection('Users').where("ID", "==", Number.parseInt(doc.data().userID_1)).get();
        console.log("query size is: " + queryUsers.size);
        queryUsers.forEach((doc)=>{
          //console.log(doc.data());
          collaborative_name = doc.data().Name;
          collaborativeID = doc.data().ID.toString();
        });
      }
      console.log(collaborative_name);
      allEntries.push({
        "collaborative_name": collaborative_name,
        "user_url": "https://cdn-icons-png.flaticon.com/512/9187/9187604.png",
        "chatboxID": doc.id.toString(),
        "time": doc.data().time,
        "lastMessage": doc.data()["lastMessage"],
        "isRead": doc.data()["isRead"],
        "collaborativeID": collaborativeID.toString()
      })
    }

    console.log("Lấy danh sách hội thoại phía người dùng thành công");
    return res.status(200).json(allEntries);
  } catch (error) {
    console.log("Lấy danh sách hội thoại phía người dùng - Lỗi hàm thục thi");
    return res.status(500).json(error.message);
  }
};

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