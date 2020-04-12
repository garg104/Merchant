require('dotenv').config()
import { generateOtpMsg, sendEmail, generateTempPassword, generateResetPassword, generateDeleteAcctMsg } from '../utils/sendEmail'
import { getFiles, authenticate } from '../middlewares/middlewares'
const jwt = require('jsonwebtoken')
const bcrypt = require('bcryptjs')
const User = require('../models/User')
const Item = require('../models/Items')
const express = require('express');
const router = express.Router();
import { config, getProfilePictureSchemas } from '../utils/fileHandling'
const upload = config('profile-pictures')
const randomstring = require('../node_modules/randomstring')

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
    res.status(400).json({ msg: 'User cannot be created' })
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
router.post('/delete', async (req, res) => {
  const { username } = req.body
  try {
    const user = await User.findOne({ username });
    if (user == null) {
      res.status(404).json({ msg: "The user does not exist." })
    }

    // itterate through the Items and delete the Items if not sold i.e. for sale items.
    // NEED TO IMPLEMENT

    try {
      await User.deleteOne(user)
    } catch (e) {
      console.log(e)
      res.status(400).json({ msg: "The account could not be deleted. Please try again." })
    }
    const email = user.email
    try {
      await sendEmail(generateDeleteAcctMsg(email))
    } catch (e) {
      res.status(206).json({ msg: ": The account has been deleted but there was an error sending the confirmation email." })
    }
    res.status(200).json({ msg: "The specified user was deleted.", username: username })
  } catch (e) {
    res.status(400).json({ msg: "The account could not be deleted. Please try again." })
  }
  //make the call to the database

})

/* update user info */
router.put('/updateProfile', async (req, res) => {
  const { username, lastName, firstName, newUsername } = req.body
  try {
    // make sure that the user exists. This will always return true, as the user has to be logged in to call this route.
    // This can be removed, but is there for testing right now.
    const user = await User.findOne({ username })
    if (user == null) {
      console.log("the user does not exist")
      res.status(404).json({ msg: "Invalid user" })
    }

    if (newUsername == username) { // the user did not update username
      if (user.lastName != lastName) { // user updated the last name
        const ret = await User.findOneAndUpdate({ username: username }, { lastName: lastName })
      }
      if (user.firstName != firstName) { // user updated the first name
        const ret = await User.findOneAndUpdate({ username: username }, { firstName: firstName })
      }
      res.status(200).json({
        updated: {
          username: newUsername,
          firstName: firstName,
          lastName: lastName
        },
        msg: "The user settings have been updated"
      })
    } else { // the user updated username
      // Make sure that the newUsername is not alreay in use.
      const ifExists = await User.findOne({ username: newUsername })
      if (ifExists == null) { // newUsername does not exist
        if (user.lastName != lastName) { // user updated the last name
          const ret = await User.findOneAndUpdate({ username: username }, { lastName: lastName })
        }
        if (user.firstName != firstName) { // user updated the first name
          const ret = await User.findOneAndUpdate({ username: username }, { firstName: firstName })
        }
        const ret = await User.findOneAndUpdate({ username: username }, { username: newUsername })
        res.status(200).json({
          updated: {
            username: newUsername,
            firstName: firstName,
            lastName: lastName
          },
          msg: "The user settings have been updated"
        })
      } else {
        res.status(409).json({ msg: "Username already taken. Nothing was updated." })
      }
    }


  } catch (e) {
    //sending an error response
    console.log(e)
    res.status(400).json({ msg: "The user settings couldn't be updated" })
  }
})

/* get user info */
router.post('/info', async (req, res) => {
  try {
    const { username } = req.body
    const ret = await User.findOne({ username })
    ret._doc.password = "None of your business ;-)"
    res.status(200).json({ ...ret._doc })
  } catch (e) {
    res.status(404).json({ msg: "User couldn't be found" })
  }
})

