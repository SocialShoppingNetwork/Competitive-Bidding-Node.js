http = require 'http'
socket = require 'socket.io'

# Export server instance to use with `up`, and socket.io lesten to server
# instance instead of a port
exports.server = http.createServer()
exports.io = socket.listen(exports.server)
