require('dotenv').config()
const express = require('express');
const router = express.Router();
const Item = require('../models/Items')

// this routes posts the items in the database
// This is a temp route written to make the item databse so that I(chirayu) can write the get items route. 
// This route is to be modified and finalized by Drew Keirn 
router.post('/postItem', async (req, res) => {
  const { userID, title, description, price, picture, category, isSold, university } = req.body
  try {
    //create new item in the Database
    const item = new Item({ userID, title, description, price, picture, category, isSold, university })
    //saving the item in the database (save() is same as User.create)
    const savedItem = await item.save()
    res.status(201).json({ item: savedItem, msg: 'Successfully Posted' })
  } catch (e) {
    console.log(e)
    res.status(400).json({ msg: 'Cannot be Posted' })
  }
})

// get all the items in the DB according the the algorithm
// the algorithm is yet to be decided.
router.get('/', async (req, res) => {
  try {
    // get all items with isSold as false.
    const items = await Item.find({ isSold: false })
    // items.filter({

    // })
    res.status(200).json({ items })
  } catch (e) {
    res.status(404).json({ msg: e.message })
  }
});

module.exports = router;

