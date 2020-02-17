const mongoose = require('./node_modules/mongoose');

const userSchema = mongoose.Schema({
    userName: {
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
    // add photo here - https://stackoverflow.com/questions/4796914/store-images-in-a-mongodb-database
    university: {
        type: String,
        required: true,
    },
    sellingHistory: {
        type: [Schema.Types.ObjectID],
        ref: "Items",
    },
    forSale: {
        type: [Schema.Types.ObjectID],
        ref: "Items",
    },
    chats: {
        type: Schema.Types.ObjectID,
        ref: "Conversation",
    },
})

module.exports = mongoose.model("User", userSchema);