socket = require './socket'
config = require('../config')['private']
chat = require './chat'
session = require './session'
connection = require './database/connection'
ready = require('up').ready
admin = require './admin'
util = require './util'
user = require './user'
item = require './item'

connection config.mongoUrl, ready

exhibiaLogger = util.logger 'exhibia'

# Export server instance to use with `up`, and socket.io lesten to server
# instance instead of a port
module.exports = socket.server
io = socket.io
socketLogger = util.logger 'socket'
io.set 'logger', socketLogger
io.set 'log level', util.logger.level.TRACE


# Use RedisStore (instead of MemoryStore) for multithread
# RedisStore = require("socket.io/lib/stores/redis")
# redis = require("socket.io/node_modules/redis")
# pub = redis.createClient config.redis.port, config.redis.host
# sub = redis.createClient config.redis.port, config.redis.host
# client = redis.createClient config.redis.port, config.redis.host
# io.set "store", new RedisStore(
#   redisPub: pub
#   redisSub: sub
#   redisClient: client
# )

# io.set "transports", ["xhr-polling"]
# io.set "polling duration", 10
# console.log io, 'io index'

# Variables to handle graceful shutdown
connectionCount = 0
sigtermReceived = false

# Function to handle graceful shutdown
exit = ->
  # exit process only when SIGTERM has already been received and number of
  # connection is 0
  process.exit() if sigtermReceived is true and connectionCount is 0

process.on 'SIGTERM', ->
  # On SIGTERM, mark that SIGTERM has already been received
  sigtermReceived = true
  # Call graceful shutdown funtion to determine whether to exit
  exit()

io.sockets.on "connection", (socket) ->

  # On connect, increase connection count
  connectionCount++

  # Other handlers
  # login must go first
  session socket
  item.guess socket
  chat socket

  socket.on 'disconnect', ->
    # On disconnect, decrease connection count
    connectionCount--

    # Call graceful shutdown funtion to determine whether to exit
    exit()

# admin namespace
adminIo = io.of('/admin')
adminIo.authorization (handshake, callback) ->
  # Only allow admin to connect
  if handshake.session.user?.isAdmin
    # callback without error, and authorized=true
    return callback null, true

  # callback with error
  callback 'Unauthorized access'

adminIo.on 'connection', (socket)->
  socket.on 'disconnect', ->
    # manually remove all listeners
    socket.removeAllListeners()
  admin socket

# user namespace
userIo = io.of('/user')
userIo.authorization (handshake, callback) ->
  if handshake.session.user
    # callback without error, and authorized = true
    return callback null, true

  # callback with error
  callback 'Unauthorized access'

userIo.on 'connection', (socket)->
  socket.on 'disconnect', ->
    # manually remove all listeners
    socket.removeAllListeners()
  user socket
  item.user socket

# @todo regularly checkout http://nodejs.org/api/domain.html
process.on 'uncaughtException', (err)->
  exhibiaLogger.fatal err

# @fixme upgrading to node 0.10.0 break LearnBoost's up
# unless listening to port inside code
# module.exports.listen process.env.PORT || config.socketPort
console.log process.env.PORT, '$PORT'
console.log config.socketPort, 'socketPort'
# rollback to node 0.8.22 and wait for https://github.com/nodejitsu/node-http-proxy/issues/387
