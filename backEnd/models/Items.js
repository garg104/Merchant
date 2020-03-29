const mongoose = require('mongoose');

const userSchema = mongoose.Schema({
    userID: {
        type: mongoose.Schema.Types.ObjectID,
        ref: "User",
    },
    username: {
        type: String,
        require: true,
    },
    title: {
        type: String,
        require: true,
    },
    description: {
        type: String,
    },
    price: {
        type: String,
    },
    DatePosted: {
      type: Date,
      default: Date.now,  
    },
    picture: {
        type: [mongoose.Schema.Types.ObjectID],
        ref: "item-picture"
    },
    category: {
        type: String,
        require: true,
    },
    isSold: {
        type: Boolean,
        require: true,
    },
    university: {
        type: String,
        required: true,
    },
})

module.exports = mongoose.model("Items", userSchema);
