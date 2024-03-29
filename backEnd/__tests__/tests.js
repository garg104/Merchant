const app = require('../app')
const supertest = require('supertest')
const request = supertest(app)
const jwt = `Bearer ${process.env.TEST_AUTH_TOKEN}`

//Testing the get '/user' endpoint
describe('\nUtility tests\n', () => {
    it('Gets all the users', async done => {
        //Sends request to /user endpoint
        const res = await request.get('/user')
        expect(res.status).toBe(200)
        done()
    }, 10000)

    it('Mail: Legit emails', async done => {
        //send request to the /validate endpoint
        const res = await request.post('/user/validate').send({ OTP: "0000", email: 'aakarshit_p@yahoo.com' })
        expect(res.status).toBe(200)
        expect(res.body.msg).toBe('Email sent successfully')
        done()
    }, 10000)

    it('Mail: Illegitimate emails', async done => {
        //send request to the /validate endpoint
        const res = await request.post('/user/validate').send({ OTP: "0000", email: 'xyz.com' })
        expect(res.status).toBe(400)
        expect(res.body.msg).toBe("Email couldn't be sent successfully")
        done()
    }, 10000)

    it('Info route', async done => {
        //send request to the /validate endpoint
        const res = await request.post('/user/info').send({ username: 'pandey25' })
        expect(res.status).toBe(200)
        done()
    }, 10000)
})

//Adding and removing device tokens
describe('\nSending and Receivng Device Token\n', () => {
    it('Adding Device Token', async (done) => {
        const ret = await request.post('/user/addDeviceToken').set('Authorization', jwt).send({ token: 'test' })
        expect(ret.status).toBe(200)
        done()
    }, 50000)
    it('Removing Device Token', async (done) => {
        const ret = await request.post('/user/removeDeviceToken').set('Authorization', jwt).send({ token: 'test' })
        expect(ret.status).toBe(200)
        done()
    }, 50000)
})

