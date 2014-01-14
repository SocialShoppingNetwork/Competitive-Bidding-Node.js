knox = require 'knox'
ObjectId = require('mongoose').Types.ObjectId
Category = require './database/category'
Product = require './database/product'
Item = require './database/item'
Coupon = require './database/coupon'
util = require './util'
mongoLogger = util.logger 'mongo'
config = require('../config')['private']
Step = require 'step'
crypto = require 'crypto'

s3 = knox.createClient config.s3
s3ResponseHandler = (err, res) ->
  if err
    return console.error err
  unless res.statusCode is 200
    console.error res
# helpers
s3Upload = (data)->
  if image = data.imageUrl
    # set data.image to true, so that the app no longer use placeholder
    data.image = true
    regex = /^data:(.+\/(.+));base64,(.*)$/
    [image, contentType, extension, dataBase64] = image.match(regex)
    buffer = new Buffer(dataBase64, "base64")
    unless id = data.id
      # create object ID so that we have same for upload file and DB document
      id = ObjectId()
      data._id = id
    filePath = "/product/#{id}"
    header =
    #'Content-Length': string.length
      'Content-Type': contentType
      # By default the x-amz-acl header is private.
      'x-amz-acl': 'public-read'
    s3.putBuffer buffer, filePath, header, s3ResponseHandler

