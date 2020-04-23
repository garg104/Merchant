import { authenticate } from '../middlewares/middlewares'
import { dispatchAPNViaFirebase } from '../utils/pushNotification';

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
router.post('/meetingLocations', authenticate, async (req, res) => {
  const { conversationID, latitude, longitude, address, title, receiverUsername } = req.body
  const conversation = await Conversations.findById(conversationID)
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
      res.status(200).json({ location, msg: "Location has been saved" })
    } catch (e) {
      res.status(400).json({ msg: "Location couldn't be updated" })
    } //end try-catch
  } else {
    //in case wrong conversation id supplied
    try {
      const receiver = await User.findOne({ username: receiverUsername })
      if (receiver) {
        //finding the conversation using the id of users
        const conversation = await Conversations.findOne({ userIDSender: req.userInfo._id, userIDReceiver: receiver._id })
        if (conversation) {
          //updating the new user location
          const location = new Location({ latitude, longitude, address, title })
          const savedLocation = await location.save()
          conversation.meeting = savedLocation._id
          await Conversations.findByIdAndUpdate(conversation._id, { ...conversation })
          const ret = await dispatchAPNViaFirebase(req.userInfo.username,
            receiverUsername,
            `${receiverUsername} has updated the meeting location`)
          res.status(200).json({ location, msg: "Location has been saved" })
          //sending the push notification
        }
      }
    } catch (e) {
      console.log(e)
      res.status(400).json({ msg: "Location couldn't be updated" })
    }
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

router.get('/sendPushNotifications', async (req, res) => {
  try {
    const { sender, receiver, messageBody } = req.body
    const ret = await dispatchAPNViaFirebase(sender, receiver, messageBody)
    res.status(200).json({ msg: ret.msg })
  } catch (e) {
    console.log(e.msg)
    res.status(400).json({ msg: e.msg })
  }
})

router.push('/deleteConversation', authenticate, async (req, res) => {
  const { receiverUsername } = req.body
  try {
    //getting the receiver object
    const receiver = await User.findOne({ username: receiverUsername })
    //finding the conversation based on the ids
    const conversation = await Conversations.findOne({ userIDReceiver: receiver._id, userIDSender: req.userInfo._id })
    //removing the conversation id from the receivers array
    if (receiver.chats) {
      const index = receiver.chats.indexOf(conversation._id)
      if (index != -1) {
        receiver.chats.splice(index, 1)
      } //end if
    } //end if
    //removing the conversation id from the sender's array
    if (req.userInfo.chats) {
      const index = req.userInfo.chats.indexOf(conversation._id)
      if (index != -1) {
        req.userInfo.chats.splice(index, 1)
      } //end if
    } //end if
    //deleting the actual conversation
    await User.findOneAndUpdate({ _id: req.userInfo._id }, { chats: req.userInfo.chats })
    await User.findOneAndUpdate({ _id: receiver._id }, { chats: receiver.chats })
    await Conversations.findOneAndDelete({ _id: conversation._id })
    res.status(200).json({ msg: 'The conversation has been deleted' })
  } catch (e) {
    console.log(e.message)
    res.status(400).json({ msg: 'The conversation could not be deleted' })
  }
})

module.exports = router;