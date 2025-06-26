// functions/index.js
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Send random message to all users (can be scheduled)
exports.sendRandomMessage = functions.pubsub
    .schedule("every 6 hours") // Adjust frequency as needed
    .timeZone("Africa/Kigali")
    .onRun(async(context) => {
        try {
            console.log("🚀 Starting random message send...");

            // Get a random message from Firestore
            const messagesRef = admin.firestore().collection("random_messages");
            const snapshot = await messagesRef.where("isActive", "==", true).get();

            if (snapshot.empty) {
                console.log("❌ No random messages found");
                return null;
            }

            // Select random message
            const messages = snapshot.docs;
            const randomIndex = Math.floor(Math.random() * messages.length);
            const randomMessage = messages[randomIndex].data();

            console.log(`📤 Sending message: ${randomMessage.title}`);

            // Send to topic
            const message = {
                notification: {
                    title: randomMessage.title,
                    body: randomMessage.body,
                },
                data: {
                    type: randomMessage.type || "random_message",
                    messageId: messages[randomIndex].id,
                    timestamp: Date.now().toString(),
                },
                topic: "random_messages",
            };

            const response = await admin.messaging().send(message);
            console.log("✅ Message sent successfully:", response);

            // Log the sent message
            await admin.firestore().collection("sent_messages").add({
                messageId: messages[randomIndex].id,
                title: randomMessage.title,
                body: randomMessage.body,
                type: randomMessage.type,
                sentAt: admin.firestore.FieldValue.serverTimestamp(),
                response: response,
            });

            return response;
        } catch (error) {
            console.error("❌ Error sending random message:", error);
            return null;
        }
    });

// Manual trigger for random message (for testing)
exports.triggerRandomMessage = functions.https.onCall(async(data, context) => {
    try {
        // Optional: Add authentication check
        // if (!context.auth) {
        //   throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
        // }

        console.log("🔥 Manual trigger for random message");

        const messagesRef = admin.firestore().collection("random_messages");
        const snapshot = await messagesRef.where("isActive", "==", true).get();

        if (snapshot.empty) {
            throw new functions.https.HttpsError("not-found", "No random messages found");
        }

        const messages = snapshot.docs;
        const randomIndex = Math.floor(Math.random() * messages.length);
        const randomMessage = messages[randomIndex].data();

        const message = {
            notification: {
                title: randomMessage.title,
                body: randomMessage.body,
            },
            data: {
                type: randomMessage.type || "random_message",
                messageId: messages[randomIndex].id,
                timestamp: Date.now().toString(),
            },
            topic: "random_messages",
        };

        const response = await admin.messaging().send(message);

        // Log the sent message
        await admin.firestore().collection("sent_messages").add({
            messageId: messages[randomIndex].id,
            title: randomMessage.title,
            body: randomMessage.body,
            type: randomMessage.type,
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            triggeredBy: context.auth.uid || "anonymous",
            response: response,
        });

        return {
            success: true,
            messageId: response,
            sentMessage: {
                title: randomMessage.title,
                body: randomMessage.body,
            },
        };
    } catch (error) {
        console.error("❌ Error in manual trigger:", error);
        throw new functions.https.HttpsError("internal", error.message);
    }
});

