import { generateOtpMsg, sendEmail } from '../utils/sendEmail'

var User = require('../models/User').default
var express = require('express');
var router = express.Router();

/* GET users listing. */
router.get('/', function (req, res, next) {

});

/* Send an OTP to the client email */
router.get('/validate', async (req, res) => {
  //get the fields
  const { email, otp } = req.body

  // wait for the sendEmail funtion to return and send a valid response
  try {
    const ret = await sendEmail(generateOtpMsg(email, otp))
    res.status(200).json({ otp: otp, ...ret })
  } catch (err) {
    res.status(400).json({ msg: "OTP couldn't be sent" })
  }
})

module.exports = router;