/* upload the user profile */
router.post('/picture', upload.single("data"), async (req, res) => {
  try {
    //getting the fields from the file
    const { id, originalname } = req.file
    let username = originalname.substring(0, originalname.lastIndexOf('.'))

    //update the user schema with the image id
    const ret = await User.findOneAndUpdate({ username }, { picture: id })
  } catch (e) {
    //logging errors
    console.log(e)
    res.status(404).json({ msg: "User profile couldn't be updated" })
  } //end try-catch
  res.status(201).json({ file: req.file, msg: "User profile picture has been updated" })
})

/* getting the picture of the user from the database */
router.get('/picture/:username', async (req, res, next) => {
  //get the name of the user
  const { username } = req.params

  try {
    //fetching the fileId from the user schema
    const user = await User.findOne({ username: username })
    if (!user) { throw new Error("User not found") }
    const fileId = user.picture
    if (!fileId) {
      //if the user doesn't have a profile picture
      console.log("No profile picture found");
      res.status(400).json({ msg: "No profile picture found" })
    } else {
      //get the file from the fileChunks and fileMetadata
      const { fileChunks } = getProfilePictureSchemas();

      //appending variables to req for next middleware call
      req.fileChunks = fileChunks
      req.fileId = fileId

      //calling the next middleware
      next()
    } //end if
  } catch (e) {
    //logging errors
    res.status(404).json({ msg: "User not found" })
  } //end try-catch
}, getFiles)

/* check if the user exists and send a recovery email. */
router.post('/forgotPassword', async (req, res) => {
  const { username } = req.body
  try {
    const user = await User.findOne({ username })
    // the user does not exist
    if (user == null) {
      res.status(404).json({ msg: "User does not exist!" })
    }

    // find the email of the user from the database 
    const email = user.email

    // make sure that the user email is in the database.
    if (email.length == 0) {
      res.status(409).json({ msg: "User email could not be found!" })
    }

    let firstName = ""
    // make sure that the firstName exists
    if (user.firstName.length != 0) {
      firstName = user.firstName
    }

    // wait for the sendEmail funtion to return and send a valid response
    try {
      const password = randomstring.generate({
        length: 12,
        charset: 'alphanumeric'
      })

      // make sure that the new password follows the password strength rule.
      while (password.match(/[A-Z]/g) == null || password.match(/[a-z]/g) == null || password.match(/[0-9]/g) == null) {
        console.log(password)
        const password = randomstring.generate({
          length: 12,
          charset: 'alphanumeric'
        })
      }

      // Hashing the password before updating it in the database (check the resources page for more info)
      bcrypt.genSalt(10, (err, salt) => {
        //error checking
        if (err) { throw err }
        //hashing the password using the salt generated
        bcrypt.hash(password, salt, async (err, hash) => {
          //error handling
          if (err) {
            throw err
          }
          // updating the password in the database
          try {
            await User.findOneAndUpdate({ username }, { password: hash })
            //console.log(User.findOne({username}))
          } catch (e) {
            //logging errors
            res.status(500).json({ msg: 'Password could not be updated on the DB!' })
          }
        })
      })
      // wait for the sendEmail funtion to return and send a valid response
      await sendEmail(generateTempPassword(email, firstName, password))
      res.status(200).json({ msg: "Email sent successfully" })
    } catch (err) {
      res.status(400).json({ msg: "Email couldn't be sent successfully" })
    }
  } catch (e) {
    console.log(e)
    res.status(417).json({ msg: "Please try again!" })
  }
})

