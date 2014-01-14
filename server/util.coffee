fs = require 'fs'
path = require 'path'
crypto = require 'crypto'
log4js = require 'log4js'
config = require('../config')['private']
cookieKey = fs.readFileSync (path.join __dirname, '../key/cookie.key')

encrypt = (cookie) ->
  cookie = JSON.stringify cookie if typeof cookie is 'object'
  cipher = crypto.createCipher 'aes256', cookieKey
  result = cipher.update cookie, 'utf8', 'base64'
  result += cipher.final 'base64'
  return result

decrypt = (cookie) ->
  decipher = crypto.createDecipher 'aes256', cookieKey
  result = decipher.update cookie, 'base64', 'utf8'
  try
    result += decipher.final 'utf8'
  catch e
    return null
  try
    return JSON.parse result
  catch e
    return result

###
  @mutate data
  @todo constrain checking on params
###
l10n = (data, fieldSet, languageSet)->
  process = (data) ->
    for field in fieldSet
      languageSet.each (language)->
        translatedField = data[field][language]
        if translatedField and not data[field]
          data[field] = translatedField
          # break the loop
          return false
        # continue the loop
        return true
    # chaining
    data

  if Array.isArray data
    data.forEach (e, index)->
      data[index] = process e
    #chaining
    return data
  else
    return process data

logRoot = __dirname + '/../var/'
# a little bit less than 8MB or 8388608
maxLogSize = 8000000
log4js.configure
  appenders: [
    {
    type: config.log
    filename: logRoot + 'socket.log'
    maxLogSize: maxLogSize
    category: [ 'socket' ]
    }
    {
    type: config.log
    filename: logRoot + 'mongo.log'
    maxLogSize: maxLogSize
    category: [ 'mongo' ]
    }
    {
    type: config.log
    filename: logRoot + 'exhibia.log'
    maxLogSize: maxLogSize
    category: [ 'exhibia' ]
    }
    {
    type: config.log
    filename: logRoot + 'up.log'
    maxLogSize: maxLogSize
    category: [ 'up' ]
    }
  ]

logger = log4js.getLogger
logger.level = log4js.levels

module.exports =
  encrypt: encrypt
  decrypt: decrypt
  logger: logger
