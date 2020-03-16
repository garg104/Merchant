require('dotenv').config()
import { generateOtpMsg, sendEmail, generateTempPassword, generateResetPassword, generateDeleteAcctMsg } from '../utils/sendEmail'
const jwt = require('jsonwebtoken')
const bcrypt = require('bcryptjs')
const User = require('../models/User')
const express = require('express');
const router = express.Router();
import { config, getProfilePictureSchemas, parseFileData } from '../utils/fileHandling'
const upload = config()
const randomstring = require('../node_modules/randomstring')

router.get('/', async (req, res) => {
    try {
      //get all the users in the DB
      const users = await User.find({})
      res.status(200).json({ users })
    } catch (e) {
      res.status(404).json({ msg: e.message })
    }
  });

  module.exports = router;  