// Send personalized message based on user's mood patterns
exports.sendPersonalizedMessage = functions.firestore
    .document("moods/{moodId}")
    .onCreate(async(snap, context) => {
        try {
            const moodData = snap.data();
            const userId = moodData.userId;

            if (!userId) return null;

            // Get user's FCM token
            const userTokensRef = admin.firestore().collection("user_tokens");
            const tokenSnap = await userTokensRef.where("userId", "==", userId).get();

            if (tokenSnap.empty) {
                console.log("❌ No FCM token found for user:", userId);
                return null;
            }

            const userToken = tokenSnap.docs[0].data().token;

            // Get appropriate message based on mood
            let messageQuery = admin.firestore().collection("random_messages")
                .where("isActive", "==", true);

            // Customize message based on mood level
            if (moodData.level <= 2) {
                // Low mood - send encouraging message
                messageQuery = messageQuery.where("type", "in", ["encouragement", "strength", "worth"]);
            } else if (moodData.level >= 4) {
                // Good mood - send positive reinforcement
                messageQuery = messageQuery.where("type", "in", ["motivation", "progress", "gratitude"]);
            }

            const messageSnap = await messageQuery.get();

            if (messageSnap.empty) {
                // Fallback to any random message
                const allMessages = await admin.firestore().collection("random_messages")
                    .where("isActive", "==", true).get();

                if (!allMessages.empty) {
                    const randomMsg = allMessages.docs[Math.floor(Math.random() * allMessages.docs.length)];
                    const msgData = randomMsg.data();

                    await admin.messaging().send({
                        notification: {
                            title: msgData.title,
                            body: msgData.body,
                        },
                        data: {
                            type: "personalized_message",
                            moodLevel: moodData.level.toString(),
                        },
                        token: userToken,
                    });
                }
                return null;
            }

            const messages = messageSnap.docs;
            const randomMessage = messages[Math.floor(Math.random() * messages.length)];
            const messageData = randomMessage.data();

            // Send personalized message
            const response = await admin.messaging().send({
                notification: {
                    title: messageData.title,
                    body: messageData.body,
                },
                data: {
                    type: "personalized_message",
                    moodLevel: moodData.level.toString(),
                    messageType: messageData.type,
                },
                token: userToken,
            });

            console.log("✅ Personalized message sent:", response);
            return response;
        } catch (error) {
            console.error("❌ Error sending personalized message:", error);
            return null;
        }
    });

// Clean up old sent messages (runs daily)
exports.cleanupOldMessages = functions.pubsub
    .schedule("every 24 hours")
    .timeZone("Africa/Kigali")
    .onRun(async(context) => {
        try {
            console.log("🧹 Cleaning up old sent messages...");

            const cutoffDate = new Date();
            cutoffDate.setDate(cutoffDate.getDate() - 30); // Keep last 30 days

            const oldMessagesRef = admin.firestore().collection("sent_messages");
            const snapshot = await oldMessagesRef
                .where("sentAt", "<", admin.firestore.Timestamp.fromDate(cutoffDate))
                .get();

            if (snapshot.empty) {
                console.log("✅ No old messages to clean up");
                return null;
            }

            const batch = admin.firestore().batch();
            snapshot.docs.forEach((doc) => {
                batch.delete(doc.ref);
            });

            await batch.commit();
            console.log(`✅ Cleaned up ${snapshot.docs.length} old messages`);

            return snapshot.docs.length;
        } catch (error) {
            console.error("❌ Error cleaning up old messages:", error);
            return null;
        }
    });

// Get random message stats (for admin dashboard)
exports.getMessageStats = functions.https.onCall(async(data, context) => {
    try {
        // Optional: Add admin authentication check here

        const [messagesSnap, sentSnap] = await Promise.all([
            admin.firestore().collection("random_messages").where("isActive", "==", true).get(),
            admin.firestore().collection("sent_messages").get(),
        ]);

        const messagesByType = {};
        messagesSnap.docs.forEach((doc) => {
            const type = doc.data().type || "unknown";
            messagesByType[type] = (messagesByType[type] || 0) + 1;
        });

        const last30Days = new Date();
        last30Days.setDate(last30Days.getDate() - 30);

        const recentSentMessages = sentSnap.docs.filter((doc) => {
            const sentAt = doc.data().sentAt;
            return sentAt && sentAt.toDate() > last30Days;
        });

        return {
            totalActiveMessages: messagesSnap.docs.length,
            messagesByType,
            totalSentMessages: sentSnap.docs.length,
            sentLast30Days: recentSentMessages.length,
            lastSentAt: sentSnap.docs.length > 0 ?
                sentSnap.docs[sentSnap.docs.length - 1].data().sentAt : null,
        };
    } catch (error) {
        console.error("❌ Error getting message stats:", error);
        throw new functions.https.HttpsError("internal", error.message);
    }
});