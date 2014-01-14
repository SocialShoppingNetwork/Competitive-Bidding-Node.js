app.factory '$interval', ['$rootScope', '$window', ($rootScope, window) ->
  functionSet = []
  unregisterSet = []
  lastStick = 0
  $timeoutFn = ->
    now = Date.now()
    # more than 1000 +/- 100 = more than 950
    if now - lastStick > 950
      functionSet.forEach (fn, i)->
        $rootScope.$apply fn(now, unregisterSet[i])
      lastStick = now
    window.setTimeout $timeoutFn, 100
  $timeoutFn()

  # pulic API
  (fn)->
    unless typeof fn is 'function'
      throw new Error 'Not a Function'
    unregister = ->
      index = functionSet.indexOf fn
      functionSet.splice index, 1
      unregisterSet.splice index, 1
    functionSet.push fn
    unregisterSet.push unregister
    # return unregister
    unregister
]
