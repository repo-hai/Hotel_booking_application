const db = require('../../firebase');
let nodemailer = require('nodemailer');
const crypto = require("crypto");

function generateConfirmCode() {
  return crypto.randomInt(1000, 9999).toString();
}

function generatePassword(){
  return crypto.randomInt(100000, 999999).toString();
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
      let userId, email, password, objectId, role, phone, name;
      querySnapshot.forEach((user) => {
        userId = user.data().UserId;
        email = user.data().Email;
        password = user.data().Password;
        objectId = user.data().ID;
        role = user.data().Role;
        phone = user.data().Phone;
        name = user.data().Name;
      });
      console.log(`Thong tin query unconfirmAccount: user_id: ${userId}, email: ${email}, password: ${password}, objectId: ${objectId}`);
      const userObject = {
        ID: objectId,
        Email: email,
        Password: password,
        Role: role,
        Location: "Hà Nội",
        MembershipLevel: null,
        Name: name,
        Phone: phone,
        Point: 0,
        SearchingHistory: [],
        CustomerBookInfo: [],
        TotalSpent: null,
        DateOfBirth: "1999-01-01"
      };
      console.log(userObject);
      const myUserCollection = db.collection("Users");
      await myUserCollection.doc(objectId.toString()).set(userObject);
      console.log("Ghi vào bảng Users thành công");

      const myUnconfirmCollection = db.collection('UnconfirmAccount').doc(objectId.toString());
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

module.exports.login = async (req, res) => {
    try {
        const body = req.body;
        console.log("request body is: ", body);

        const username = body.email;
        const password = body.password;
        console.log('username: ', username);
        console.log('password: ', password);
        const querySnapshot = await db.collection('Users').where('Email', '==', username).where('Password', '==', password).get();
        
        let user_id = "";
        let role = "";
        if (querySnapshot.empty) {
            console.log('Sai username hoặc password.');
            return res.status(400).json({"error": "Sai username/password"});
        } else {
            querySnapshot.forEach((user)=>{
                console.log("user id is : ", user.id);
                user_id = user.id;
                role = user.data().Role;
            });
        }

        console.log(`Login successfully with username: ${username}, password: ${password}, role: ${role}`);
        return res.status(200).json({
            user_id: user_id,
            role: role,
            password: password,
        });
    } catch (error) {
        console.log("Đã có lỗi khi thực thi hàm login");
        return res.status(500).json(error.message);
    }
};

module.exports.forgotPassword = async (req, res) => {
  try {
    const body = req.body;
    console.log(`Quen mat khau. Thong tin: email: ${body.email}.`)
    const myCollection = db.collection('Users');
    const querySnapshot = await myCollection.where('Email', '==', body.email).get();
    
    if(querySnapshot.empty){
      console.log("Sai email");
      return res.status(400).send("Sai email");
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
    console.log("Forgot password - Đã có lỗi khi thực thi hàm");
    return res.status(500).json(error.message).send();
  }
};

module.exports.changePassword = async (req, res) => {
  try {
    const body = await req.body;
    console.log(`Đổi mật khẩu. Thông tin: `);
    await console.log(body);
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

module.exports.getUser = async (req, res) => {
  try {
    const body = await req.body;
    const params = await req.params;

    console.log("Params: ", params)
    console.log("Email: ", params.email);

    const querySnapshot = await db.collection('Users').where("Email", '==', params.email).get();
    querySnapshot.forEach( (doc) => {
        console.log(doc.data());
        userObject= doc.data();
    });
    console.log("user object is: " + userObject);

    console.log("Lấy thông tin người dùng thành công");
    //return res.status(200).json(allEntries);

    return res.status(200).json(userObject);

  } catch (error) {
    console.log("Lấy danh sách hội thoại phía người dùng - Lỗi hàm thục thi");
    return res.status(500).json(error.message);
  }
};

module.exports.editProfile = async (req, res) => {
  try {
    const body = await req.body;
    console.log(`Chỉnh sửa thông tin cá nhân. Thông tin: `);
    await console.log(body);
    const myCollection = db.collection('Users');
    const querySnapshot = await myCollection.where('Email', '==', body.email).where('Password', '==', body.password).get();
    
    if(querySnapshot.empty){
      console.log("Sai mật khẩu");
      return res.status(400).send("Sai mật khẩu");
    } else {

        let UserId;
        querySnapshot.forEach((user) => {
            UserId = user.id;
        });
      
        console.log("Start update profile");
        
        myCollection.doc(UserId).update({
            'Email': body.newEmail,
            'Name': body.newName,
            'Phone': body.newPhoneNumber
        });

        console.log("Edit profile succesfully");

        console.log(`Thông tin sau edit profile: new email: ${body.newEmail}, new name: ${body.newName}, new phone number: ${body.newPhoneNumber}.`)
            
        return res.status(200).send({
            message: 'Edit profile successfully',
        });
    }
  } catch (error) {
    console.log("Edit profile - Đã có lỗi khi thực thi hàm");
    return res.status(500).json(error.message).send();
  }
};


