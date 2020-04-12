const mongoose = require('mongoose');

const userSchema = mongoose.Schema({
    userIDSender: {
        type: mongoose.Schema.Types.ObjectID,
        ref: "User",
    },
    userIDReciever: {
        type: mongoose.Schema.Types.ObjectID,
        ref: "User",
    },
    messages: {
        type: [mongoose.Schema.Types.ObjectID],
        ref: "Message"
    },
    meeting: {
        type: mongoose.Schema.Types.ObjectID,
        ref: "Location"
    }
})

module.exports = mongoose.model("Conversations", userSchema);
