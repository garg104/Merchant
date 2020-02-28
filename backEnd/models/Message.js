const mongoose = require('mongoose');

const userSchema = mongoose.Schema({
    text: {
        type: String,
        require: true,
    },
    time : { 
        type : Date, 
        default: Date.now, 
    }
})

module.exports = mongoose.model("Message", userSchema);
