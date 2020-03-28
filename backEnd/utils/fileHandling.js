const multer = require('multer')
const crypto = require('crypto')
const GridFsStorage = require('multer-gridfs-storage')
const path = require('path');

/**
 * Setting up multer and grid-fs for image upload.
 */
export const config = () => {
    const storage = new GridFsStorage({
        url: process.env.DB_CONNECTION,
        cache: true, //check the functionality
        file: (req, file) => {
            return new Promise((resolve, reject) => {
                crypto.randomBytes(16, (err, buf) => {
                    if (err) {
                        console.log(err)
                        return reject(err);
                    }
                    const filename = buf.toString('hex') + path.extname(file.originalname);
                    const fileInfo = {
                        filename: filename,
                        bucketName: 'profile-pictures'
                    };
                    resolve(fileInfo);
                });
            });
        }
    });

    return multer({ limits: { fieldSize: 1024 * 1024 * 15 }, storage });
}


/**
 * Getting multer and gridfs config for image download
 */
let fileMetadata;
let fileChunks;
export const downloadConfig = (db) => {
    //getting the fileMetadata and chunks schemas
    fileMetadata = db.collection('profile-pictures.file')
    fileChunks = db.collection('profile-pictures.chunks')
}

/**
 * Export the schemas obtained from config function
 */
export const getProfilePictureSchemas = () => {
    return {
        fileMetadata,
        fileChunks
    }
}

/**
 * Function to parse the image data
 * To base64 format
 */
export const parseFileData = (fileChunks) => {
    //coalesce the chunks into single file data
    let fileData = []
    fileChunks.forEach((chunk) => {
        //push the data to the array in base64 encoded string format
        fileData.push(chunk.data.toString('base64'))
    })
    //convert the data to base64 encoded imageURI
    const imageURI = 'data:image/jpeg' + ';base64, ' + fileData.join('')

    return imageURI
}