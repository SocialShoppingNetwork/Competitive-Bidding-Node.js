ObjectId = require('mongoose').Types.ObjectId
ChatMessage = require './database/chatmessage'
io = require('./socket').io

# @todo Only allow login user chat at the momen
# export function for listening to the socket
module.exports = (socket) ->
  session = socket.handshake.session
  # @todo configureable amount of save chat messages
  # retrieve latest 20 messages for new connection
  socket.on 'user:join', (data, fn) ->
    ChatMessage.find().sort(_id: -1).limit(20).exec (err, res) ->
      # @todo err handling
      if err
        return fn
          code: 5000
          object: err
          message: 'Unknown error'
      res.reverse()
      fn null, res

  # broadcast a user's message to other users
  socket.on "message:send", (data, fn) ->
    # @todo throttle message by user account

    unless data?.message
      return fn
        error: 4000
        message: 'Bad request'

    # just add additional info, dont sanitize, Mongoose will
    # assume socket.session.user isnt null
    data.userId = session.user._id
    data.name = session.user.name
    data.avatarUrl = session.user.avatarUrl

    ChatMessage.create data, (err, res) ->
      if err
        # unknown error
        return fn
          code: 5000
          message: 'Unknown error from MongoDB #{err.code}'

      # callback with empty object, i.e. no error
      fn()

      # client only knows what it should
      data =
        id: res.id
        message: res.message
        userId: res.userId # String
        name: res.name
        avatarUrl: res.avatarUrl
      # broadcast to all other connections the result from Mongoose, which is absolutely already sanitized
      socket.broadcast.emit "message:send", data

  # clean up when a user leaves, and broadcast it to other users
  # @todo temporary disable 'leave' notification
  # socket.on "disconnect", ->
  #   if session.user?.name
  #     socket.broadcast.emit "user:leave",
  #       name: session.user.name
