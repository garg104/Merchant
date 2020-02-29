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
    try {
        const apiRes = await sgMail.send(msg)
        return Promise.resolve({ msg: 'Email sent successfully' })
    } catch (e) {
        console.log('Email could not be sent')
        return Promise.reject({ ...e })
    }
} //sendEmail

/**
 * Generate a email for otp generation
 *
 * @author Aakarshit Pandey
 */

export const generateOtpMsg = (email, otp) => {
    return {
        to: `${email}`,
        from: 'merchant@gmail.com',
        subject: 'ATTENTION: Verify your merchant account',
        text: 'Hi,\n Thank you for creating an account on Merchant.' +
            `Please enter the following One Time Password on your app to verify your account: ${otp}` +
            '\nRegards,\nMerchant Team!',
    };
}

/**
 * Generate a email for otp generation
 *
 * @author Aakarshit Pandey
 */

export const generateDeleteAcctMsg = (email) => {
    return {
        to: `${email}`,
        from: 'merchant@gmail.com',
        subject: 'Account Deleted',
        text: 'Hi,\n Thank you for using Merchant. Your account has been deleted.' +
            '\nRegards,\nMerchant Team!', 
    };
}

/**
 * Generate a email for temp password
 *
 * @author Chirayu Garg
 */

export const generateTempPassword = (email, firstName, password) => {
    return {
        to: `${email}`,
        from: 'merchant@gmail.com',
        subject: 'ATTENTION: Temporary password. ',
        text: `Hi, ${firstName}\nYour temporary password is\n` + `${password}\n` + 
            `Please update your password from the User page after logging in using the above password.` +
            '\nRegards,\nMerchant Team!',
    };
}

/**
 * Generate a email for reset password
 *
 * @author Chirayu Garg
 */

export const generateResetPassword = (email, firstName) => {
    return {
        to: `${email}`,
        from: 'merchant@gmail.com',
        subject: 'ATTENTION: Password reset. ',
        text: `Hi, ${firstName}\nYour password has been reset.\n` + 
            '\nRegards,\nMerchant Team!',
    };
}


/**
 * Send an email with custom content
 *
 * @author Aakarshit Pandey
 */

export const generateEmailMsg = (email, opts) => {
    return {
        to: `${email}`,
        from: 'merchant@example.com',
        subject: opts.subject,
        text: opts.message,
        html: opts.html
    };
}

