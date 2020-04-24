import { authenticate } from '../middlewares/middlewares'
import { dispatchAPNViaFirebase } from '../utils/pushNotification';

const express = require('express');
const router = express.Router();
const Item = require('../models/Items')
const Conversations = require('../models/Conversations')
const User = require('../models/User')
const Location = require('../models/Location')
const Pusher = require('pusher')

/* GET home page. */
router.get('/', function (req, res, next) {
  res.render('index', { title: 'Express' });
});

/* Route for adding a meeting location for the conversation */
router.post('/meetingLocations', authenticate, async (req, res) => {
  const { conversationID, latitude, longitude, address, title, receiverUsername } = req.body
  try {
    const conversation = await Conversations.findById(conversationID)

    //create a pusher instance
    let pusher = new Pusher({
      appId: '988508',
      key: '0abb5543b425a847ea81',
      secret: '28b34e176e9568cd6048',
      cluster: 'us2',
      encrypted: true
    });

    let channelName = req.userInfo.username + '-' + receiverUsername + '-maps'

    if (conversation) {
      try {
        const location = new Location({ latitude, longitude, address, title })
        const savedLocation = await location.save()
        conversation.meeting = savedLocation._id
        await Conversations.findByIdAndUpdate(conversationID, { ...conversation })
        //sending the push notification
        const ret = await dispatchAPNViaFirebase(req.userInfo.username,
          receiverUsername,
          `${receiverUsername} has updated the meeting location`)
        pusher.trigger(channelName, 'map-location', { "location": location });
        res.status(200).json({ location, msg: "Location has been saved" })
      } catch (e) {
        res.status(400).json({ msg: "Location couldn't be updated" })
      } //end try-catch
    }
  } catch (e) {
    console.log(e.message)
    res.status(401).json({ msg: e.message })

  }
})

router.get('/safeLocations', authenticate, async (req, res) => {
  try {
    const safeLocations = await Location.find({ isSafe: true })
    res.status(200).json({ locations: safeLocations, msg: "Safe locations fetched successfully" })
  } catch (e) {
    res.status(400).json({ locations: [], msg: "Error occured, try again" })
  }
})

router.post('/sendPushNotifications', async (req, res) => {
  try {
    const { sender, receiver, messageBody } = req.body
    const ret = await dispatchAPNViaFirebase(sender, receiver, messageBody)
    res.status(200).json({ msg: ret.msg })
  } catch (e) {
    console.log(e.msg)
    res.status(400).json({ msg: e.msg })
  }
})

module.exports = router;