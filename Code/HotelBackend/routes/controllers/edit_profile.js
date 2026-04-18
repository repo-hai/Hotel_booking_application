const {db} = require('../../firebase');

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
