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

/* Getting the meeting location for a conversation id */
router.get('/meetingLocation/:id', async (req, res) => {
  const { id } = req.params
  try {
    //getting the conversation
    const conversation = await Conversations.findById(id)
    if (conversation.meeting) {
      //getting the corresponding location
      const location = await Location.findById(conversation.meeting)
      //sending the response
      res.status(200).json({ location, msg: 'The meeting location has been found' })
    } else {
      //no meeting location found
      res.status(404).json({ msg: 'Not meeting location stored yet' })
    } //end if
  } catch (e) {
    //logging errors
    res.status(400).json({ msg: 'wrong conversation id supplied' })
  }
})

/* Route for adding a meeting location for the conversation */
router.post('/meetingLocations', authenticate, async (req, res) => {
  const { id, latitude, longitude, address, title, receiverUsername } = req.body
  console.log(id)
  try {
    const conversation = await Conversations.findOne({ _id: id })

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
        console.log(latitude, longitude, address, title)
        const location = new Location({ latitude, longitude, address, title })
        const savedLocation = await location.save()
        if (conversation.meeting) {
          //deleting the old location
          await Location.findByIdAndDelete(conversation.meeting)
        }
        conversation.meeting = savedLocation._id
        await Conversations.findByIdAndUpdate(id, { meeting: conversation.meeting })
        //sending the push notification
        const ret = await dispatchAPNViaFirebase(req.userInfo.username,
          receiverUsername,
          `${req.userInfo.username} has updated the meeting location`)
        pusher.trigger(channelName, 'map-location', { "location": location });
        res.status(200).json({ location, msg: "Location has been saved" })
      } catch (e) {
        console.log(e.message)
        res.status(400).json({ msg: "Location couldn't be updated" })
      } //end try-catch
    } else {
      res.status(404).send({ msg: 'Could not find a conversation' })
    }
  } catch (e) {
    console.log(e.message)
    res.status(401).json({ msg: e.message })

  }
})

/* Route for adding a meeting location for the conversation */
router.post('/sendCurrentLocation', authenticate, async (req, res) => {
  const { latitude, longitude, address, title, receiverUsername } = req.body
  try {
    // const conversation = await Conversations.findOne({ _id: id })

    //create a pusher instance
    let pusher = new Pusher({
      appId: '988508',
      key: '0abb5543b425a847ea81',
      secret: '28b34e176e9568cd6048',
      cluster: 'us2',
      encrypted: true
    });

    let channelName = req.userInfo.username + '-' + receiverUsername + '-maps-current'

    // if (conversation) {
    try {
      console.log(latitude, longitude, address, title)
      const location = new Location({ latitude, longitude, address, title })
      const savedLocation = await location.save()
      //sending the push notification
      const ret = await dispatchAPNViaFirebase(req.userInfo.username,
        receiverUsername,
        `${receiverUsername} has updated their current location`)
      pusher.trigger(channelName, 'map-location-current', { "location": location });
      res.status(200).json({ location, msg: "Location has been sent" })
    } catch (e) {
      console.log(e.message)
      res.status(400).json({ msg: "Location couldn't be sent" })
    } //end try-catch
    // } else {
    //   res.status(404).send({ msg: 'Could not find a conversation' })
    // }
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

router.post('/deleteConversation', authenticate, async (req, res) => {
  const { id, toDeleteUsername } = req.body
  try {
    //finding the userID of the user
    const user = await User.findOne({ username: toDeleteUsername })
    const toDeleteUserID = user._id
    //finding the conversation based on the ids
    const conversation = await Conversations.findById(id)
    //getting the receiver object
    const user1 = await User.findById(conversation.user1)
    const user2 = await User.findById(conversation.user2)
    //removing the conversation id from the receivers array
    let refCountOfChat = 2
    let user1Changed = false
    let user2Changed = false
    if (user1.chats) {
      const index = user1.chats.indexOf(id)
      if (index != -1) {
        if (user1._id == toDeleteUserID) {
          user1.chats.splice(index, 1)
          refCountOfChat--;
          user1Changed = true
        }
      } else {
        refCountOfChat--;
      }//end if
    } else {
      refCountOfChat--;
    }//end if
    //removing the conversation id from the sender's array
    if (user2.chats) {
      const index = user2.chats.indexOf(id)
      if (index != -1) {
        if (user2._id == toDeleteUserID) {
          user2.chats.splice(index, 1)
          refCountOfChat--;
          user2Changed = true
        }
      } else {
        refCountOfChat--;
      }//end if
    } else {
      refCountOfChat--;
    }//end if
    //deleting the actual conversation
    if (user1Changed)
      await User.findOneAndUpdate({ _id: user1._id }, { chats: user1.chats })
    if (user2Changed)
      await User.findOneAndUpdate({ _id: user2._id }, { chats: user2.chats })
    //deleting the meeting location if exists
    if (refCountOfChat === 0) {
      console.log('deleting the actual conversation')
      if (conversation.meeting) {
        try {
          //deleting the meeting location
          await Location.findByIdAndDelete(conversation.meeting)
        } catch (e) {
          console.log(e)
        }
      } //end if
      await conversation.delete()
    } //end if
    res.status(200).json({ msg: 'The conversation has been deleted' })
  } catch (e) {
    console.log(e.message)
    res.status(400).json({ msg: 'The conversation could not be deleted' })
  }
})

module.exports = router;