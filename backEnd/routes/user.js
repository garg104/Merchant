require('dotenv').config()

import { generateOtpMsg, sendEmail } from '../utils/sendEmail'
const jwt = require('jsonwebtoken')
const bcrypt = require('bcryptjs')
const User = require('../models/User')
const express = require('express');
const router = express.Router();

/* GET users listing. (for debugging) */
router.get('/', async (req, res) => {
  try {
    //get all the users in the DB
    const users = await User.find({})
    res.status(200).json({ users })
  } catch (e) {
    res.status(404).json({ msg: e.message })
  }
});

/**
 * Routes for registering the new user
 * has routes for sending the OTP
 * to the user and registering them
 */

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

  // wait for the sendEmail funtion to return and send a valid response
  try {
    const ret = await sendEmail(generateOtpMsg(email, OTP))
    res.status(200).json({ msg: "Email sent successfully" })
  } catch (err) {
    res.status(400).json({ msg: "Email couldn't be sent successfully" })
  }
})

/* Login the user and send a legitimate JWT token */
router.post('/login', (req, res) => {
  //get the fields from the request body
  const { username, password } = req.body
  //find the user in the database
  User.findOne({ username })
    .then((dbUser) => {
      if (!dbUser) {
        //if the username couldn't be found, return a 404
        res.status(404).json({ msg: "Username couldn't be found" })
      }

      //compare the password from the database with the client-provided password
      bcrypt.compare(password, dbUser.password, (err, isMatching) => {
        if (err) {
          //error checking
          console.log(err)
          res.status(501).json({ msg: "Internal server error" })
        }
        //if the passwords don't match, return error
        if (!isMatching) {
          res.status(401).json({ msg: "Passwords don't match" })
          return
        }

        //define a payload to be attached to the JWT (more info: https://jwt.io/introduction/)
        const payload = {
          id: dbUser.id,
          username: dbUser.username,
          firstName: dbUser.firstName,
          lastName: dbUser.lastName,
        }

        //signing the jwt using the payload and encryption key
        jwt.sign(payload, process.env.JWT_KEY, { expiresIn: 31556926 }, (err, token) => {
          if (err) {
            //handle error if jwt doesn't get signed
            console.log(err)
            res.status(500).json({ msg: "Login failed, please try again" })
            return;
          }
          //signing jwt successful, append it to the response json
          res.status(200).json({
            token: token,
            msg: `Welcome to Merchant, ${dbUser.firstName}!`
          })
        })
      })
    })
})

/* Delete user */
router.delete('/delete', async (req, res) => {
  try {
    //getting the fields
    const { username } = req.body
    //checking if the client sent a proper response
    if (username.length == 0) {
      res.status(404).json({ msg: "The username is empty" })
      return
    }
    //make the call to the database
    await User.deleteOne({ username })
    res.status(200).json({ msg: "The specified user was deleted.", username: username })
  } catch (err) {
    res.status(404).json({ msg: "The specified user could not be found." })
  }
})

/* update user info */
router.put('/', async (req, res) => {
  try {
    //finding the user update the info
    //here update is a JSON which contains all the info to be updated
    const ret = await User.findOneAndUpdate({ username: req.body.username }, { ...req.body.update })
    console.log(req.body)
    //sending a response to the user
    res.status(200).json({ updated: { ...req.body.update }, msg: "The user settings have been updated" })
  } catch (e) {
    //sending an error response
    console.log(e)
    res.status(400).json({ msg: "The user settings couldn't be updated" })
  }
})

module.exports = router;