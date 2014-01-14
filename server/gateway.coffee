
config = require('../config')['private']
braintree = require 'braintree'

gatewayConfig = config.paymentGateway.braintree
gatewayConfig.environment = braintree.Environment[gatewayConfig.environment]

module.exports = braintree.connect gatewayConfig
