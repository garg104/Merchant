import { generateOtpMsg, sendEmail } from '../utils/sendEmail'

var User = require('../models/User')
var express = require('express');
var router = express.Router();

/* GET users listing. */
router.get('/', function (req, res, next) {

});

/* Register */
router.post('/register', async (req, res) => {
  const { firstName, lastName, email, username, password, university } = req.body

  try {
    //checking the db for existing user
    const user = await User.find({ username })
    if (user.length === 0) {
      try {
        //create new user in the Database
        const user = await User.create({ firstName, lastName, email, username, password, university })
        res.status(201).json({ user: user, msg: 'Successfully Registered' })
      } catch (e) {
        //logging errors
        console.log(e)
        res.status(500).json({ msg: 'User could not be created' })
      }
    } else {
      //username already exists
      res.status(409).json({ msg: 'Username already exists' })
    }
  } catch (e) {
    //creating the new user
    console.log(e)
  }
})

/* Send an OTP to the client email */
router.post('/validate', async (req, res) => {
  //get the fields
  const { email, OTP } = req.body
  console.log(req.body)
  console.log(req.params)
  console.log(req.body.email)
  console.log(req.body.OTP)
  console.log(`Email: ${email} and OTP: ${OTP}`)
  const otp = OTP

  // wait for the sendEmail funtion to return and send a valid response
  try {
    const ret = await sendEmail(generateOtpMsg(email, otp))
    res.status(200).json({ msg: "Email sent successfully" })
  } catch (err) {
    res.status(400).json({ msg: "Email couldn't be sent successfully" })
  }
})

module.exports = router;
