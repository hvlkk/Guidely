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

    const newRegisteredUsers = change.after.data().registeredUsers;
    const previousRegisteredUsers = change.before.data().registeredUsers;

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
      console.log("Organizer FCM token:", organizerFcmToken);
      const message = {
        notification: {
          title: "New Tour Registration",
          body: "A new user has registered for your tour.",
        },
        token: organizerFcmToken,
      };
      try {
        await admin.messaging().send(message);
        console.log("Notification sent to organizer:", newValue.organizer.uid);
      } catch (error) {
        console.error("Error sending notification to organizer:", error);
      }

      await common.addNotificationToUser(
        newValue.organizer.uid,
        "New Tour Registration",
        `User ${user.username} has registered for your tour.`
      );

      await common.addNotificationToUser(
        newUserId,
        "Tour Registration Successful",
        "You have successfully registered for the tour."
      );
    }
  });

exports.sendTourAnnouncementNotification = functions.firestore
  .document("tours/{tourId}")
  .onUpdate(async (change, context) => {
    const tourId = context.params.tourId;

    const newValue = change.after.data();

    const newAnnouncement = change.after.data().recentAnnouncement;
    const previousAnnouncement = change.before.data().recentAnnouncement;

    if (newAnnouncement !== previousAnnouncement) {
      const message = {
        notification: {
          title: "New Announcement for Tour",
          body: newAnnouncement,
        },
        topic: tourId,
      };
      try {
        await admin.messaging().send(message);
        console.log("Announcement notification sent to topic:", tourId);
      } catch (error) {
        console.error("Error sending notification:", error);
      }

      const registeredUsers = newValue.registeredUsers;
      for (const userId of registeredUsers) {
        try {
          await common.addNotificationToUser(
            userId,
            "New Announcement",
            newAnnouncement
          );
          console.log(`Notification added to user ${userId}`);
        } catch (error) {
          console.error(`Error adding notification to user ${userId}:`, error);
        }
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
