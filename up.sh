#! /bin/bash

pwd="$( cd "$( dirname "$0" )" && pwd )"
scriptPath="${pwd}/server/index.coffee"

exec /usr/bin/env node ${pwd}/node_modules/.bin/up $($pwd/script/getparam.js) $scriptPath
