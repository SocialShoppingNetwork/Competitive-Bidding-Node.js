angular.module('exhibiaApp').factory 'util', [ '$rootScope', '$timeout', ($rootScope, $timeout)->

  $rootScope.alertList = []
  class Notification
    constructor: (@msg, @type = 'success', @timeout = 5000)->
      # auto-close notification after 5s
      # not in use
      # $timeout ()=>
      #   $rootScope.alertList = $rootScope.alertList.exclude @
      # , @timeout
    close: ->
      $rootScope.alertList = $rootScope.alertList.exclude @

  # public API
  cookie: (name, value, days)->
    if days
      date = new Date()
      date.setDate date.getDate() + days
      expires = "; expires=" + date.toGMTString()
    else
      expires = ""
    document.cookie = name + "=" + value + expires # + "; path=/"

  success: (m)->
    $rootScope.alertList.push new Notification m

  warning: (m)->
    $rootScope.alertList.push new Notification m, 'warning'

  error: (err)->
    # unlike other notification, error receive error object, which consists of at least error (code) and message
    $rootScope.alertList.push new Notification err.message, 'error'

  debug: (m)->
    if true
      console.log m
]
