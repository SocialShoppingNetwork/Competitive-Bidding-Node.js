app.controller 'UserCardCtrl', ['$scope', '$rootScope', 'socket', '$location', 'util', ($scope, $rootScope, socket, $location, util) ->
  socket = socket.of '/user'

  $scope.create = ->
    # untouched $scope.address
    return unless $scope.card

    $scope.submitDisabled = true
    socket.emit 'card:create', $scope.card, (error, res) ->
      if error
        $scope.submitDisabled = false
        return util.error error

    # @todo success handling
      $location.path '/user/profile/'
]
