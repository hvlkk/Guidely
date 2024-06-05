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
const { getRecommendationScore } = require("./recommendation_system");

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

// CLOUD FUNCTIONS LISTENERS

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
    const previousValue = change.before.data();

    const newAuthState = newValue.authState;
    const previousAuthState = previousValue.authState;

    const userFCMToken = newValue.fcmToken;

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

// tour recommender
// this will need to listen on the tours collection,
// once a new tour is added, it will recommend the tour to users
// based on their preferences

exports.recommendTour = functions.firestore
  .document("tours/{tourId}")
  .onCreate(async (snapshot, context) => {
    const tourData = snapshot.data();

    const usersSnapshot = await admin.firestore().collection("users").get();

    usersSnapshot.forEach(async (userDoc) => {
      const userData = userDoc.data();
      const userFCMToken = userData.fcmToken;
      // call recommender function with tourData and userData as argument
      // const score = getRecommendationScore(userData, tourData);

      const score = Math.random(); // test score

      const threshold = 0.5;

      if (score < threshold) {
        return;
      }
      console.log("Recommendation score above threshold: ", score);

      const message = {
        notification: {
          title: "New Tour Recommendation",
          body: `We recommend you to check out the new tour: ${tourData.title}.`,
        },
        token: userFCMToken,
      };

      try {
        console.log("About to send tour recommendation to user:", userData.uid);
        await admin.messaging().send(message);
        console.log("Tour recommendation sent to user:", userData.uid);

        await common.addNotificationToUser(
          userData.uid,
          "New Tour Recommendation",
          `We recommend you to check out the new tour: ${tourData.tourDetails.title}.`
        );
      } catch (error) {
        console.error("Error sending tour recommendation:", error);
      }
    });
  });

// send notification if a new review is added to a tour
exports.sendReviewNotification = functions.firestore
  .document("tours/{tourId}/reviews/{reviewId}")
  .onCreate(async (snapshot, context) => {
    const tourId = context.params.tourId;
    console.log("Cloud Function triggered by review creation:", snapshot.id);

    const tourSnapshot = await admin
      .firestore()
      .collection("tours")
      .doc(tourId)
      .get();

    // find the review added
    const tourReviews = tourSnapshot.data().reviews;
    const review = tourReviews.find((r) => r.id === snapshot.id);

    const tourData = tourSnapshot.data();

    const tourOrganizerUid = tourData.organizer.uid;

    const tourTitle = tourData.tourDetails.title;

    console.log("Now creating message for organizer:", tourOrganizerUid);
    const message = {
      notification: {
        title: "New Review Added",
        body: `A new review has been added to your tour: ${tourTitle}.`,
      },
      token: tourData.organizer.fcmToken,
    };

    console.log(
      "About to send review notification to organizer:",
      tourOrganizerUid
    );

    try {
      await admin.messaging().send(message);
      console.log("Review notification sent to organizer:", tourOrganizerUid);

      await common.addNotificationToUser(
        tourOrganizerUid,
        "New Review Added",
        `A new review has been added to your tour: ${tourTitle} with rating ${review.grade} and comment: ${review.comment}`
      );
    } catch (error) {
      console.error("Error sending review notification:", error);
    }
  });
