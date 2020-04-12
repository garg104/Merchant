import { downloadConfig } from './utils/fileHandling'

require('dotenv').config()

const express = require('express');
const path = require('path');
const cookieParser = require('cookie-parser');
const logger = require('morgan');
const throwError = require('http-errors')
const passport = require('passport')
const Grid = require('gridfs-stream')
const multer = require('multer')

const indexRouter = require('./routes/index');
const userRouter = require('./routes/user');
const itemsRouter = require('./routes/items');
const mongoose = require('mongoose')

const app = express();

//connection to MongoDB Atlas
mongoose.connect(process.env.DB_CONNECTION, { useNewUrlParser: true, useUnifiedTopology: true, useFindAndModify: true }, (err) => {
    console.log(err ? err.message : "connected to the database")
})

//Add the file upload settings
let gfs;
const db = mongoose.connection
db.once('open', () => {
    //grid-fs settings
    gfs = Grid(db.db, mongoose.mongo);
    gfs.collection('profile-pictures')

    //file-download setup
    downloadConfig(db)
})

//setup passport for JWT authentication
app.use(passport.initialize())

//passport config
require('./utils/passport')(passport)

//initial configuration
app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());

//router integration
app.use('/', indexRouter);
app.use('/user', userRouter);
app.use('/items', itemsRouter);

//error handling
app.use((req, res, next) => {
    next(throwError('404', "Not found"))
});

//error handler
app.use((err, req, res, next) => {
    //only providing error message in development
    res.locals.message = err.message
    res.locals.error = req.app.get('env') === 'dev' ? err : {};

    //rendering error response
    res.status(err.status || 500)
    res.json({ msg: res.locals.message });
});

module.exports = app;
