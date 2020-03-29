const app = require('../app')
const supertest = require('supertest')
const request = supertest(app)

//Testing the get '/user' endpoint
describe('\nUtility tests\n', () => {
    it('Gets all the users', async done => {
        //Sends request to /user endpoint
        const res = await request.get('/user')
        expect(res.status).toBe(200)
        done()
    }, 10000)

    it('\nMail: Legit emails\n', async done => {
        //send request to the /validate endpoint
        const res = await request.post('/user/validate').send({ OTP: "0000", email: 'aakarshit_p@yahoo.com' })
        expect(res.status).toBe(200)
        expect(res.body.msg).toBe('Email sent successfully')
        done()
    }, 10000)

    it('\nMail: Illegitimate emails\n', async done => {
        //send request to the /validate endpoint
        const res = await request.post('/user/validate').send({ OTP: "0000", email: 'xyz.com' })
        expect(res.status).toBe(400)
        expect(res.body.msg).toBe("Email couldn't be sent successfully")
        done()
    }, 10000)
})

//Testing the register route
describe('\nAuthentication tests\n', () => {
    it('Tests the register route abortion on duplicate username', async done => {
        //Tests the route
        const res = await request.post('/user/register').send({ username: 'pandey25', email: 'pandey25@purdue.edu' })
        expect(res.status).toBe(409)
        expect(res.body.msg).toBe('Username already exists')
        done()
    }, 10000)

    it('Login: correct creds', async done => {
        //Testing the route
        const res = await request.post('/user/login').send({ username: 'pandey25', password: 'Test123' })
        expect(res.status).toBe(200)
        done()
    })

    it('Login: incorrect creds', async done => {
        //Testing the route
        const res = await request.post('/user/login').send({ username: 'pandey25', password: 'test123' })
        expect(res.status).toBe(401)
        expect(res.body.msg).toBe("Passwords don't match")
        done()
    })
})

//Testing the get picture route
describe('\nTests for picture\n', () => {
    it('Tests the picture route for a legitimate user', async done => {
        //Test the route
        const res = await request.get('/user/picture/pandey25')
        expect(res.status).toBe(200)
        done()
    }, 10000)

    //Testing the get picture route
    it('Tests the picture route for no data', async done => {
        //Test the route
        const res = await request.get('/user/picture/test')
        expect(res.status).toBe(404)
        done()
    }, 10000)
})

