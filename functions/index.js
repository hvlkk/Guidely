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

exports.subscribeTourAndNotifyEntry = functions.firestore
  .document("tours/{tourId}")
  .onUpdate(async (change, context) => {
    const newValue = change.after.data();
    const previousValue = change.before.data();

    const newRegisteredUsers = newValue.registeredUsers;
    const previousRegisteredUsers = previousValue.registeredUsers;

    console.log("New registered users length:", newRegisteredUsers.length);
    console.log(
      "Previous registered users length:",
      previousRegisteredUsers.length
    );

    // Check if a new value was added to the registeredUsers list
    if (newRegisteredUsers.length > previousRegisteredUsers.length) {
      const newUserId = newRegisteredUsers.find(
        (user) => !previousRegisteredUsers.includes(user)
      );
      // get the user's FCM token
      const userSnapshot = await admin
        .firestore()
        .collection("users")
        .doc(newUserId)
        .get();
      const user = userSnapshot.data();
      const userFCMToken = user.fcmToken;

      // subscription to the tour topic
      const tourId = context.params.tourId;
      await admin.messaging().subscribeToTopic(userFCMToken, tourId);
      console.log("User subscribed to tour topic:", tourId);

      const organizerFcmToken = newValue.organizer.fcmToken;

      if (organizerFcmToken) {
        const message = {
          notification: {
            title: "New Tour Registration",
            body: `A new user has registered for your tour.`,
          },
          token: organizerFcmToken,
        };
        // needs to be fixed
        await admin.messaging().send(message);
        console.log("Notification sent to organizer:", organizerFcmToken);
      } else {
        console.log("Organizer FCM token not found");
      }
    }
  });
