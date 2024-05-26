const admin = require("firebase-admin");
const { v4: uuidv4 } = require("uuid");

async function addNotificationToUser(userId, notification) {
  console.log("Adding notification to user:", userId, notification);
  try {
    const userRef = admin.firestore().collection("users").doc(userId);
    await userRef.update({
      notifications: admin.firestore.FieldValue.arrayUnion(notification),
    });
  } catch (error) {
    console.error("Error adding notification:", error);
  }
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
      uuidv4(),
      `Request ${requestStatus}`,
      `A request to become an organizer has been ${requestStatus}.`
    );
    await addNotificationToUser(userId, notification);
  } catch (error) {
    console.error("Error sending notification to organizer:", error);
  }
}

function constructNotification(uid, title, message) {
  return {
    uid: uid || uuidv4(),
    title: title || "",
    message: message || "",
    date: new Date().toString(),
    isRead: false,
  };
}

module.exports = {
  addNotificationToUser,
  getUserByUserId,
  constructNotification,
  sendNotificationToPendingOrganizer,
};