ObjectId = require('mongoose').Types.ObjectId
User = require './database/user'
Item = require './database/item'
Coupon = require './database/coupon'
config = require('../config')['private']
gateway = require './gateway'
Step = require 'step'
util = require './util'
mongoLogger = util.logger 'mongo'
require 'sugar'

module.exports = (socket) ->
  session = socket.handshake.session
  # @todo read from session instead of db
  socket.on 'profile:read', (mode, fn) ->
    if mode is 'simple'
      conditions = {_id: session.user._id}
      filters =
        username: 1
        firstName: 1
        lastName: 1
        email: 1
        bidCount: 1
        pointCount: 1
        balance: 1
      return User.findOne conditions, filters, (err, res)->
        # @todo error handling
        if err
          # unkown error
          mongoLogger.error err
          return fn
            code: 5000
            message: 'Unknown database error'
        fn null, res

    if mode is 'proxy'
      return gateway.customer.find session.user.id, (err, customer)->
        # @todo error handling
        if err
          return fn({
            code: err.code
            message: err})

        # never trust 3rd party info either
        customer.addresses.forEach (v, i)->
          a = Object.select v, [
            'id'
            'firstName'
            'lastName'
            'company'
            'streetAddress'
            'extendedAddress'
            'locality'
            'postalCode'
          ]
          a.country = v.countryCodeAlpha2
          customer.addresses[i] = a

        customer.creditCards.forEach (v, i)->
          c = Object.select v, [
            'token'
            'expirationDate'
            'cardholderName'
            'default'
          ]
          c.type = v.cardType
          c.number = v.maskedNumber
          customer.creditCards[i] = c

        data =
          addressSet: customer.addresses
          cardSet: customer.creditCards
        fn null, data


    fn
      code: 4000
      message: 'Bad request'

  socket.on 'profile:edit', (data, fn) ->
    unless data
      return fn
        code: 4003
        message: 'Empty request'

    conditions = _id: session.user._id

    # Never trust client's data when updating database
    update = {}
    update.username = data.username if data.username
    update.fistName = data.fistName if data.fistName
    update.lastName = data.lastName if data.lastName
    update.email = data.email if data.email

    User.update conditions, data, (err, numberAffected) ->
      # error by mongo
      # unkown error
      mongoLogger.error err
      return fn
        code: 5000
        message: 'Unknown database error'
      if numberAffected is 0
        return fn
          code: 4042
          message: 'Not found, not updated'

      fn()

  socket.on 'address:create', (data, fn) ->
    unless data
      return fn
        code: 4003
        message: 'Empty request'
    data.customerId = session.user.id
    gateway.address.create data, (err, result)->
      # @todo error handling
      if err
        return fn
          code: -1
          message: err.message
      fn()

  socket.on 'card:create', (data, fn) ->
    # check cvv. we do not set CVV verification in BT because otherwise
    # make default a card is impossible without providing CVV again
    # @todo contact BT
    # @todo verify card number and cvv right away
    unless data and data.number and data.cvv
      return fn
        code: 4003
        message: 'Empty request'

    # client's data is passed to 3rd party, uneccesary to santize
    data.customerId = session.user.id
    data.token = ObjectId().toString()

    gateway.creditCard.create data, (err, result)->
      # @todo error handling
      if err
        return fn
          code: -1
          message: err.message

      unless result?.success
        return fn
          code: 4031
          message: 'Unable to verify card. Please double check your info and retry'

      fn()

  socket.on 'address:delete', (data, fn) ->
    gateway.address.delete session.user.id, data, (err)->
      # @todo error handler
      if err
        return fn
          code: -1
          message: err.message
      fn()

  socket.on 'card:delete', (data, fn) ->
    gateway.creditCard.delete data, (err)->
      # @todo error handler
      if err
        return fn
          code: -1
          message: err.message
      fn()

  socket.on 'card:update', (req, fn) ->

    unless req
      return fn
        code: 4003
        message: 'Empty request'

    # never trust client data
    token = req.token
    data = options: {}
    data.options.makeDefault = req.options?.makeDefault

    gateway.creditCard.update token, data, (err, result)->
      # @todo error handler
      if err
        return fn
          code: -1
          message: err.message

      unless result?.success
        return fn
          code: 4031
          message: 'Unable to verify card. Please double check your info and retry'

      fn()

  socket.on 'basket:read', (data, fn) ->
    conditions =
      lastWinner: session.user._id
    Item.find(conditions).populate('product').exec (err, res) ->
      # @todo error handler
      return fn err if err

      # remove item still in competition
      now = Date.now()
      res.remove (i) ->
        if i.competitionEnd
          return i.competitionEnd > now

      # remove items which been already paid
      if data is 'checkout'
        res.remove (i) ->
          return i.state isnt 2
      # remove item which not been paid yet
      else if data is 'feedback'
        res.remove (i) ->
          return i.state is 2

        # remove items which already have feedback
        res.remove (i) ->
          return i.feedbackMessage

      # only return neccessary data
      item = res.map (i) ->
        item =
          _id: i._id
          code: i.product.code
          name: i.product.name
          lastWinner: i.lastWinner
          description: i.product.description
          image: i.product.imageUrl
          price: i.transactionList.length / 100

      fn null, {item: item}

  socket.on 'basket:pay', (data, fn) ->
    try
      itemId = ObjectId data.itemId
    catch e
      return fn
        code: 4002
        message: 'Bad ObjectId'

    # shipAdd is required to purchase final item
    unless data.shipAdd?
      return fn
        code: 4033
        message: 'No shipping address provided'

    # need creditCard data if wanna have billingAddres
    transaction =
      amount: Number(data.amount)
      customerId: String(session.user._id)
      shipping:
        firstName: data.shipAdd.firstName
        lastName: data.shipAdd.lastName
        company: data.shipAdd.company
        streetAddress: data.shipAdd.streetAddress
        extendedAddress: data.shipAdd.extendedAddress
        locality: data.shipAdd.locality
        postalCode: data.shipAdd.postalCode
        countryCodeAlpha2: data.shipAdd.country
      # explicitly set orderId to be itemId
      orderId: String(itemId)
      options:
        submitForSettlement: true
    Step(
      ->
        gateway.transaction.sale transaction, @

        undefined
      , (err, res) ->
        if err
          return fn
            code: 5001
            message: 'Cannot reach payment gateway. Please try again later'

        unless res?.success
          return fn
            code: 4032
            message: 'Unable to create transaction. Please try another payment method'

        conditions = _id: itemId
        update =
          state: 3

        Item.update conditions, update, (err, res) ->
          if err
            return fn
              code: 5000
              message: err

          fn()

    )

  socket.on 'item:feedback', (data, fn) ->
    try
      itemId = ObjectId data.itemId
    catch e
      return fn
        code: 4002
        message: 'Bad ObjectId'

    # message must not be null
    unless data.message
      return fn
        code: 4002
        message: 'No message is not allowed'

    Item.update {_id: itemId}, {feedbackMessage: data.message}, (err, numberAffected) ->
      if err
        # unkown error
        mongoLogger.error err
        return fn
          code: 5000
          message: 'Unknown database error'
      if numberAffected is 0
        return fn
          code: 4042
          message: 'Item not recognized'

      fn()

  socket.on 'profile:list', (data, fn) ->
    try
      _id = ObjectId data
    catch e
      return fn
        code: 4002
        message: 'Bad ObjectId'
    return User.findOne {_id: _id}, (err, res)->
      # @todo error handling
      if err
        # unkown error
        mongoLogger.error err
        return fn
          code: 5000
          message: 'Unknown database error'
      if res is null
        return fn
          code: 4040
          message: 'User not found'
      fn null,
        id: res.id
        fullName: res.fullName
        email: res.email
        avatarUrl: res.avatarUrl
        username: res.username
        fbId: res.fbId

  socket.on 'coupon:redeem', (data, fn) ->
    # how to redeem
    try
      buffer = Buffer(data, 'base64')
      _id = buffer.readUInt32BE(0)
    catch e
      return fn
        code: -1
        message: 'Unvalid code'

    Step(
      ->
        conditions =
          _id: _id
          redeemedAt: null
        updates =
          redeemedAt: Date.now()
          redeemedBy: session.user._id
        Coupon.findOneAndUpdate conditions, updates, @

        undefined
      , (err, coupon) ->
        if err
          mongoLogger.error err
          return fn
            code: 5000
            message: 'Unknown database error'
        unless coupon
          return fn
            code: 4050
            message: 'Unmatched code'

        conditions =
          _id: session.user._id
        updates =
          $inc:
            balance: coupon.value
        User.findOneAndUpdate conditions, updates, (err, res) ->
          if err
            mongoLogger.error err
            return fn
              code: 5000
              message: 'Unknown database error'
          unless res
            return fn
              code: 4042
              message: 'No user found'

          # @todo success handler
          # only return user's new balance
          fn null, res.balance / config.currencyMultiplier
    )
