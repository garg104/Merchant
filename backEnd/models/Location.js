const mongoose = require('mongoose');

const locationSchema = mongoose.Schema({
    latitude: {
        type: mongoose.Schema.Types.Number,
        required: true
    },
    longitude: {
        type: mongoose.Schema.Types.Number,
        required: true
    },
    title: {
        type: mongoose.Schema.Types.String,
        required: false
    },
    address: {
        type: mongoose.Schema.Types.String,
        required: false,
    },
    //to determine if a location is a random user selected one or a verified safe one
    isSafe: {
        type: mongoose.Schema.Types.Boolean,
        default: false
    }
})

module.exports = mongoose.model("Location", locationSchema);
