require('dotenv').config()
import { config, getItemPictureSchemas } from '../utils/fileHandling'
import { getFiles } from '../middlewares/middlewares';
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
    const item = new Item({ userID, username, title, description, price, picture, category, isSold, university })

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
router.get('/allItems/', async (req, res) => {
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

router.post('/removeItem', async (req, res) => {
  const { username, itemID } = req.body

  try {
    //get the corresponding user
    const user = await User.findOne({ username: username })
    //get the corresponding itemIndex in the items array
    const index = user.forSale.indexOf(itemID);
    if (index > -1) {
      //remove the item
      user.forSale.splice(index, 1)
    } else {
      //item couldn't be found
      res.status(400).json({ msg: "item could not be found in the user's forSale list" })
    }
    //delete the item and also update the corresponding user object
    let ret = await Item.findByIdAndDelete({ _id: itemID })
    let retVal = await User.findOneAndUpdate({ username: username }, { forSale: user.forSale })
    res.status(200).json({ msg: "item has been successfully removed" })
  } catch (e) {
    //logging errors
    console.log(e)
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
    const user = await User.findOne({ username: username })
    if (user)
      userId = user._id
    else
      return res.status(400).json({ msg: "User not found" })
  } catch (e) {
    console.log(e)
    return res.status(400).json({ msg: "User not found" })
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

/**
 * Route to get item pictures from DB
 */
router.get('/picture/:id', async (req, res, next) => {
  //get the id of the picture
  const { id } = req.params

  //get the schemas for items
  const { itemChunks } = getItemPictureSchemas()

  //in case there is no id, respond with an error
  if (!id) {
    return res.status(404).json({ msg: "The fileId was not found" })
  } //end if

  //setting up the request object for next middleware
  req.fileChunks = itemChunks
  req.fileId = id

  //calling the next middleware
  next()
}, getFiles)

/**
 * Route to delete a picture from the database
 */
router.delete('/picture/:id', async (req, res, next) => {
  //get the id of the picture
  const { id } = req.params

  //get the schemase for the items
  const { itemChunks, itemMetadata } = getItemPictureSchemas()

  //checking whether id is not null
  if (!id) {
    return res.status(404).json({ msg: 'requested id not found!' })
  } //end if

  try {
    //search for the picture and delete it from both the schemas
    await itemChunks.delete({ _id: id })
    await itemMetadata.delete({ _id: id })
  } catch (e) {
    //error handling
    console.error(e)
    res.status(400).json({ msg: 'Could not delete the picture' })
  }
})

module.exports = router;