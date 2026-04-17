const {db} = require('../config/firebase');

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
        if (querySnapshot.empty) {
            console.log('Sai username hoặc password.');
            return;
        } else {
            querySnapshot.forEach((user)=>{
                console.log("user id is : ", user.id);
                user_id = user.id;
            });
        }

        console.log(`Login successfully with username: ${username}, password: ${password}`);
        return res.status(200).json({
            user_id: user_id,
        });
    } catch (error) {
        console.log("Đã có lỗi khi thực thi hàm login");
        return res.status(500).json();
    }
};
