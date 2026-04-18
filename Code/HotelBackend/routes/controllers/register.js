const db = require('../../firebase');
let nodemailer = require('nodemailer');
const crypto = require("crypto");

function generateConfirmCode() {
  return crypto.randomInt(1000, 9999).toString();
}

function generateUserID() {
  return crypto.randomUUID();
}

module.exports.register = async (req, res) => {
  try {
    const body = req.body;
    console.log(`Tao tai khoan moi. Thong tin: role: ${body.role}, name: ${body.name}, email: ${body.email}, password: ${body.password}.`)
    const myCollection = db.collection('Users');
    const querySnapshot = await myCollection.where('Email', '==', body.email).get();

    if (!querySnapshot.empty) {
      console.log("Duplicate email");
      return res.status(500).send("Duplicate email");
    } else {
      console.log("Chuẩn bị gửi email");
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
        text: `Your confirm code is: ${confirmCode}`
      };
      console.log("Chuẩn bị hoàn tất. Bắt đầu gửi email");
      transporter.sendMail(mailOptions, async function (error, info) {
        if (error) {
          console.log(error);
          return res.status(500).json({
            error: "Lỗi chưa gửi được email",
          });
        } else {
          console.log('Email sent: ' + info.response);
          const allUsersSnap = await myCollection.get();
          const userid = allUsersSnap.size + 1;
          console.log("New user ID:", userid);
          const unconfirmUserObject = {
            ID: userid,
            Email: body.email,
            Password: body.password,
            ConfirmCode: confirmCode,
            Role: body.role,
            Location: "Hà Nội",
            MembershipLevel: null,
            Name: body.name,
            Phone: body.phone,
            Point: 0,
            SearchingHistory: [],
            CustomerBookInfo: [],
            TotalSpent: null,
            DateOfBirth: "1999-01-01"
          };
          console.log(unconfirmUserObject);

          const myUnconfirmCollection = db.collection("UnconfirmAccount");
          await myUnconfirmCollection.doc(userid.toString()).set(unconfirmUserObject);

          console.log(`Thong tin tai khoan chua xac nhan: id: ${unconfirmUserObject.ID}, email: ${body.email}, password: ${body.password}.`)

          return res.status(200).send({
            message: 'create unconfirm account successfully',
          });
        }
      });
    }
  } catch (error) {
    console.log("Register - Đã có lỗi khi thực thi hàm");
    return res.status(500).json(error.message).send();
  }
};
