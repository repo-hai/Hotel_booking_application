const db = require('../../firebase');

module.exports.changePassword = async (req, res) => {
  try {
    const body = await req.body;
    console.log(`Đổi mật khẩu. Thông tin: `);
    const myCollection = db.collection('Users');
    const querySnapshot = await myCollection.where('Email', '==', body.email).where('Password', '==', body.oldPassword).get();
    
    if(querySnapshot.empty){
      console.log("Sai mật khẩu cũ");
      return res.status(400).send("Sai mật khẩu cũ");
    } else {

      let UserId;
      querySnapshot.forEach((user) => {
        UserId = user.id;
      });
      
      console.log("Start update password");
      myCollection.doc(UserId).update({'Password': body.newPassword});
      console.log("Update password succesfully");

      console.log(`Thông tin sau đổi mật khẩu: mật khẩu mới: ${body.newPassword}.`)
          
      return res.status(200).send({
        message: 'Change password successfully',
      });
    }
  } catch (error) {
    console.log("Change password - Đã có lỗi khi thực thi hàm");
    return res.status(500).json(error.message).send();
  }
};
