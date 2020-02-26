const mongoose = require('mongoose');

const userSchema = mongoose.Schema({
    username: {
        type: String,
        required: true,
    },
    password: {
        type: String,
        required: true,
    },
    email: {
        type: String,
        required: true,
    },
    firstName: {
        type: String,
        required: true
    },
    lastName: {
        type: String,
        required: true
    },
    // add photo here - https://stackoverflow.com/questions/4796914/store-images-in-a-mongodb-database
    university: {
        type: String,
        required: true,
    },
    sellingHistory: {
        type: [mongoose.Schema.Types.ObjectID],
        ref: "Items",
    },
    forSale: {
        type: [mongoose.Schema.Types.ObjectID],
        ref: "Items",
    },
    chats: {
        type: mongoose.Schema.Types.ObjectID,
        ref: "Conversation",
    },
})

module.exports = mongoose.model("User", userSchema);