const mongoose = require('mongoose');

const userSchema = mongoose.Schema({  
    messages: {
        type: [{
            userIDSender: {
                type: mongoose.Schema.Types.ObjectID,
                ref: "User",
            },
            userIDReceiver: {
                type: mongoose.Schema.Types.ObjectID,
                ref: "User",
            },
            text: {
                type: String,
                require: true,
            },
            time : { 
                type : String, 
                require: true, 
            }
        }],
        default: [],
    },
    meeting: {
        type: mongoose.Schema.Types.ObjectID,
        ref: "Location",
        require: false
    }
})

module.exports = mongoose.model("Conversations", userSchema);