/* resets the password of a user */
router.post('/resetPassword', async (req, res) => {
  const { username, password, newPassword } = req.body
  console.log(username)
  try {
    const user = await User.findOne({ username })
    // the user does not exist
    console.log(user)
    if (user == null) {
      res.status(404).json({ msg: "User does not exist!" })
    }

    // find the email of the user from the database 
    const email = user.email
    console.log(email)

    // make sure that the user email is in the database.
    if (email.length == 0) {
      res.status(409).json({ msg: "User email could not be found!" })
    }

    let firstName = ""
    // make sure that the firstName exists
    if (user.firstName.length != 0) {
      firstName = user.firstName
    }

    try {
      bcrypt.compare(password, user.password, async (err, isMatching) => {
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
        try {
          // Hashing the password before updating it in the database (check the resources page for more info)
          bcrypt.genSalt(10, (err, salt) => {
            //error checking
            if (err) {
              throw err
            }
            //hashing the password using the salt generated
            bcrypt.hash(newPassword, salt, async (err, hash) => {
              //error handling
              if (err) {
                throw err
              }
              // updating the password in the database
              try {
                console.log(hash)
                await User.findOneAndUpdate({ username }, { password: hash })
                //console.log(User.findOne({username}))
              } catch (e) {
                //logging errors
                console.log(e)
                res.status(500).json({ msg: 'Password could not be updated on the DB!' })
              }
            })
          })
          await sendEmail(generateResetPassword(email, firstName))
          res.status(200).json({ msg: "Email sent successfully" })
        } catch (e) {
          console.log(e)
          res.status(400).json({ msg: "Email couldn't be sent successfully" })
        }
      })
    } catch (err) {
      res.status(500).json({ msg: 'Password could not be reset!' })
    }
  } catch (e) {
    console.log(e)
    res.status(417).json({ msg: "Please try again!" })
  }
})

/* route for getting the list of users based on the search query */
router.get('/search/:query', async (req, res, next) => {
  const { query } = req.params
  try {
    //looking up the users by matching the search query on first name, last name, and username fields
    let usersByUserName = await User.find({ "username": { $regex: `^[^ \t\n]*${query}[^ \t\n]*$`, $options: 'i' } })
    let usersByFirstName = await User.find({ "firstName": { $regex: `^[^ \t\n]*${query}[^ \t\n]*$`, $options: 'i' } })
    let usersByLastName = await User.find({ "lastName": { $regex: `^[^ \t\n]*${query}[^ \t\n]*$`, $options: 'i' } })

    //getting rid of duplicate matchings
    let mySet = new Set()

    //add all the elements of the three arrays to the set
    usersByFirstName.forEach((u) => mySet.add(JSON.stringify(u)))
    usersByLastName.forEach((u) => mySet.add(JSON.stringify(u)))
    usersByUserName.forEach((u) => mySet.add(JSON.stringify(u)))

    //push all the unique elements in the set to the final array
    let finalUserList = [];
    mySet.forEach(u => { finalUserList.push(JSON.parse(u)) })

    //send an appropriate success reponse to the client
    res.status(200).json({ users: finalUserList, msg: "Users successfully listed" })
  } catch (e) {
    console.log(e)
    res.status(404).json({ users: [], msg: "No user found" })
    User.deleteMany({ _id: { $in: [] } })
  } //end try-catch
})

router.post('/wishlist', authenticate, async (req, res) => {
  const idItem = req.body.id
  //check if the item id has been passed in the body or not
  if (!idItem) {
    res.status(400).json({ msg: 'User id not found in the request' })
    return
  } //end if
  try {
    //add the item id to the wishlist array
    if (req.userInfo.wishlist.indexOf(idItem) === -1)
      req.userInfo.wishlist.push(idItem)
    //update the DB schema
    await User.update({ _id: req.userInfo._id }, { wishlist: req.userInfo.wishlist })
    res.status(200).json({ wishlist: req.userInfo.wishlist, msg: 'The item has been added to the wishlist' })
  } catch (e) {
    res.status(401).json({ msg: e.message })
  } //end try-catch
})

router.get('/wishlist', authenticate, async (req, res) => {
  if (req.userInfo) {
    if (req.userInfo.wishlist) {
      let wishlist = []
      //retreiving all the images from the database and sorting them
      await Promise.all(req.userInfo.wishlist.map(async itemId => {
        //retreiving items from the database and adding them to the array
        return new Promise(async (resolve, reject) => {
          //looking up the item and adding to the database
          try {
            const item = await Item.findById(itemId)
            if (item)
              wishlist.push(item)
            resolve()
          } catch (e) {
            console.log(e)
            reject()
          }
        })
      }))
      res.status(200).json({ wishlist: wishlist, msg: 'The wishlist has been found' })
    } else {
      res.status(400).json({ msg: 'The wishlist could not be found' })
    } //end if
  } else {
    res.status(404).json({ msg: 'The user could not be found' })
  } //end if
})

module.exports = router;
