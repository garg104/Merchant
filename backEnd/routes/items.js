require('dotenv').config()
import { config, getItemPictureSchemas, removeFiles } from '../utils/fileHandling'
import { getManyFiles } from '../middlewares/middlewares';
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
  let { username, userID, title, description, price, isSold, university } = req.body

  //ensure that the isSold is false if nothing is passed
  if (!isSold) {
    isSold = false
  }

  //ensure that the correct userID is assigned if nothing is passed
  if (!userID) {
    const ret = await User.findOne({ username: username })
    userID = ret._id
  }

  // convert the category to integers to store in the database.
  let category = 0
  if (req.body.category == "Electronics") {
    category = 1
  } else if (req.body.category == "School supplies") {
    category = 2
  } else if (req.body.category == "Furniture") {
    category = 3
  } else {
    console.log("category is not working properly")
    res.status(403).json({ msg: 'Look what category is' })
  } //end if

  //get the ids of all the pictures saved
  let picture = []
  if (req.files) {
    req.files.forEach(file => picture.push(file.id))
  }

  try {
    //create new item in the Database
    const item = new Item({ userID, username, title, description, price, picture, category, isSold, university })
    if (username == "") {
      res.status(404).json({ msg: 'Please specify username' })
    }
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

/**
 * Get all the items that 
 * the user is selling currently
 */
router.get('/userSellingCurrent/:username', async (req, res) => {
  try {
    // get all items with isSold as false.
    console.log(req.params.username)
    const user = await User.find({ username: req.params.username })
    let items = []
    user[0].forSale.forEach(async (item) => {
      const temp = await Item.findById({ _id: item })
      if (temp && !temp.isSold) {
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

/**
 * Remove the item from the database
 */
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
    //find the corresponding item to get the array of pictures
    let item = await Item.findById(itemID)
    //delete the pictures in the array
    let ret = await removeFiles([...item.picture], 'items')
    //delete the item and also update the corresponding user object
    ret = await Item.findByIdAndDelete({ _id: itemID })
    ret = await User.findOneAndUpdate({ username: username }, { forSale: user.forSale })
    res.status(200).json({ msg: "item has been successfully removed" })
  } catch (e) {
    //logging errors
    console.log(e)
    res.status(404).json({ msg: e.message })
  }
});


/**
 * Marks the item as sold and moves the item to the users selling history
 */
router.post('/itemSold', async (req, res) => {
  const { username, itemID } = req.body

  try {
    //get the corresponding user
    const user = await User.findOne({ username: username })
    //get the corresponding itemIndex in the items array
    const index = user.forSale.indexOf(itemID);
    if (index > -1) {
      //remove the item from forSale and add it to sellingHistory
      user.sellingHistory.push(itemID)
      user.forSale.splice(index, 1)
    } else {
      //item couldn't be found
      res.status(400).json({ msg: "item could not be found in the user's forSale list" })
    }
    // update forSale and sellingHistory Array
    var ret = await User.findOneAndUpdate({ username: username }, { forSale: user.forSale })
    ret = await User.findOneAndUpdate({ username: username }, { sellingHistory: user.sellingHistory })
    res.status(200).json({ msg: "item has been successfully been marked as sold" })
  } catch (e) {
    //logging errors
    console.log(e)
    res.status(404).json({ msg: e.message })
  }
});

/**
 * Selling history 
 */
router.get('/userSellingHistory/:username', async (req, res) => {
  try {
    // get all items with isSold as true.
    const user = await User.find({ username: req.params.username })
    let items = []
    if (user[0].sellingHistory.length === 0) {
      res.status(200).json({ items })
    } //end if
    user[0].sellingHistory.forEach(async (item) => {
      const temp = await Item.findById({ _id: item })
      if (temp.isSold) {
        items.push(temp)
      } //end if
      if (item === user[0].sellingHistory[user[0].sellingHistory.length - 1]) {
        res.status(200).json({ items })
      } //end if
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
router.get('/picture/:itemId', async (req, res, next) => {
  //get the id of the picture
  const { itemId } = req.params

  const { itemChunks } = getItemPictureSchemas()

  //get the schemas for items
  const item = await Item.findById(itemId)

  let ids = []
  if (item)
    ids = [...item.picture]

  //in case there is no id, respond with an error
  if (ids.length === 0) {
    return res.status(404).json({ msg: "The fileId was not found" })
  } //end if

  //setting up the request object for next middleware
  req.fileChunks = itemChunks
  req.fileIds = ids

  //calling the next middleware
  next()
}, getManyFiles)

/**
 * Route to delete a picture from the database
 */
router.delete('/picture/:id', async (req, res, next) => {
  //get the id of the picture
  const { id } = req.params

  //checking whether id is not null
  if (!id) {
    return res.status(404).json({ msg: 'requested id not found!' })
  } //end if

  try {
    //search for the picture and delete it from both the schemas
    const ret = await removeFiles([id], 'items')
  } catch (e) {
    //error handling
    console.error(e)
    res.status(400).json({ msg: 'Could not delete the picture' })
  }
})

/**
 * Route to update the details of the item
 */
router.put('/', async (req, res) => {
  try {
    const ret = await Item.findOneAndUpdate({ _id: req.body.id }, { ...req.body })
    res.status(200).json({ msg: "The item settings have been updated" })
  } catch (e) {
    //sending an error response
    console.log(e)
    res.status(400).json({ msg: "The item settings couldn't be updated" })
  }
})

/**
 * Route to update the item pictures
 */
router.post('/pictures/:id', upload.array("data"), async (req, res) => {
  const { id } = req.params
  try {

    console.log(req.files)

    //getting the fields from the file
    let picture = []
    if (req.files) {
      req.files.forEach(file => picture.push(file.id))
    }

    console.log(picture)

    //get the item and delete old files
    const item = await Item.findById(id)

    //delete old files if they exist
    if (item.picture && item.picture.length !== 0)
      await removeFiles(item.picture, 'items')

    //update the user schema with the image id
    const ret = await Item.findByIdAndUpdate(id, { picture: [...picture] })
  } catch (e) {
    //logging errors
    console.log(e)
    res.status(404).json({ msg: "item pictures couldn't be updated" })
  } //end try-catch
  res.status(201).json({ file: req.file, msg: "item pictures have been updated" })
})

module.exports = router;