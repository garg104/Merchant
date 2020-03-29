require('dotenv').config()
import { config, getProfilePictureSchemas } from '../utils/fileHandling'
const express = require('express');
const router = express.Router();
const Item = require('../models/Items')
const User = require('../models/User')
let upload = config('item-pictures')

/**
 * this routes posts the items in the database
 * This is a temp route written to make the item databse so that I(chirayu) can write the get items route. 
 * This route is to be modified and finalized by Drew Keirn  
 */
router.post('/postItem', upload.array("data"), async (req, res) => {
  const { username, userID, title, description, price, category, isSold, university } = req.body
  
  //get the ids of all the pictures saved
  let picture = []
  req.files.forEach(file => picture.push(file.id))

  try {
    //create new item in the Database
    const item = new Item({ userID, title, description, price, picture, category, isSold, university })

    // saving the item in the database (save() is same as User.create)
    // add the item to the selling list of the user
    const savedItem = await item.save()
    const user = await User.find({ username })
    user[0].forSale.push(savedItem._id)
    const ret = await User.findOneAndUpdate({ username: username }, { forSale: user[0].forSale })


    //sending the response
    res.status(201).json({ item: savedItem, msg: 'Successfully Posted' })
  } catch (e) {
    //logging the errors
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
    res.status(200).json({ items })
  } catch (e) {
    res.status(404).json({ msg: e.message })
  }
});

router.get('/userSellingCurrent/:username', async (req, res) => {
  try {
    // get all items with isSold as false.
    console.log(req.params.username)
    const user = await User.find({ username: req.params.username })
    // console.log(user[0].forSale)
    let items = []
    user[0].forSale.forEach(async (item) => {
      const temp = await Item.findById({ _id: item })
      if (!temp.isSold) {
        items.push(temp)
      }
      if (item == user[0].forSale[user[0].forSale.length - 1]) {
        res.status(200).json({ items })
      }
    })
  } catch (e) {
    res.status(404).json({ msg: e.message })
  }
});

router.get('/userSellingHistory', async (req, res) => {
  try {
    // get all items with isSold as true.
    const user = await User.find({ username: req.body.username })
    let items = []
    user[0].sellingHistory.forEach(async (item) => {
      const temp = await Item.findById({ _id: item })
      if (temp.isSold) {
        items.push(temp)
      }
      if (item == user[0].sellingHistory[user[0].sellingHistory.length - 1]) {
        res.status(200).json({ items })
      }
    })
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