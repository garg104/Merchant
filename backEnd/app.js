require('dotenv').config()

var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
var throwError = require('http-errors')

var indexRouter = require('./routes/index');
var usersRouter = require('./routes/users');

var app = express();

//connection to MongoDB: TODO


//initial configuration
app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());

//router integration
app.use('/', indexRouter);
app.use('/users', usersRouter);

//error handling
app.use((req, res, next) => {
    next(throwError('404', "Not found"))
});

//error handler
app.use((err, req, res, next) => {
    //only providing error message in development
    res.locals.message = err.message
    res.locals.error = req.app.get('env') === 'development' ? err : {};

    //rendering error response
    res.status(err.status || 500)
    res.send({ message: res.locals.message });
});

module.exports = app;
