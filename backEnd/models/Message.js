const mongoose = require('mongoose');

const userSchema = mongoose.Schema({
    text: {
        type: String,
        require: true,
    },
    time : { 
        type : String, 
        require: true, 
    }
})

module.exports = mongoose.model("Message", userSchema);
