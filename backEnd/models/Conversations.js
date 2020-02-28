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
    // add something for maps and meet up location. 
})

module.exports = mongoose.model("Conversations", userSchema);
