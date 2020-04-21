const apn = require('apn')

import * as admin from "firebase-admin";

const serviceAccount = require('../firebase.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://merchant-307.firebaseio.com"
});

/**
 * This function helps dispatch an
 * APN (Appple Push Notification) to
 * Apple's push notification server
 */
export const dispatchAPNViaFirebase = (username, userMessage) => {
    // These registration tokens come from the client FCM SDKs.
    const registrationTokens = [];

    //formatting the message object
    const message = {
        notification: {
            title: username,
            body: userMessage,
        },
        data: { time: Date.now().toString() },
        tokens: registrationTokens,
    }

    //broadcasting the message and error handling
    admin.messaging().sendMulticast(message)
        .then((response) => {
            if (response.failureCount > 0) {
                const failedTokens = [];
                response.responses.forEach((resp, idx) => {
                    if (!resp.success) {
                        failedTokens.push(registrationTokens[idx]);
                    }
                });
                console.log('List of tokens that caused failures: ' + failedTokens);
            }
        });
}

/**
 * This function helps dispatch an
 * APN (Apple Push Notification) to
 * Apple's push notification server
 */
export const dispatchAPN = () => {
    //set up the apn provider
    let apnProvider = new apn.Provider({
        token: {
            key: process.env.APN_FILE_NAME,
            keyId: process.env.APN_KEY,
            teamId: process.env.TEAM_ID,
        },
        production: false,
    })

    let deviceToken = ""

    //setting up a new notification
    let note = new apn.Notification()
    note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
    note.badge = 3;
    note.alert = "\uD83D\uDCE7 \u2709 You have a new message";
    note.payload = { 'messageFrom': 'Sender' };
    note.topic = "com.example.CS307Team4.Merchant";

    apnProvider.send(note, deviceToken).then((result) => {
        result.sent.forEach(token => {
            console.log('Sent OK')
        });

        result.failed.forEach(failure => {
            if (failure.error) {
                console.log(failure.response)
            }
        })
    });

    //shutdown the apn provider
    apnProvider.shutdown()
}