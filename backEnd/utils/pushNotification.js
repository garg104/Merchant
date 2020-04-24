// const apn = require('apn')
const User = require('../models/User')
const admin = require('firebase-admin')

const serviceAccount = require('../firebase');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://merchant-307.firebaseio.com"
})

/**
 * This function helps dispatch an
 * APN (Apple Push Notification) to
 * Apple's push notification server
 * 
 * @param senderUsername: username of the sender
 * @param receiverUsername: username of the receiver
 * @param userMessage: message body
 */
export const dispatchAPNViaFirebase = async (senderUsername, receiverUsername, userMessage) => {
    return new Promise(async (resolve, reject) => {
        // These registration tokens come from the client FCM SDKs.
        let registrationTokens = [];

        try {
            const user = await User.findOne({ username: receiverUsername })
            registrationTokens = user.deviceTokens
        } catch (e) {
            console.log(e.message)
            reject({ msg: 'Error occured, cannot get the reciever' })
            return
        }

        if (registrationTokens.length == 0) {
            resolve({ msg: 'No registration tokens found' })
            return
        }

        //get the name of the sender
        let senderName = senderUsername
        try {
            const user = await User.findOne({ username: receiverUsername })
            senderName = `${user.firstName} ${user.lastName}`
        } catch (e) {
            console.log(e.message)
        }

        //formatting the message object
        const message = {
            notification: {
                title: senderName,
                body: userMessage,
            },
            data: { time: Date.now().toString(), type: 'text-message' },
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
                resolve({ msg: 'The push notifications have been sent' })
            });
    })
}

// /**
//  * This function helps dispatch an
//  * APN (Apple Push Notification) to
//  * Apple's push notification server
//  */
// export const dispatchAPN = () => {
//     //set up the apn provider
//     let apnProvider = new apn.Provider({
//         token: {
//             key: process.env.APN_FILE_NAME,
//             keyId: process.env.APN_KEY,
//             teamId: process.env.TEAM_ID,
//         },
//         production: false,
//     })

//     let deviceToken = ""

//     //setting up a new notification
//     let note = new apn.Notification()
//     note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
//     note.badge = 3;
//     note.alert = "\uD83D\uDCE7 \u2709 You have a new message";
//     note.payload = { 'messageFrom': 'Sender' };
//     note.topic = "com.example.CS307Team4.Merchant";

//     apnProvider.send(note, deviceToken).then((result) => {
//         result.sent.forEach(token => {
//             console.log('Sent OK')
//         });

//         result.failed.forEach(failure => {
//             if (failure.error) {
//                 console.log(failure.response)
//             }
//         })
//     });

//     //shutdown the apn provider
//     apnProvider.shutdown()
// }