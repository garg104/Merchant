import { otpGenerator } from '../utils/generalUtils'

var User = require('../models/User')
var express = require('express');
var router = express.Router();

/* GET users listing. */
router.get('/', function (req, res, next) {

});

/* Send an OTP to the client email */
router.get('/validate', async (req, res) => {
  const { email } = req.body
  const generatedOTP = otpGenerator()
  try {
    const ret = await sendEmail(generateEmailMsg(email, { otp: generatedOTP }))
    res.status(200).json({ otp: generatedOTP, ...ret.msg })
  } catch (err) {
    console.log(err)
    res.status(400).json({ msg: "Email couldn't be sent, try again" })
  }
})

module.exports = router;
