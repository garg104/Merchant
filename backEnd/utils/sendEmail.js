/**
 * Configure emailing sevice using sendgrid
 *
 * @author Chirayu Garg
 */
require('dotenv').config()
const sgMail = require('@sendgrid/mail')
sgMail.setApiKey(process.env.SEND_GRID_API_KEY)

// there is a way to add photos and customize the email we send of the SendGrid website.


/**
 * Generate the OTP which will be sent to the client-side
 * 
 * @author Domenic Conversa
 */
export const otpGenerator = () => {
    //TODO
    return 0;
} //otpGenerator

/**
 * Send an email to the mentioned email address
 *
 * @author Aakarshit Pandey
 */
export const sendEmail = async (msg) => {
    sgMail
        .send(msg)
        .then(() => {
            return new Promise.resolve({ msg: 'Email sent successfully' })
        })
        .catch((err) => {
            console.log(err)
            return new Promise.reject(err)
        })
} //sendEmail

/**
 * Generate a email for otp generation
 *
 * @author Aakarshit Pandey
 */

export const generateEmailMsg = (email, opts) => {
    return {
        to: `${email}`,
        from: 'merchant@example.com',
        subject: opts.subject || 'ATTENTION: Verify your merchant account',
        text: opts.message || 'Hi,\n Thank you for creating an account on Merchant.' +
            `Please enter the following One Time Password on your app to verify your accont: ${opts.otp}` +
            '\nRegards,\nMerchant Team!',
        html: opts.html || `<p>${message}</p>`,
    };
}

/**
 * Generate a email for otp generation
 *
 * @author Aakarshit Pandey
 */

export const generateDeleteAcctMsg = (email, opts) => {
    return {
        to: `${email}`,
        from: 'merchant@example.com',
        subject: opts.subject || 'ATTENTION: Verify your merchant account',
        text: opts.message || 'Hi,\n Thank you for creating an account on Merchant.' +
            `Please enter the following One Time Password on your app to verify your accont: ${opts.otp}` +
            '\nRegards,\nMerchant Team!',
        html: opts.html || `<p>${message}</p>`,
    };
}
