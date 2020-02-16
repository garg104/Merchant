import { otpGenerator, sendEmail, generateEmailMsg } from '../utils/generalUtils'

var express = require('express');
var router = express.Router();

/* GET users listing. */
router.get('/', function (req, res, next) {
  res.send('respond with a resource');
});

/* Send an OTP to the client email */
router.post('/validate', async (req, res) => {
  const { email } = req.body
  const generatedOTP = otpGenerator()
  try {
    const ret = await sendEmail(generateEmailMsg(email, { otp: generatedOTP }))
    res.status(200).json({ otp: generatedOTP, ...ret.msg })
  } catch (err) {
    console.log(err)
    res.status(400).send(err)
  }
})


module.exports = router;
