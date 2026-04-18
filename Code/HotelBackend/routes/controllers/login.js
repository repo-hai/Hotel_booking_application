const {db} = require('../../firebase');

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
