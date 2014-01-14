#! /usr/bin/env node
var path, config;
path = require('path');
require('coffee-script');
config = require(path.join(__dirname,'../config'));


// process.env.PORT for deploy to heroku
port = process.env.PORT || config.private.socketPort
timeout = '1ms'
cpu = config.private.cpu

console.log('--port %d -r coffee-script -t %s -n %d -m', port, timeout, cpu);
