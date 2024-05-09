const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

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

      return admin.messaging().sendToDevice(organizerToken, payload);
    }

    return null;
  });
