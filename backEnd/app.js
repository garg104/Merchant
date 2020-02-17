require('dotenv').config()

const express = require('express');
const path = require('path');
const cookieParser = require('cookie-parser');
const logger = require('morgan');
const throwError = require('http-errors')
const passport = require('passport')

const indexRouter = require('./routes/index');
const userRouter = require('./routes/user');
const mongoose = require('mongoose')

const app = express();

//connection to MongoDB Atlas
mongoose.connect(process.env.DB_CONNECTION, { useNewUrlParser: true, useUnifiedTopology: true }, () => {
    console.log("connected to the database")
})

//ADD database schemas: TODO


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
