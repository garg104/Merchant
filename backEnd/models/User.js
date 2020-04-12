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
    picture: {
        type: mongoose.Schema.Types.ObjectID,
        ref: "profile-picture"
    },
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
        type: [mongoose.Schema.Types.ObjectID],
        ref: "Conversations",
    },
    wishList: {
        type: [mongoose.Schema.Types.ObjectID],
        ref: "Items",
    }
})

module.exports = mongoose.model("User", userSchema);
