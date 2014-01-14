app.controller 'UserAddressCtrl', ['$scope', '$rootScope', 'socket', '$location', 'util', ($scope, $rootScope, socket, $location, util) ->
  socket = socket.of '/user'

  $scope.countryList = [
    ['US', 'USA']
    ['FI', 'Finland']
    ['DE', 'Germany']
    ['VN', 'Vietnam']
  ]
  $scope.add = ->
    # untouched $scope.address
    return unless $scope.address

    socket.emit 'address:create', $scope.address, (error, res) ->
      return util.error error if error

      # @todo success handling
      $location.path '/user/profile/'
]
