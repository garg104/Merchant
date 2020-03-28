require('dotenv').config()
const express = require('express');
const router = express.Router();
const Item = require('../models/Items')
const User = require('../models/User')

/**
 * this routes posts the items in the database
 * This is a temp route written to make the item databse so that I(chirayu) can write the get items route. 
 * This route is to be modified and finalized by Drew Keirn  
 */
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

/**
 * Get all the items in the DB according the the algorithm
 * The algorithm is yet to be decided.
 */
router.get('/allItems', async (req, res) => {
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

router.get('/userSellingCurrent', async (req, res) => {
  try {
    // get all items with isSold as false.
    const items = await Item.find({ isSold: false, userID: req.body.userID })
    // items.filter({

    // })
    res.status(200).json({ items })
  } catch (e) {
    res.status(404).json({ msg: e.message })
  }
});

router.get('/userSellingHistory', async (req, res) => {
  try {
    // get all items with isSold as false.
    const items = await Item.find({ isSold: true, userID: req.body.userID })
    // items.filter({

    // })
    res.status(200).json({ items })
  } catch (e) {
    res.status(404).json({ msg: e.message })
  }
});


/**
 * Search for a list of items based on the query string
 */
router.get('/search/:username/:query', async (req, res, next) => {
  const { query, username } = req.params

  let userId;
  try {
    user = await User.findOne({ username: username })
    userId = user._id
  } catch (e) {
    res.status(400).json({ msg: "User not found" })
  } //end try-catch

  try {
    //looking up the users by matching the search query on first name, last name, and username fields
    let itemsByTitle = await Item.find({
      "title": { $regex: `${query}`, $options: 'i' },
      isSold: false,
      userID: { $ne: userId }
    })
    let itemsByDescription = await Item.find({
      "description": { $regex: `${query}`, $options: 'i' },
      isSold: false,
      userID: { $ne: userId }
    })
    let itemsByCategory = await Item.find({
      "category": { $regex: `${query}`, $options: 'i' },
      isSold: false,
      userID: { $ne: userId }
    })

    //getting rid of duplicate matchings
    let mySet = new Set()

    //add all the elements of the three arrays to the set
    itemsByTitle.forEach((u) => mySet.add(JSON.stringify(u)))
    itemsByDescription.forEach((u) => mySet.add(JSON.stringify(u)))
    itemsByCategory.forEach((u) => mySet.add(JSON.stringify(u)))

    //push all the unique elements in the set to the final array
    let finalItemsList = [];
    mySet.forEach(u => { finalItemsList.push(JSON.parse(u)) })

    //send an appropriate success reponse to the client
    res.status(200).json({ items: finalItemsList, msg: "Items successfully listed" })
  } catch (e) {
    console.log(e)
    res.status(404).json({ items: [], msg: "No items found" })
  } //end try-catch
})

module.exports = router;

