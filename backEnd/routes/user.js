import { generateOtpMsg, sendEmail } from '../utils/sendEmail'

var User = require('../models/User').default
var express = require('express');
var router = express.Router();

/* GET users listing. */
router.get('/', function (req, res, next) {

});

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
