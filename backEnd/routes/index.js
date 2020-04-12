import { authenticate } from '../middlewares/middlewares'

const express = require('express');
const router = express.Router();
const Item = require('../models/Items')
const Conversations = require('../models/Conversations')
const User = require('../models/User')
const Location = require('../models/Location')

/* GET home page. */
router.get('/', function (req, res, next) {
  res.render('index', { title: 'Express' });
});

/* Route for adding a meeting location for the conversation */
router.post('/meetingLocation/', authenticate, async (req, res) => {
  const { conversationID, latitude, longitude } = req.body
  const conversation = await Conversations.findById(conversationID)
  if (conversation) {
    try {
      const location = new Location({ latitude, longitude })
      const savedLocation = await location.save()
      conversation.meeting = savedLocation._id
      await Conversations.findByIdAndUpdate(conversationID, { ...conversation })
      res.status(200).json({ location, msg: "Location has been saved" })
    } catch (e) {
      res.status(400).json({ msg: "Location couldn't be updated" })
    } //end try-catch
  } else {
    res.status(404).json({ msg: "Conversation not found" })
  } //end if
})

router.get('/safeLocations', authenticate, async (req, res) => {
  try {
    const safeLocations = await Location.find({ isSafe: true })
    res.status(200).json({ locations: safeLocations, msg: "Safe locations fetched successfully" })
  } catch (e) {
    res.status(400).json({ locations: [], msg: "Error occured, try again" })
  }
})

module.exports = router;