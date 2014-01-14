mongoose = require('mongoose')
updated = require('./updated')
ObjectId = mongoose.Schema.Types.ObjectId

config = require('../../config')['private']
ProductSchemaDeclarative = Object.clone require('./product').declarative, true
ProductSchemaDeclarative._id =
  type: ObjectId
  index: true

TransactionSchema = new mongoose.Schema(
  # immutable
  userId:
    type: ObjectId
    ref: 'User'
  # mutable, if user wanna change his/her username
  username: String
,
  strict: true
)

ItemSchema = new mongoose.Schema
  product: ProductSchemaDeclarative

  ## possible values:
  # 0: created
  # 1: funding
  # 2: transition + competition
  # 3: finalPayment paid
  # 4: shipping
  # 5: received
  # 6: closed
  state:
    type: Number
    'default': 0
    min: 0
    max: 6

  # fix timestamp marks item enabled for sponsor
  openAt: Number

  fundSizeRequired:
    type: Number
    required: true

  ## switch state from 1 to 2 when:
  # fundSize >= fundSizeRequired
  # sponsorSet.length >= sponsorCountRequired
  fundSize:
    type: Number
    'default': 0

  sponsorCountRequired:
    type: Number
    required: true

  sponsorSet: [
    type: mongoose.Schema.Types.ObjectId
    ref: 'User'
  ]

  transitionTimeout:
    # in millisecond
    type: Number
    # 5m
    'default': 300000

  competitionTimeout:
  # in millisecond
    type: Number
    # 2m
    'default': 120000

  ## competitionStart is set when:
  # progress is 100
  ## item's opened for competition when:
  # competitonStart <= now
  competitionStart: Number

  ## competitionEnd is set when:
  # progress is 100
  ## item's opened for competition when:
  # competitonEnd >= now
  ## updated when:
  # item:compete
  competitionEnd: Number

  # @todo while in item, save embedded document, while archiving, save ref
  transactionList: [ TransactionSchema ]

  # current winner who earns right to purchase the item
  lastWinner:
    type: mongoose.Schema.Types.ObjectId
    ref: 'User'

  # price in cent
  price:
    type: Number
    'default': 0

  feedbackMessage: String


ItemSchema.virtual('sponsorCount').get ->
  @sponsorSet.length

ItemSchema.virtual('product.imageUrl').get ->
  if @product.image
    return "#{config.s3.url}/product/#{@product._id}"
  else
    return "#{config.s3.url}/product/placeholder"

ItemSchema.virtual('progress').get ->
  # from 0 to 99
  p = Math.round @fundSize / @fundSizeRequired * 100

  if @sponsorSet.length < @sponsorCountRequired
    # only 99% if sponsorCountRequired not met
    Math.min p, 99
  else
    # maximum 100%
    Math.min p, 100

# auto "lastModified"
ItemSchema.plugin updated.plugin

ItemSchema.set 'toObject', getters: true
ItemSchema.set 'toJSON', getters: true

module.exports = updated.preUpdate mongoose.model 'Item', ItemSchema
