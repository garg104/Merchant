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
    wishlist: {
        type: [mongoose.Schema.Types.ObjectID],
        ref: "Items",
        default: [],
    },
    reviews: {
        type: [{
            username: {
                type: String,
                require: true,
            },
            review: {
                type: String,
                require: true
            },
            DatePosted: {
                type: Date,
                default: Date.now,  
            },
        }],
        default: []
    },
    rating: {
        type: {
            totalRatings: String,
            currentRating: String
        },
        default: {}
    } 
})

module.exports = mongoose.model("User", userSchema);
