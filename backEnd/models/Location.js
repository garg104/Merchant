const mongoose = require('mongoose');

const locationSchema = mongoose.Schema({
    lattitude: {
        type: mongoose.Schema.Types.Number,
        required: true
    },
    longitude: {
        type: mongoose.Schema.Types.Number,
        required: true
    },
    //to determine if a location is a random user selected one or a verified safe one
    isSafe: {
        type: mongoose.Schema.Types.Boolean,
        default: false
    }
})

module.exports = mongoose.model("Location", locationSchema);
