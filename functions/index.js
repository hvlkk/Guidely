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

const { v4: uuidv4 } = require("uuid");

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const common = require("./common/common");

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
    const tourId = context.params.tourId;

    const newValue = change.after.data();
    const previousValue = change.before.data();

    const newRegisteredUsers = newValue.registeredUsers;
    const previousRegisteredUsers = previousValue.registeredUsers;

    // Check if a new value was added to the registeredUsers list
    if (newRegisteredUsers.length > previousRegisteredUsers.length) {
      const newUserId = newRegisteredUsers.find(
        (user) => !previousRegisteredUsers.includes(user)
      );
      // get the user's FCM token
      const user = await common.getUserByUserId(newUserId);
      const userFCMToken = user.fcmToken;

      // subscription to the tour topic
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
        await admin.messaging().send(message);

        const notificationHoster = common.constructNotification(
          uuidv4(),
          "New Tour Registration",
          `User ${user.username} has registered for your tour.`
        );

        await common.addNotificationToUser(
          newValue.organizer.uid,
          notificationHoster
        );

        const notificationUser = common.constructNotification(
          uuidv4(),
          "Tour Registration Successful",
          `You have successfully registered for the tour.`
        );

        await common.addNotificationToUser(newUserId, notificationUser);
      } else {
        console.log("Organizer FCM token not found");
      }
    }
  });

exports.handleAuthStatusChange = functions.firestore
  .document("users/{authState}")
  .onUpdate(async (change, context) => {
    const newValue = change.after.data();
    console.log("New value:", newValue);

    const previousValue = change.before.data();
    console.log("Previous value:", previousValue);

    const newAuthState = newValue.authState;
    console.log("New auth state:", newAuthState);

    const previousAuthState = previousValue.authState;
    console.log("Previous auth state:", previousAuthState);

    const userFCMToken = newValue.fcmToken;
    console.log("User FCM token:", userFCMToken);

    if (previousAuthState === 1 && newAuthState === 2) {
      await common.sendNotificationToPendingOrganizer(newValue.uid, "approved");
      const message = {
        notification: {
          title: "Auth State Updated",
          body: `Your authentication state has been updated to ${newAuthState}.`,
        },
        token: userFCMToken,
      };
      await admin.messaging().send(message);
    }

    if (previousAuthState === 1 && newAuthState === 0) {
      await common.sendNotificationToPendingOrganizer(newValue.uid, "rejected");
      const message = {
        notification: {
          title: "Auth State Updated",
          body: `Your authentication state has been updated to ${newAuthState}.`,
        },
        token: userFCMToken,
      };
      await admin.messaging().send(message);
    }
  });
