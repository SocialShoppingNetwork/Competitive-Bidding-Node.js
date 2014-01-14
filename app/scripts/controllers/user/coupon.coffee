app.controller 'UserCouponCtrl', ['$scope', 'socket', 'util', ($scope, socket, util) ->
  socket = socket.of '/user'

  $scope.submit = ->
    socket.emit 'coupon:redeem', $scope.couponCode, (error, res)->
      # @todo error handling
      return util.error error if error

      util.success 'You now have $' + res + ' in your balance.'
]
