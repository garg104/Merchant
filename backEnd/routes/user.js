import { generateOtpMsg, sendEmail } from '../utils/sendEmail'

const bcrypt = require('bcryptjs')
const User = require('../models/User')
const express = require('express');
const router = express.Router();

/* GET users listing. */
router.get('/', async (req, res) => {
  try {
    //get all the users in the DB
    const users = await User.find({})
    res.status(200).json({ users })
  } catch (e) {
    res.status(404).json({ msg: e.message })
  }
});

/* Register */
router.post('/register', async (req, res) => {
  const { firstName, lastName, email, username, password, university } = req.body

  try {
    //checking the db for existing user
    const checkUser = await User.find({ username })
    if (checkUser.length === 0) {
      //create new user in the Database
      const user = new User({ firstName, lastName, email, username, password, university })

      //Hashing the password before saving it in the database (check the resources page for more info)
      bcrypt.genSalt(10, (err, salt) => {
        //error checking
        if (err) { throw err }
        //hashing the password using the salt generated
        bcrypt.hash(user.password, salt, async (err, hash) => {
          //error handling
          if (err) { throw err }

          //assigning the hashed password to the user object
          user.password = hash
          try {
            //saving the user in the database (save() is same as User.create)
            const savedUser = await user.save()
            res.status(201).json({ user: savedUser, msg: 'Successfully Registered' })
          } catch (e) {
            //logging errors
            console.log(e)
            res.status(500).json({ msg: 'User could not be created' })
          }
        })
      })
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
