ObjectId = require('mongoose').Types.ObjectId
Item = require './database/item'
Transaction = require './database/transaction'
User = require './database/user'
gateway = require './gateway'
Step = require 'step'
io = require('./socket').io
util = require './util'
mongoLogger = util.logger 'mongo'
config = require('../config')['private']
require 'sugar'

languageSet = config.languageSet
exports.user = (socket) ->
  session = socket.handshake.session

  # fn is only for error reporting
  socket.on 'item:sponsor', (data, fn) ->
    # @todo this implementation does not check whether the item is availalbe and/or open for sponsorship
    try
      itemId = ObjectId data.id
    catch e
      return fn
        code: 4002
        message: 'Bad ObjectId'
    orderId = ObjectId()
    # sponsorRealAmount is in real amount
    if data.amount
      sponsorIntAmount = Number(data.amount) * config.currencyMultiplier
    else
      # 1000 cents, or 10 units (USD)
      sponsorIntAmount = 1000
    # @todo bandwith optimization
    # event-scope to store old value of progress and sponsor count, so that if it stay the same, do not broadcast
    #itemProgress = null
    #itemSponsorSount = null
    Step(
      ->
        # Step 1, lock user account and find if account has positive (coupon) balance
        conditions =
          _id: session.user._id
          lock:
            $ne: true
        update = lock: true
        options =
          select:
            balance: 1
            lock: 1
        User.findOneAndUpdate conditions, update, options, @

        undefined
      , (err, userAccount)->
        throw err if err
        # unless user account, this account has been possibly lock but not yet unlock clean
        unless userAccount
          throw
            message: "Your user acccount is technically dirty, please contact our technical support"
            code: 5002

        step2a = @parallel()
        step2b = @parallel()
        # Step 2a, if coupon
        if userAccount.balance > 0
          step2b(null, -1)

          sponsorIntAmount = Math.min sponsorIntAmount, userAccount.balance
          update =
            $inc:
              balance: - sponsorIntAmount

          User.findByIdAndUpdate session.user._id, update, step2a

        else
          step2a(null, -1)

          # no 2PC, just charge the user first!
          transaction =
            # amount in dollar!!!
            amount: sponsorIntAmount / config.currencyMultiplier
            customerId: String(session.user._id)
            # explicitly set orderId
            orderId: String(orderId)
            options:
              submitForSettlement: true
          gateway.transaction.sale transaction, @

        undefined
      , (err, couponRes, paymentRes)->
        if couponRes is -1
          # @todo error handling
          if err
            throw
              code: 5001
              message: 'Cannot reach payment gateway. Please try again later'

          # @todo check whether transaction being rejected by processor or gateway
          # we only assume user doesn't have a credit card set up yet
          unless paymentRes?.success
            throw
              code: 4032
              message: 'Unable to create transaction. Please add new credit card or try another payment method'
        else throw err if err

        # upon transaction success, update our db

        # increase the amount of item
        conditions = {_id: itemId}
        update =
          $addToSet:
            sponsorSet: session.user._id
          $inc:
            fundSize: sponsorIntAmount
        options =
          select:
            # need for calculating progress
            sponsorSet: 1
            sponsorCountRequired: 1
            fundSize: 1
            fundSizeRequired: 1

            state: 1

            # need of calculating countdown
            competitionStart: 1
            transitionTimeout: 1
            competitionTimeout: 1

        Item.findOneAndUpdate conditions, update, options, @parallel()
        ###
        # create transaction
        data =
        # explicitly set _id to orderId
          _id: orderId
          user: session.user._id
          item: itemId
          # type: pay to braintree
          type: 1

        Transaction.create data, @parallel()
        ###

        # increase the bidCount of user
        condition = _id: session.user._id
        update =
          # @todo calculate bidCount base on amount of transaction
          $inc:
            bidCount: sponsorIntAmount / config.bidDivisor
          $set:
            lock: false
        User.update condition, update, @parallel()

        undefined
      , (err, item, user)->
        # @todo error handling
        if err

          # known error
          if err.code in [5001, 5002, 4032]
            return fn(err)

          # unkown error
          mongoLogger.error err
          return fn
            code: 5000
            object: err
            message: 'Unknown error'


        # callback with null object, i.e no error nor result
        # we have result sent back via emitting 'item:update'
        fn()

        # if progress is 100 and competitionStart is not set, mark competitionStart/End
        if item.progress is 100 and not item.competitionStart
          item.competitionStart = Date.now() + item.transitionTimeout
          item.competitionEnd = Date.now() + item.transitionTimeout + item.competitionTimeout
          item.state = 2
          # @fixme no callback
          item.save()
        data =
          id: item.id
          progress: item.progress
          sponsorCount: item.sponsorCount
          # @todo if undefined, do not tell client
          competitionStart: item.competitionStart
          competitionEnd: item.competitionEnd
        # emit to other connections, even THIS connection and guess
        io.of('').emit 'item:update', data, Date.now()
    )

  # fn is only for error reporting
  socket.on 'item:compete', (data, fn) ->
    transaction =
      userId: session.user._id
      username: session.user.username
    now = Date.now()
    Step(
      ->
        ###
        Step 1, whether item is for compete, whether user is legimate to compete
        ###
        itemId = ObjectId data.id
        conditions =
          _id: itemId
          $and: [
            {competitionStart: $lte: now}
            # competition made right on time (in ms) is still accepted
            {competitionEnd: $gte: now}
          ]

        # get 9 latest transaction
        # push the new one in and we have list of 10
        filters =
          transactionList: $slice: -9

        Item.findOne conditions, filters, @parallel()

        # confirm that user has enough bidCount
        conditions =
          _id: session.user._id
          bidCount: $gt: 0
        filters = _id: 1
        User.find(conditions, filters).lean().exec @parallel()

        undefined
      , (err, item, user) ->
        throw err if err
        if item is null
          throw
            code: 4015
            message: 'Item not available for competition'

        if user is null
          throw
            code: 4014
            message: 'Not enough bid to compete'

        # do not use mongoose item document, but native mongodb driver
        conditions = _id: item._id
        update =
          $push:
            transactionList: transaction
          $inc:
            price: 1
          $set:
            competitionEnd: now + item.competitionTimeout
            lastWinner: session.user._id
        options =
          new: true
        Item.findOneAndUpdate conditions, update, options, @parallel()

        conditions = _id: session.user._id
        update = $inc: bidCount: -1
        User.update conditions, update, @parallel()
        undefined
      , (err, item) ->
        if err
          # known error
          if err.code in [4014,4015]
            return fn err

          # unknown err from mongo
          mongoLogger.error err
          return fn
            code: 5000
            message: 'Unknown error'

        # callback with null object, i.e no error nor result
        # we have result sent back via emitting 'item:update'
        fn()

        data =
          id: item.id
          competitionTimeout: item.competitionTimeout
          # @todo transactionList have more information than required competitorList
          competitorList: item.transactionList
          price: item.price
        # emit to other connections, even THIS connection and guess
        io.of('').emit 'item:update', data, Date.now()
        undefined
    )

