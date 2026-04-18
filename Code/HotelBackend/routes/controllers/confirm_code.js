const {db} = require('../config/firebase');

module.exports.confirmCode = async (req, res) => {
  try {
    const body = req.body;
    console.log(`Xac nhan tao tai khoan moi. Thong tin: email: ${body.email}, confirm-code: ${body.confirmCode}.`)
    const myCollection = db.collection('UnconfirmAccount');
    const querySnapshot = await myCollection.where('Email', '==', body.email).where('ConfirmCode', '==', body.confirmCode).get();
    
    if(querySnapshot.empty){
      console.log("Sai email hoac confirm code");
      return res.status(500).json({"error": "sai email hoac sai confirm code"}).send();
    } else {
      let userId, email, password, objectId;
      querySnapshot.forEach((user) => {
        userId = user.data().UserId;
        email = user.data().Email;
        password = user.data().Password;
        objectId = user.id;
      });
      console.log(`Thong tin query unconfirmAccount: user_id: ${userId}, email: ${email}, password: ${password}, objectId: ${objectId}`);
      const userObject = {
        UserId: userId,
        Email: email,
        Password: password,
      };
      const myUserCollection = db.collection("Users");
      myUserCollection.doc(userObject.UserId).set(userObject);

      const myUnconfirmCollection = db.collection('UnconfirmAccount').doc(objectId);
      await myUnconfirmCollection.delete().catch((error) => {
        return res.status(400).json({
          status: 'error',
          message: error.message,
        });
      });

      console.log(`Tao tai khoan moi thanh cong: id: ${userObject.UserId}, email: ${userObject.Email}, password: ${userObject.Password}.`)
      
      return res.status(200).send({
        message: 'create account successfully',
      });
    }
  } catch (error) {
    console.log("Đã có lỗi khi thực thi hàm confirm code");
    return res.status(500).json(error.message).send();
  }
};
