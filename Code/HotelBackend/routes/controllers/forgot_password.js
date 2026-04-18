const {db} = require('../config/firebase');
let nodemailer = require('nodemailer');
const crypto = require("crypto");

function generatePassword(){
  return crypto.randomInt(100000, 999999).toString();
}

module.exports.register = async (req, res) => {
  try {
    const body = req.body;
    console.log(`Quen mat khau. Thong tin: email: ${body.email}.`)
    const myCollection = db.collection('Users');
    const querySnapshot = await myCollection.where('Email', '==', body.email).get();
    
    if(querySnapshot.empty){
      console.log("Sai email");
      return res.status(500).send("Sai email");
    } else {
      let transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
          user: 'dinhhoanghai.email@gmail.com',
          pass: 'ebpi lhbu cbzb qpgm',
        }
      });

      const newPassword = generatePassword();

      let mailOptions = {
        from: 'dinhhoanghai.email@gmail.com',
        to: body.email,
        subject: 'Change password email',
        text: `Your new password is: ${newPassword}`
      };

      let UserId;
      querySnapshot.forEach((user) => {
        UserId = user.id;
      });

      transporter.sendMail(mailOptions, function(error, info){
        if(error){
          console.log(error);
          return res.status(500).json({
            error: "Quên mật khẩu - Lỗi chưa gửi được email",
          });
        } else {
          console.log('Email sent: ' + info.response);

          myCollection.doc(UserId).update({'Password': newPassword});

          console.log(`Thông tin sau đổi mật khẩu: mật khẩu mới: ${newPassword}.`)
          
          return res.status(200).send({
            message: 'Change password account successfully',
          });
        }
      });
    }
  } catch (error) {
    console.log("Đã có lỗi khi thực thi hàm login");
    return res.status(500).json(error.message).send();
  }
};
