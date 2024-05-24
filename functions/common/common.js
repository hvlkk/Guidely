const admin = require("firebase-admin");

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

function constructNotification(uid, title, message) {
  return {
    uid: uid || uuidv4(),
    title: title || "",
    message: message || "",
    date: new Date(),
  };
}

module.exports = {
  addNotificationToUser,
  getUserByUserId,
  constructNotification,
};