module.exports = (socket)->

  socket.on 'category:create', (data, fn)->
    Category.create data, (err, res) ->
      if err
        # duplicate category code
        if err.code is 11000
          return fn
            code: 4001
            message: 'Category code duplicated'

        # unknown error
        mongoLogger.error err
        return fn
          code: 5000
          message: 'Unknown database error'

      # @todo notify all other connection a new category is added
      fn null, id: res.id

  socket.on 'category:read', (data, fn)->
    # read the list
    if data is null
      conditions = {}
      filters =
        name: 1
        code: 1
      Category.find conditions, filters, (err, res)->
        # @todo error handling
        if err
          return fn
            code: err.code
            message: err

        fn null, res

  socket.on 'category:delete', (data, fn)->
    # batch delete
    if data instanceof Array
      #

    # individual
    else

      # try to parse object id, or return and callback error
      try
        _id = ObjectId data
      catch e
        return fn
          code: 4002
          message: 'Bad ObjectId'

      # do the delete
      Category.remove _id: _id, (err, deleteCount)->
        # error by mongo
        if err
          return fn
            code: 5000
            message: err

        if deleteCount is 0
          return fn
            code: 4041
            message: 'Not found, not deleted'

        # successfully delete
        fn()

  socket.on 'product:create', (data, fn)->
    s3Upload data

    Product.create data, (err, res) ->
      if err
        # duplicate product code
        if err.code is 11000
          return fn
            code: 4001
            message: 'Product code duplicated'
        # unknown error
        mongoLogger.error err
        return fn
          code: 5000
          message: 'Unknown database error'

      fn null, res

  socket.on 'product:read', (data, fn)->
    # read the list
    if data is null
      conditions = {}
      # @todo filters
      filters = {}
      Product.find conditions, filters, (err, res)->
        # @todo error handling
        if err
          # unknown error
          mongoLogger.error err
          return fn
            code: 5000
            message: 'Unknown database error'
        fn null, res

  socket.on 'product:delete', (data, fn)->
    # batch delete
    if data instanceof Array
      #

    # individual
    else

      # try to parse object id, or return and callback error
      try
        _id = ObjectId data
      catch e
        return fn
          code: 4002
          message: 'Bad ObjectId'

      s3.deleteFile "/product/#{_id}", s3ResponseHandler

      # do the delete
      Product.remove _id: _id, (err, deleteCount)->
        # error by mongo
        if err
          # unknown error
          mongoLogger.error err
          return fn
            code: 5000
          message: 'Unknown database error'

        if deleteCount is 0
          return fn
            code: 4041
            message: 'Not found, not deleted'

        # successfully delete
        fn()

  socket.on 'product:update', (data, fn)->
    try
      _id = ObjectId data.id
    catch e
      return fn
        code: 4002
        message: 'Bad ObjectId'

    s3Upload data
    Step(
      ->
        conditions = _id: _id
        update = data
        Product.update conditions, update, @parallel()

        # @fixme need not to update THE WHOLE DB, but only those still displayed/open
        conditions = 'product._id': _id
        data._id = _id
        update = product: data
        Item.update conditions, update, @parallel()
        undefined
      , (err, numberAffected) ->
        # error by mongo
        if err
          # unknown error
          mongoLogger.error err
          return fn
            code: 5000
            message: 'Unknown database error'
        if numberAffected is 0
          return fn
            code: 4042
            message: 'Not found, not updated'
        fn null, id: _id
    )

  socket.on 'item:create', (data, fn)->
    data.fundSizeRequired *= config.currencyMultiplier
    Item.create data, (err, res) ->
      if err
        # duplicate product code
        if err.code is 11000
          return fn
            code: 4001
            message: 'Product code duplicated'
        # unknown error
        mongoLogger.error err
        return fn
          code: 5000
          message: 'Unknown database error'
      fn null, res

  socket.on 'item:read', (data, fn)->
    # read the list
    if data is null
      conditions = {}
      Item.find(conditions).exec (err, res)->
        # @todo error handling
        if err
          # unknown error
          mongoLogger.error err
          return fn
            code: 5000
            message: 'Unknown database error'

        # message for each state
        now = Date.now()
        for i in res
          if i.state is 0
            i.stateMess = 'Initial item'
          else if i.feedbackMessage?
            i.stateMess = 'Feedback received'
          else if i.state is 3
            i.stateMess = 'Final payment received'
          else if i.progress < 100
            i.stateMess = 'Item in sponsor phase'
          else if i.competitionStart > now
            i.stateMess = 'Item in transition phase'
          else if i.competitionEnd > now
            i.stateMess = 'Item in competition phase'
          else
            i.stateMess = 'Competition ended. Waiting for final payment'

        # client only knows what it should
        res = res.map (i)->
          item =
            _id: i._id
            product:
              _id: i.product._id
              name: i.product.name
              description: i.product.description
              imageUrl: i.product.imageUrl
              code: i.product.code
            state: i.state
            stateMess: i.stateMess
            fundSize: i.fundSize / config.currencyMultiplier
            fundSizeRequired: i.fundSizeRequired / config.currencyMultiplier
            progress: i.progress
            sponsorCount: i.sponsorCount
            sponsorCountRequired: i.sponsorCountRequired
            transitionTimeout: i.transitionTimeout
            competitionTimeout: i.competitionTimeout
            competitionStart: i.competitionStart
            competitionEnd: i.competitionEnd

        fn null, res

  socket.on 'item:delete', (data, fn)->
    # batch delete
    if data instanceof Array
      #

    # individual
    else

      # try to parse object id, or return and callback error
      try
        _id = ObjectId data
      catch e
        return fn
          code: 4002
          message: 'Bad ObjectId'

      # do the delete
      Item.remove _id: _id, (err, deleteCount)->
        # error by mongo
        if err
          # unknown error
          mongoLogger.error err
          return fn
            code: 5000
            message: 'Unknown database error'

        if deleteCount is 0
          return fn
            code: 4041
            message: 'Not found, not deleted'

        # successfully delete
        fn()

  socket.on 'item:update', itemUpdate = (data, fn)->
    try
      _id = ObjectId data.id
    catch e
      return fn
        code: 4002
        message: 'Bad ObjectId'
    Item.update _id: _id, data, (err, numberAffected, rawResponse) ->
      # error by mongo
      if err
        # unknown error
        mongoLogger.error err
        return fn
          code: 5000
          message: 'Unknown database error'
      if numberAffected is 0
        return fn
          code: 4042
          message: 'Not found, not updated'
      fn null,
        _id: _id

  socket.on 'item:enable', (data, fn)->
    data.openAt = Date.now()
    itemUpdate data, fn

  socket.on 'coupon:create', (data, fn) ->
    random = crypto.pseudoRandomBytes(4)

    # code for redemption
    couponCode = random.toString('base64')
    couponCode = couponCode.remove('==')

    # data including _id and value
    data._id = random.readUInt32BE(0)
    data.value *= config.currencyMultiplier
    Coupon.create data, (err, res) ->
      if err
        # unknown error
        mongoLogger.error err
        return fn
          code: 5000
          message: 'Unknown database error'

      fn null, res.value, couponCode

  socket.on 'coupon:read', (data, fn) ->
    # read the list
    if data is null
      conditions = {}
      filters = null
      Coupon.find conditions, filters, (err, res)->
        # @todo error handling
        if err
          return fn
            code: err.code
            message: err

        res = res.map (c)->
          buf = Buffer(4)
          buf.writeUInt32BE(c._id, 0)
          code = buf.toString('base64').remove('==')
          coupon =
            _id: c._id
            couponCode: code
            value: c.value / config.currencyMultiplier
            redeemedAt: c.redeemedAt

        fn null, res
