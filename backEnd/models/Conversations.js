const mongoose = require('mongoose');

const userSchema = mongoose.Schema({
    userIDSender: {
        type: mongoose.Schema.Types.ObjectID,
        ref: "User",
    },
    userIDReceiver: {
        type: mongoose.Schema.Types.ObjectID,
        ref: "User",
    },
    messages: {
        type: [mongoose.Schema.Types.ObjectID],
        ref: "Message",
        default: [],
    },
    meeting: {
        type: mongoose.Schema.Types.ObjectID,
        ref: "Location"
    }
})

module.exports = mongoose.model("Conversations", userSchema);
