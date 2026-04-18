const {db} = require('../../../firebase');

async function testCount(){
    const myCollection = db.collection('Users');

    const userid = await myCollection.count().get();

    console.log(userid);

    let data = userid._data.count;

    console.log(data + 1);
}

testCount();