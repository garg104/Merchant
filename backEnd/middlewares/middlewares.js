import { parseFileData } from '../utils/fileHandling'

/**
 * Extra middleware functions to
 * serve as helpers for different routes
 */

/* middleware to get the image from the database */
export async function getFiles(req, res) {
    const { fileId, fileChunks } = req
    //retreiving chunks from the database and sorting them
    fileChunks.find({ files_id: fileId })
        .sort({ n: 1 }).toArray((err, chunks) => {
            if (err) {
                //error handling
                console.log(err)
                return res.status(406).json({ msg: "File Download error" })
            } else {
                const imageURI = parseFileData(chunks)
                //send the image data to the client
                res.status(200).send(imageURI);
            } //end if
        })
}

/* middleware to authenticate the access token in protected routes */
export async function authenticate(req, res, next) {
    console.log(`authenticating the request`)

    //call to passport for parsing the bearer token
    passport.authenticate('jwt', { session: false }, (err, user, info) => {
        if (err) {
            //passport error
            res.status(400).json({ msg: 'There was an autthentication error' });
            return
        }

        if (!user) {
            //token is invalid
            console.log(`invalid token`)
            res.status(404).json({ msg: 'Invalid Token.' })
            return
        }

        //if authentication is successfull, append the user data to res
        res.userInfo = user
        next()
    })(req, res, next)
}