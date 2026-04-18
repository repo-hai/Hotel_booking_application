const {db} = require('../../firebase');

module.exports.getDetailChatbox = async (req, res) => {
  try {
    const allEntries = [];
    const querySnapshot = await db.collection('entries').get();
    querySnapshot.forEach( (doc) => allEntries.push(doc.data()));
    return res.status(200).json(allEntries);
  } catch (error) {
    return res.status(500).json(error.message);
  }
};

