const {db} = require('../../../firebase');

async function testCount(){
    const myCollection = db.collection('UnconfirmAccount');

    const unconfirmObject = await myCollection.doc('10');

    console.log(unconfirmObject);
}

testCount();