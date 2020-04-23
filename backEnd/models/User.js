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
    rating: {
        type: {
            totalRatings: String,
            currentRating: String,
            users: [{
                userID: mongoose.Schema.Types.ObjectID,
                rating: String,
                review: {
                    type: String,
                    require: true
                },
                DatePosted: {
                    type: String,
                    require: true,
                },
            }]
        },
        default: {
            totalRatings: 0,
            currentRating: 0,
            users: []
        }
    },
    reports: {
        type: {
            reportNum: String,
            users: [{
                userID: mongoose.Schema.Types.ObjectID,
                reason: String,
                DatePosted: {
                    type: String,
                    require: true,
                },
            }]
        },
        default: {
            reportNum: 0,
            users: []
        },
    },
    deviceTokens: {
        type: [mongoose.Schema.Types.String],
        default: []
    }
})

module.exports = mongoose.model("User", userSchema);