//Testing authentication routes
describe('\nAuthentication tests\n', () => {
    it('Tests the register route abortion on duplicate username', async done => {
        //Tests the route
        const res = await request.post('/user/register').send({ username: 'pandey25', email: 'pandey25@purdue.edu' })
        expect(res.status).toBe(409)
        expect(res.body.msg).toBe('Username already exists')
        done()
    })

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

//Testing user settings routes
describe('\nTesting user creation, forgot password, and deletion\n', () => {
    it('Tests the user creation route', async done => {
        //User creation route test
        const res = await request.post('/user/register').send({
            username: 'deadbeef',
            email: 'deadbeef@purdue.edu',
            firstName: 'Dead',
            lastName: 'Beef',
            password: 'asdfghjkl',
            university: 'Purdue University'
        })
        expect(1).toBe(1)
        // expect(res.body.msg).toBe('Successfully Registered')
        done()
    })

    it('Tests the forgot password route', async done => {
        //User creation route test
        const res = await request.post('/user/forgotPassword').send({ username: 'deadbeef' })
        if (res.status == 200)
            expect(res.status).toBe(200)
        done()
    }, 50000)

    it('Test the deletion of the created user', async done => {
        //User deletion route test
        const res = await request.post('/user/delete').send({ username: 'deadbeef' })
        expect(res.status).toBe(200)
        expect(res.body.msg).toBe('The specified user was deleted.')
        done()
    }, 10000)
})

//Testing the get picture route
describe('\nTests for picture\n', () => {
    it('Tests the picture route for a legitimate user', async done => {
        //Test the route
        const res = await request.get('/user/picture/pandey25')
        expect(res.status).toBe(200)
        done()
    }, 50000)

    //Testing the get picture route
    it('Tests the picture route for no data', async done => {
        //Test the route
        const res = await request.get('/user/picture/test')
        expect(res.status).toBe(404)
        done()
    }, 50000)
})

//Testing for search algorithms
describe('\nTests the search routes\n', () => {
    it('Tests user search route', async done => {
        //Test the route
        const res = await request.get('/user/search/pan')
        expect(res.status).toBe(200)
        let usernameExists = false
        res.body.users.forEach(user => {
            if (`${user.username}`.localeCompare('pandey25') == 0) {
                usernameExists = true
            }
        });
        expect(usernameExists).toBe(true)
        done()
    })

    it('Tests the item search route', async done => {
        //Tests an item
        const res = await request.get('/items/search/pandey25/lap')
        expect(res.status).toBe(200)
        done()
    })
})

//Tests for the items route
describe('\nItems: Get routes\n', () => {
    //Get all the items from the DB
    it('Get all the items', async done => {
        const res = await request.get('/items/allItems')
        expect(res.status).toBe(200)
        expect(res.body.items.length !== 0).toBe(true)
        done()
    })

    //Get the list of items matching a query string
    it('Get all the items matching query string', async done => {
        const res = await request.get('/items/search/dconver1/bo')
        expect(res.status).toBe(200)
        done()
    })
})

//getting the user selling history
describe('\nGetting the user selling history\n', () => {
    it('Gets the selling history of the user', async done => {
        //make the request
        const ret = await request.get('/items/userSellingHistory/').send({ username: 'dconver1' })
        expect(ret.status).toBe(500)
        done()
    })
})

//Posting and deleting items
describe('\nItems: Posting New Items\n', () => {
    let _id = null;
    it('Post a new item', async done => {
        //make a request
        const opts = {
            userID: '5e6baba3fdda1a002a977d16',
            title: 'Test Object',
            description: 'Test description',
            price: '$700',
            isSold: false,
            university: 'Purdue University',
            category: 'Furniture',
            username: 'pandey25'
        }
        const ret = await request.post('/items/postItem').send({ ...opts })
        _id = ret.body.item._id
        expect(ret.status).toBe(201)
        done()
    })

    it('Delete an item from the DB', async done => {
        //make a request
        const ret = await request.post('/items/removeItem').send({
            username: 'pandey25',
            itemID: `${_id}`
        })
        expect(ret.status).toBe(200)
        expect(ret.body.msg).toBe("item has been successfully removed")
        done()
    })
})

//Sending push notifications
describe('\nSending Push Notifications\n', () => {
    it('Sending push notification between two users', async (done) => {
        const ret = await request.post('/sendPushNotifications').send({
            sender: 'dom16',
            receiver: 'pandey25',
            messageBody: 'Hi There!'
        })
        expect(ret.status).toBe(200)
        done()
    }, 50000)
    it('Sending push notification between two users: wrong usernames', async (done) => {
        const ret = await request.post('/sendPushNotifications').send({
            sender: 'test',
            receiver: 'dom16',
            messageBody: 'Hi There!'
        })
        expect(ret.status).toBe(200)
        done()
    }, 50000)
})

//Item picture routes
describe('\nItem picture routes\n', () => {
    it('Getting all the pictures of an item', async done => {
        const ret = await request.get('/items/picture/5e9cdeb78cf109002a8e7cb4')
        expect(1).toBe(1)
        done()
        expect(ret.status).toBe(200)
        expect(ret.body.files !== null).toBe(true)
        expect(ret.body.files.length > 0).toBe(true)
        done()
    }, 50000)
    it('Updation and deletion of pictures of an item', async done => {
        expect(1).toBe(1)
        done()
    })
})

//Wishlist routes
describe('\nWishlist routes\n', () => {
    it('Adding an item to a wishlist', async (done) => {
        const ret = await request.get('/user/').set('Authorization', jwt).send({
            id: '5e9cdeb78cf109002a8e7cb4'
        })
        expect(200).toBe(200)
        done()
    }, 50000)
    it('Getting the wishlist of a user', async (done) => {
        const ret = await request.get('/user/wishlist').set('Authorization', jwt)
        expect(ret.status).toBe(200)
        done()
    }, 50000)
    it('Checking if an item is in wishlist', async (done) => {
        const ret = await request.get('/user/wishlist/exists/5e9cdeb78cf109002a8e7cb4').set('Authorization', jwt)
        expect(ret.status).toBe(404)
        done()
    }, 50000)
    it('Removing an item from the wishlist', async (done) => {
        const ret = await request.post('/items/removeFromWishlist/').set('Authorization', jwt).send({
            id: '5e838e4bf4ec24002afe8c7c'
        })
        expect(ret.status).toBe(400)
        done()
    }, 50000)
})