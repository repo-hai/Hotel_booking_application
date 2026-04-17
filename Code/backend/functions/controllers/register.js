const {db} = require('../config/firebase');
let nodemailer = require('nodemailer');
const crypto = require("crypto");

function generateConfirmCode(){
  return crypto.randomInt(1000, 9999).toString();
}

function generateUserID(){
  return crypto.randomUUID();
}

module.exports.register = async (req, res) => {
  try {
    const body = req.body;
    console.log(`Tao tai khoan moi. Thong tin: name: ${body.name}, email: ${body.email}, password: ${body.password}.`)
    const myCollection = db.collection('Users');
    const querySnapshot = await myCollection.where('Email', '==', body.email).get();
    
    if(!querySnapshot.empty){
      console.log("Duplicate email");
      return res.status(500).send();
    } else {
      let transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
          user: 'dinhhoanghai.email@gmail.com',
          pass: 'ebpi lhbu cbzb qpgm',
        }
      });

      const confirmCode = generateConfirmCode();

      let mailOptions = {
        from: 'dinhhoanghai.email@gmail.com',
        to: body.email,
        subject: 'Confirm email',
        text: confirmCode
      };

      transporter.sendMail(mailOptions, function(error, info){
        if(error){
          console.log(error);
          return res.status(500).json({
            error: "Lỗi chưa gửi được email",
          });
        } else {
          const userid = generateUserID();
          console.log('Email sent: ' + info.response);
          const unconfirmUserObject = {
            UserId: userid,
            Email: body.email,
            Password: body.password,
            ConfirmCode: confirmCode
          };
          const myUnconfirmCollection = db.collection("UnconfirmAccount");
          myUnconfirmCollection.doc(userid).set(unconfirmUserObject);

          console.log(`Thong tin tai khoan chua xac nhan: id: ${unconfirmUserObject.UserId}, email: ${body.email}, password: ${body.password}.`)
          
          return res.status(200).send({
            message: 'create unconfirm account successfully',
          });
        }
      });
    }
  } catch (error) {
    console.log("Đã có lỗi khi thực thi hàm login");
    return res.status(500).json(error.message).send();
  }
};
