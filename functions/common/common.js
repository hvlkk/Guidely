const admin = require("firebase-admin");
const { v4: uuidv4 } = require("uuid");

async function addNotificationToUser(userId, title, message) {
  const notification = constructNotification(title, message);
  try {
    const userRef = admin.firestore().collection("users").doc(userId);
    await userRef.update({
      notifications: admin.firestore.FieldValue.arrayUnion(notification),
    });
  } catch (error) {
    console.error("Error adding notification:", error);
  }
}

function constructNotification(title, message) {
  return {
    uid: uuidv4(),
    title: title || "",
    message: message || "",
    date: new Date().toString(),
    isRead: false,
  };
}

async function getUserByUserId(userId) {
  const userSnapshot = await admin
    .firestore()
    .collection("users")
    .doc(userId)
    .get();
  const user = userSnapshot.data();
  return user;
}

async function sendNotificationToPendingOrganizer(userId, requestStatus) {
  try {
    const notification = constructNotification(
      `Request ${requestStatus}`,
      `A request to become an organizer has been ${requestStatus}.`
    );
    await addNotificationToUser(userId, notification.title, notification.message);
  } catch (error) {
    console.error("Error sending notification to organizer:", error);
  }
}

module.exports = {
  addNotificationToUser,
  getUserByUserId,
  sendNotificationToPendingOrganizer,
};
