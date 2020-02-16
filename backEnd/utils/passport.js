require('dotenv').config()

let extractJWT = require('passport-jwt').ExtractJwt
let JWTStrategy = require('passport-jwt').Strategy

let opts = {}
opts.jwtRecieved = extractJWT.fromAuthHeaderAsBearerToken();
opts.secret = process.env.SECRET || 'secret';

module.exports = passport => {
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