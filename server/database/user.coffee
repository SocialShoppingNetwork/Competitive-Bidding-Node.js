mongoose = require('mongoose')
bcrypt = require 'bcrypt'
Schema = mongoose.Schema
exhibiaLogger = require('../util').logger 'exhibia'
UserAddressSchema = new Schema(
  street1: String
  street2: String
  city: String
  postcode: Number
  country: String
  phoneNumber: Number
,
  strict: true
)

UserCreditCardSchema = new Schema(
  holder: String
  number: Number
  csc: Number
  state: String
  month:
    type: Number
    'enum': [1..12]
  year: Number
,
  strict: true
)

permissionMaskMap =
  isAdmin: 1
  isSomething: 2
  isOther: 3

UserSchema = new Schema
  # lock is used during financial transaction, in which it is true at the first step of the transaction and released (false)
  # at the final step
  lock: Boolean
  # Profile information
  username:
    type: String
    unique: true
    sparse: true
    # @deprecated, should use @name directly if want to get 'display name'
    get: (n)->
      n or @firstName
  password:
    type: String
    'set': (password)->
      bcrypt.hashSync password, bcrypt.genSaltSync()
  firstName: String
  lastName: String
  email: String
  phoneNumber: Number
  # Facebook ID
  fbId:
    type: Number
    unique: true
    sparse: true
  # Facebook username
  fbName: String

  # cent
  balance: Number

  bidCount:
    type: Number
    'default': 0
  pointCount:
    type: Number
    'default': 0
  # @todo
  # 1:
  # 2:
  # 4:
  # 8:
  badgeMask: Number
  #tweeterId:
  #googleId:
  addressSet: [ UserAddressSchema ]
  creditCardSet: [ UserCreditCardSchema ]
  #
  # 1: isAdmin
  # 2: isSomething
  # 3: isAdmin + isSomething
  # 4: isOther
  # 5: isAdmin + isOther
  # 6: isSomething + isOther
  # 7: isAdmin + isSomething + isSomething
  permissionMask:
    type: Number
    'default': 0
  # Schema version
  v:
    type: Number
    'default': 0

UserSchema.methods.checkPassword = (password) ->
  return false unless password and @password
  bcrypt.compareSync String(password), String(@password)

# @todo change picture type (small, large)
UserSchema.virtual('fbAvatarUrl').get ->
  if @fbId
    'http://graph.facebook.com/' + @fbId + '/picture?type=square'
  else
    null

UserSchema.virtual('avatarUrl').get ->
  @fbAvatarUrl if @fbAvatarUrl

UserSchema.virtual('fullName').get ->
  [@firstName, @lastName].join ' '

UserSchema.virtual('name').get ->
  @username or @firstName

isAdmin = UserSchema.virtual('isAdmin')

isAdmin.set (v)->
  # bitwise operation
  #@permissionMask |= v & permissionMaskMap.isAdmin
  # @todo implement set admin
  exhibiaLogger.error 'Not yet implement'

isAdmin.get ->
  # bitwise operation
  Boolean(@permissionMask & permissionMaskMap.isAdmin)


# set getter: true so that we have virtual path getter for isAdmin
# UserSchema.set 'toObject', getters: true

UserSchema.set 'toObject', virtuals: true
UserSchema.set 'toJSON', virtuals: true

module.exports = mongoose.model('User', UserSchema)
