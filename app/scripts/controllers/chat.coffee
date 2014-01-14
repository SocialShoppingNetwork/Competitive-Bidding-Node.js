app.controller 'ChatCtrl', ['$rootScope', '$scope', 'socket', 'util',($rootScope, $scope, socket, util) ->

  # init
  $scope.messageList = []
  # object id string of last massage sender, so that we can group chat message in thread
  lastSender = null

  # Private helpers
  pushData = (data)->
    # same sender, group it into thread
    if lastSender is data.name
      # assume $scope.messageList.last() isnt undefined, because we have lastSender isnt undefined/null
      $scope.messageList.last().message.push data.message
      # different sender
    else
      # update lastSender
      lastSender = data.name
      # zip the message into array
      data.message = [data.message]
      # create new thread
      $scope.messageList.push data

  parseData = (dataArray)->
    for data in dataArray
      pushData data

  # retrieve latest message for new user connection
  # @todo could be limited by thread or message
  # limit by 20 thread, configurable
  socket.emit 'user:join', null, (error, chatList) ->
    return util.error error if error

    parseData chatList

  $scope.$on '::message:send', (scope, data) ->
    pushData data

  # @todo temporary disable 'leave' notification
  # add a message to the conversation when a user disconnects or leaves the room
  #
  # $scope.$on '::user:leave', (scope, user) ->
  #   $scope.messageList.push
  #     name: 'chatroom',
  #     message: 'User ' + user.name + ' has left.'

  $scope.sendMessage = () ->
    data = message: $scope.message
    socket.emit 'message:send', data, (error)->
      # @todo error handling
      return util.error error if error

      data.name = $rootScope.session.user.name
      data.userId = $rootScope.session.user.id
      data.avatarUrl = $rootScope.session.user.avatarUrl
      # push it locally
      pushData data

      # clear message box
      $scope.message = ''
]
