/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// const {setGlobalOptions} = require("firebase-functions");
// const {onRequest} = require("firebase-functions/https");
// const logger = require("firebase-functions/logger");

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// setGlobalOptions({ maxInstances: 10 });

const {addEntry} = require('./controllers/examples/addEntry');
const {getAllEntries} = require('./controllers/examples/getEntry');
const {updateEntry} = require('./controllers/examples/updateEntry');
const {deleteEntry} = require('./controllers/examples/deleteEntry');
const {login} = require('./controllers/login');
const {register} = require('./controllers/register');
const {confirmCode} = require('./controllers/confirm_code');
//const functions = require("firebase-functions");

const bodyParser = require('body-parser')
const jsonParser = bodyParser.json();
const express = require("express");

const app = express();

app.use(express.json());

app.get("/", (req, res) => res.status(200).send("Hey there!"));
app.get('/get-entry', getAllEntries);
app.post('/update-entry', updateEntry);
app.post('/delete-entry', deleteEntry);
app.post('/add-entry', addEntry);

app.post('/login', login);
app.post('/register', register);
app.post('/confirm-create-account', confirmCode);

//exports.app = functions.https.onRequest(app);
app.listen(3000, () => {
  console.log(`Example app listening on port 3000`);
})