exports.guess = (socket) ->
  session = socket.handshake.session
  socket.on 'item:read', (data, fn)->
    # read the list
    if data is null
      # @todo more condition
      yesterday = Date.now() - 86400000
      # partial filter, assume that there is no competitionTimeout greater than 24 hours
      # later we can even filter by last competitor?
      # @todo what about item not yet open?
      conditions =
        $or:[
          {competitionUpdated: null}
          {competitionUpdated: $gt: yesterday}
        ]
        $and: [
          {state: $gt: 0}
          {state: $lte: 2}
        ]

      filters =
        transactionList: $slice: -10

      Item.find(conditions, filters).exec (err, res)->
        # @todo error handling
        # unkown error
        mongoLogger.error err
        if err
          return fn
            code: 5000
            object: err
            message: 'Unknown database error'

        # remove item with competition ended
        # @todo filter by DB condition, not logic condition
        res.remove (i) ->
          if i.competitionEnd
            return i.competitionEnd < Date.now()

        # client only knows what it should

        res = res.map (i)->
          item =
            # @deprecated
            id: i.id
            _id: i.id
            product:
              code: i.product.code
              name: i.product.name[session.language] or i.product.name[languageSet[0]]
              imageUrl: i.product.imageUrl
              description: i.product.description[session.language] or i.product.description[languageSet[0]]
            progress: i.progress
            sponsorCount: i.sponsorCount
            # @todo transactionList has more information than required competitorList
            competitorList: i.transactionList
            state: i.state
            price: i.price
            competitionStart: i.competitionStart
            competitionEnd: i.competitionEnd
            openAt: i.openAt
          #item
        fn null, res, Date.now()
