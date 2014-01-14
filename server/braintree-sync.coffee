User = require './database/user'
braintree = require 'braintree'
connection = require './database/connection'
config = require('../config')['private']
Step = require 'step'

gatewayConfig = config.paymentGateway.braintree
gatewayConfig.environment = braintree.Environment[gatewayConfig.environment]
gateway = braintree.connect gatewayConfig

Step(
  ->
    connection config.mongoUrl, @
    undefined
  , ->
    query = {}
    filters = _id: 1
    User.find query, filters, @
    undefined
  , (err, collection)->
    return console.log err if err
    for document in collection
      done = @parallel()
      # put it in clousre to avoid condition race
      # cause by async and for loop
      ((id)->
        gateway.customer.find id, (err, user)->
          if err?.type is braintree.errorTypes.notFoundError
            c = id: id
            return gateway.customer.create c, (err, res)->
              throw err if err
              if res.success
                console.log "Customer with ID #{id} created"
              else
                console.log res
                throw new Error 'somthing wrong while creating'
              done()

          throw err if err
          done()
      )(document.id)
    undefined
  , (err, res...)->
    throw err if err
    console.info('All sync\'ed')
    process.exit(0)
)

