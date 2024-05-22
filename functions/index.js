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

// eslint-disable-line max-len
exports.checkUsernameAvailability = functions.https.onCall(
  async (data, context) => {
    const { username } = data;

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
        "Error checking username availability"
      );
    }
  }
);

exports.sendNotification = functions.https.onCall(async (data, context) => {
  const { tourId } = data;

  try {
    const tourSnapshot = await admin
      .firestore()
      .collection("tours")
      .doc(tourId)
      .get();
    const tourData = tourSnapshot.data();

    // You can access the tour data here and perform necessary operations

    return { success: true };
  } catch (error) {
    console.error("Error sending notification:", error);
    return { success: false, error: error.message };
  }
});

exports.sendNotification = functions.firestore
  .document("tours/{tourId}")
  .onUpdate((change, context) => {
    const newValue = change.after.data();
    const previousValue = change.before.data();

    const newRegisteredUsers = newValue.registeredUsers;
    const previousRegisteredUsers = previousValue.registeredUsers;

    // Check if a new user has been added
    const addedUsers = newRegisteredUsers.filter(
      (user) => !previousRegisteredUsers.includes(user)
    );

    if (addedUsers.length > 0) {
      const organizerToken = newValue.organizer.fcmToken;
      const tourTitle = newValue.tourDetails.title;

      const payload = {
        notification: {
          title: "New User Registered",
          body: `${addedUsers.length} new user(s) registered for the tour "${tourTitle}"`,
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      };
      print("Sending notification...");
      return admin.messaging().sendToDevice(organizerToken, payload);
    }

    return null;
  });
