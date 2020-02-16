require('dotenv').config()

let extractJWT = require('passport-jwt').ExtractJwt
let JWTStrategy = require('passport-jwt').Strategy

let opts = {}

//get the JWT as bearer token
opts.jwtRecieved = extractJWT.fromAuthHeaderAsBearerToken();

//get the secret key from the environment variable
opts.secret = process.env.SECRET || 'secret';

//setting up the JWT authentication strategy
module.exports = (passport) => {
    passport.use(
        new JWTStrategy(opts, (jwt_payload, done) => {
            User.findById(jwt_payload.id)
                .then(user => {
                    if (user) {
                        return done(null, user)
                    }
                    return done(null, false)
                })
                .catch(err => console.log(err))
        })
    )
}