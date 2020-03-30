const multer = require('multer')
const crypto = require('crypto')
const GridFsStorage = require('multer-gridfs-storage')
const path = require('path');

/**
 * Setting up multer and grid-fs for image upload.
 */
export const config = (bucketName) => {
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
                        bucketName: bucketName
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
let itemMetadata;
let itemChunks;
export const downloadConfig = (db) => {
    //getting the profileMetadata and chunks schemas
    fileMetadata = db.collection('profile-pictures.file')
    fileChunks = db.collection('profile-pictures.chunks')
    itemMetadata = db.collection('item-pictures.files')
    itemChunks = db.collection('item-pictures.chunks')
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
 * Export the schemas obtained from the config function
 */
export const getItemPictureSchemas = () => {
    if (!itemChunks) {
        console.log('itemChunks is null')
    }
    return {
        itemMetadata,
        itemChunks
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

/**
 * Function to remove images from backend
 * 
 * @param ids: array of file ids
 * @param type: specify the type of file
 */
export const removeFiles = async (ids, type) => {
    return new Promise(async (resolve, reject) => {
        let chunks = null
        let metadata = null

        if (`${type}`.localeCompare('items') == 0) {
            chunks = itemChunks
            metadata = itemMetadata
        } else if (`${type}`.localeCompare('profile-pictures') == 0) {
            chunks = fileChunks;
            metadata = fileMetadata
        } else {
            reject({ msg: 'incorrect method call' })
        } //end if

        //deleting all the chunks from the database
        try {
            const ret = await chunks.deleteMany({ files_id: { $in: [...ids] } })
        } catch (e) {
            console.error(e)
            reject({ msg: 'chunk deletion failed' })
        } //end try-catch

        //deleting all the metadata from the database
        try {
            const ret = await metadata.deleteMany({ _id: { $in: [...ids] } })
        } catch (e) {
            console.error(e)
            reject({ msg: 'metadata deletion failed' })
        } //end try-catch

        //removal successful: return success message
        resolve({ msg: 'file deletion successful' })
    })
}