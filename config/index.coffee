options =
  ext: ".yaml"
  cwd: "config"

throw 'export NODE_ENV first' unless process.env.NODE_ENV

util = require("./util")
path = require("path")
require 'js-yaml'
commonConfig = require './common.yaml'
specConfig = require './' + process.env.NODE_ENV + options.ext

rawConfig = util._extend(commonConfig, specConfig)

module.exports = util._scope(rawConfig)
