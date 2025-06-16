const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();
const db = getFirestore();

exports.sendMoodUpdateNotification = onDocumentUpdated("moods/{userId}", async (event) => {
  const userId = event.params.userId;
  const partnerId = userId === "me" ? "partner" : "me";

  const partnerDoc = await db.collection("users").doc(partnerId).get();
  const fcmToken = partnerDoc.data()?.fcmToken;

  if (!fcmToken) {
    console.log("❌ No FCM token found for partner:", partnerId);
    return;
  }

  const payload = {
    notification: {
      title: "Mood Update 💬",
      body: "Your partner just updated their mood.",
    },
    token: fcmToken,
  };

  try {
    const response = await getMessaging().send(payload);
    console.log("✅ Notification sent:", response);
  } catch (error) {
    console.error("❌ Failed to send notification:", error);
  }
});
