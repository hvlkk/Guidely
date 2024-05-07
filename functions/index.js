// TODO: Move the entire sign-up functionality here
/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 * const {onRequest} = require("firebase-functions/v2/https");
 * const logger = require("firebase-functions/logger");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// TODO: Move the entire sign-up functionality here
// eslint-disable-line max-len
exports.checkUsernameAvailability = functions.https.onCall(
    async (data, context) => {
      const {username} = data;

      try {
        // Query Firestore to check if the username exists
        const userSnapshot = await admin
            .firestore()
            .collection("users")
            .where("username", "==", username)
            .get();
        return userSnapshot.empty;
      } catch (error) {
        console.error("Error checking username availability:", error);
        throw new functions.https.HttpsError(
            "internal",
            "Error checking username availability",
        );
      }
    },
);


// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
