angular.module('exhibiaApp').factory 'socket',
['$rootScope', '$cookies', ($rootScope, $cookies) ->
  # save to local var and destroy global var
  io = window.io
  delete window.io
  #config or= window.config
  # start connecting

  querySet = []
  if $cookies.session
    # need encodeURIComponent
    querySet.push 'session=' + encodeURIComponent($cookies.session)
  if $cookies.language
    # need not encodeURIComponent
    querySet.push 'language=' + $cookies.language
  opts = query: querySet.join('&')
  # socket = io.connect config.socket, opts
  socket = io.connect 'exhibia-test.herokuapp.com', opts
  console.log socket, 'socket service'
    # private variable of class SocketNamespace
  namespaces = {}
  class SocketNamespace
    constructor: (@socketNamespace)->

      # override $emit to catch all events
      $emit = @socketNamespace.$emit
      @socketNamespace.$emit = (eventName, data, timestamp)=>
        timestamp = null unless typeof timestamp is 'number'
        socketEventName = ":#{@socketNamespace.name}:#{eventName}"

        # safe $apply
        fn = -> $rootScope.$broadcast socketEventName, data, timestamp
        if $rootScope.$$phase is '$apply'
          fn()
        else
          $rootScope.$apply fn

        # pass backward to other handlers
        $emit.apply @socketNamespace, arguments

      @manager = @socketNamespace.socket.of ''

      @emit = (eventName, data, callback) ->
        @socketNamespace.emit eventName, data, ->
          args = arguments
          $rootScope.$apply ->
            callback.apply @socketNamespace, args if callback

      # loop inside namespace, and have some shorthand
      @['of'] = (namespace)->

        # cache namespace, and only init if necessary
        unless namespaces[namespace]

          # init new namespace connection
          namespaces[namespace] = subSocket = new SocketNamespace socket.of namespace

          # socket manager
          subSocket.manager =
            connected: false
            connecting: true
            disconnect: ->
              if subSocket.manager.connecting or subSocket.manager.connected
                socket.socket.of(namespace).disconnect()
                subSocket.manager.connecting = subSocket.manager.connected = false
                $rootScope.$broadcast ':/admin:disconnect'
            connect: ->
              if not (subSocket.manager.connected or subSocket.manager.connecting)
                subSocket.manager.connecting = true
                socket.socket.of(namespace).packet type: "connect"

          socket.of(namespace).on 'connect', ->
            subSocket.manager.connecting = false
            subSocket.manager.connected = true

          socket.of(namespace).on 'error', ->
            $rootScope.$apply subSocket.manager.disconnect()

        namespaces[namespace]
  #SocketNamespace.prototype = socket
  o = new SocketNamespace socket
  o
]
