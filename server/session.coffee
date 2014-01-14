User = require './database/user'
Step = require 'step'
util = require './util'
request = require 'request'
mongoLogger = util.logger 'mongo'
exhibiaLogger = util.logger 'exhibia'
ObjectId = require('mongoose').Types.ObjectId
gateway = require './gateway'
languageSet = require('../config')['private'].languageSet

# export function for listening to the socket
module.exports = (socket) ->
  handshake = socket.handshake

  # init empty session object
  handshake.session = {}

  # if language is available and isnt hacked
  if handshake.query.language in languageSet
    handshake.session.language = handshake.query.language
  else
    handshake.session.language = languageSet[0]

  socket.on 'language:change', (language)->
    # if language isnt hacked
    if language in languageSet
      handshake.session.language = language

  # is called with user object
  successLogin = (user) ->
    # update user object in the (handshake's) session
    # assume that socket.handshake.session is already init'ed
    handshake.session.user = user
    # https://hipaise.codebasehq.com/projects/exhibia/tickets/40
    user.bidCount or=0
    user.pointCount or=0

    # create new timestamp
    ts = Date.now()

    # callback
    socket.emit "user:login",
      user:
        id: user.id
        username: user.username
        isAdmin: user.isAdmin
        bidCount: user.bidCount
        pointCount: user.pointCount
        name: user.name
        avatarUrl: user.avatarUrl
      session: util.encrypt
      # get the last 11 (or less) number of expires as salt
      # so that 16 first charcters of this message will always be different
        s: ts % 100000000000
        ts: ts
        user:
          id: user.id


  # if session is available
  if handshake.query.session
    session = util.decrypt handshake.query.session

    # if session is sucessfully decrypted
    if _id = session?.user?.id
      # if the session timestamp IS AVAILABLE and is less than 30 days ago
      # @todo configurable cookie expiration
      # 1000ms * 60s * 60m * 24h * 30d = 2592000000
      # or google 30 day to ms
      if session.ts > Date.now() - 2592000000
        conditions = _id: _id
        User.findOne conditions, (err, user)->
          # @todo error handling
          return mongoLogger.error err if err
          return exhibiaLogger.error "No user #{_id}" unless user

          successLogin user


  # User request login
  socket.on "user:login", (data) ->
    # todo hack/attack handling
    return null unless data

    fn = (res)->
      socket.emit "user:login", res


    if data.fbAccessToken and data.fbUserID
      Step(
        ->
          fbCb = @parallel()
          dbCb = @parallel()

          # Facebook callback
          fields = 'id,username,first_name,last_name,email,gender'
          options =
            uri: "https://graph.facebook.com/me?access_token=#{data.fbAccessToken}&fields=#{fields}"
            json: true
          request options, fbCb

          # Database callback
          query = fbId: Number(data.fbUserID)
          filters = {}
          User.findOne query, filters, dbCb
          undefined
        , (err, fbRes, dbRes)->
          if err
            exhibiaLogger.error err
            return fn
            error: '5000'
            message: err.message or 'Unkown error'

          unless fbRes.statusCode is 200
            return fn
              error: 4034
              message: 'Invalid Facebook access token'
          fbData = fbRes.body
          fbId = Number fbData.id

          # create user if new
          if dbRes is null
            _id = ObjectId()
            user = new User
              _id: _id
              firstName: fbData.first_name
              lastName: fbData.last_name
              email: fbData.email
              #gender: fbRes.gender
              fbId: fbId
              fbName: fbData.username

            # @fixme error handling if persisitng failed
            user.save (err)->
              mongoLogger err if err

            c = id: String(_id)

            # @fixme error handling if persisitng failed
            gateway.customer.create c, (err)->
              exhibiaLogger err if err

            successLogin user
            return

          # for somereason, access token and fb User id isnt consistnent
          if fbId isnt dbRes.fbId
            return fn
              error: '4004'
              message: 'Inconsistent Facebook data'

          # all success
          successLogin dbRes
      )
      # stop the flow
      return

    Step(
      ->
        conditions = {username: data.username}
        filters = {}
        User.findOne conditions, filters, @
        undefined

    , (err, user) ->
      # callback this error
      # @todo error categorization
      return fn err if err

      # wrong username result in null user object
      if user is null
        return fn
          error: 4011
          message: 'Wrong username'

      # return part of user object upon success authentication
      if user.checkPassword data.password
        return successLogin user

      # wrong password
      fn
        error: 4012
        message: 'Wrong password'
    )

  # User request logout
  socket.on "user:logout", ->
    # clear user object in the (handshake's) session
    # assume that socket.handshake.session is already init'ed
    socket.handshake.session.user = null

  # User signup
  socket.on 'user:signup', (data, fn) ->
    User.create data, (err, res) ->
      if err
        # duplicate category code
        if err.code is 11000
          return fn
            error: 4001
            message: 'Username duplicated'

        # unknown error
        return fn
          error: 5000
          message: 'Unknown error from MongoDB #{err.code}'

      # @todo notify all other connection a new category is added
      fn
        _id: res._id
