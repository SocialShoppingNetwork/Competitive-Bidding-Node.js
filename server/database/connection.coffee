# Modified from https://gist.github.com/1058819

mongoose = require 'mongoose'
reconnTimer = null
url = null
connection = null
mongoLogger = require('../util').logger 'mongo'

module.exports = (u, cb) ->

  # Save the state
  reconnTimer = null
  url = u
  connection = null
  mongoose.connection.on "opening", ->
    mongoLogger.info "Mongo: Connecting... %d", mongoose.connection.readyState

  mongoose.connection.on "open", ->
    mongoLogger.info "Mongo: Connected."
    if reconnTimer
      # clear reconnect timeout if available
      clearTimeout reconnTimer
      reconnTimer = null
    cb && typeof cb is 'function' && cb()

  mongoose.connection.on "close", ->
    mongoLogger.info "Mongo: Disconnected."
    mongoose.connection.readyState = 0 # force...
    mongoose.connection.db.close()
    if reconnTimer
      mongoLogger.info "Mongo: Already trying to reconnect."
    else
      reconnTimer = setTimeout(connect, 500) # try after delay

  connect()

connect = ->
  reconnTimer = null
  mongoLogger.info "Mongo: Trying to connect: %s", url
  connection = mongoose.connect(url)
