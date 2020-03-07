const multer = require('multer')
const crypto = require('crypto')
const GridFsStorage = require('multer-gridfs-storage')
const path = require('path');

export const config = () => {
    const storage = new GridFsStorage({
        url: process.env.DB_CONNECTION,
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

    return multer({ storage, limits: { fieldSize: 25 * 1024 * 1024, fileSize: 5 * 1000000 } });
}