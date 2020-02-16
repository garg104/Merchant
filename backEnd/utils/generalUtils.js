import { sgMail } from './sendgridConfig'

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
            return new Promise.resolve(msg.otp)
        })
        .catch((err) => {
            console.log(err)
            return new Promise.reject(err)
        })
} //sendEmail