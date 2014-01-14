mongoose = require 'mongoose'
ObjectId = mongoose.Schema.Types.ObjectId

TransactionSchema = new mongoose.Schema(
  user:
    type: ObjectId
    ref: 'User'
  item:
    type: ObjectId
    ref: 'Item'

  # user sponsor an item with his/her credit card through braintree gateway
  # bidding++, money--
  # 1: 'braintree'
  #
  # user compete for an item
  # bidding--
  # 2:'competition'
  #
  # 3:'paypal'
  type: Number
,
  strict: true
)

module.exports = mongoose.model 'Transaction', TransactionSchema
