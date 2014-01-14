app.controller 'UserFeedbackCtrl', ['$scope', '$rootScope', '$routeParams', 'socket', '$location', 'util' , ($scope, $rootScope, $routeParams, socket, $location, util) ->
  socket = socket.of '/user'

  socket.emit 'basket:read', 'feedback', (error, data) ->
    return util.error error if error

    if data.item.isEmpty()
      $scope.noFeedbackItem = "You don't have any available item for feedback."
    else
      $scope.feebackItem = data.item

      if $routeParams.code
        $scope.feedbacking = true

        feedbackItem = $scope.feebackItem.find (item) ->
          item._id is $routeParams.code

        Object.merge $scope, feedbackItem

  $scope.feedback = ->
    $location.path 'user/feedback/' + @item._id

  $scope.submit = ->
    # prevent user changing routeParams on purpose
    if $scope._id
      data =
        itemId: $routeParams.code
        # @todo message maxlength is 300 and configurable
        message: @message
    else
      err =
        code: 4040
        message: 'Item not recognized'
      util.error err

    socket.emit 'item:feedback', data, (error, res) ->
      return util.error error if error

      $location.path 'user/feedback/'
      util.success 'Thank you for your feedback'
]
