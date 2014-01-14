mongoose = require('mongoose')
updated = require('./updated')

CouponSchema = new mongoose.Schema(
  _id: Number
  # cent
  value: Number
  # timestamp
  redeemedAt: Number
  redeemedBy:
    type: mongoose.Schema.Types.ObjectId
    ref: 'User'
,
  strict: true
)

module.exports = mongoose.model 'Coupon', CouponSchema
