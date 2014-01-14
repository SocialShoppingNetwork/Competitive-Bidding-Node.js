app.controller 'AdminCouponCtrl', ['$scope', 'socket', 'util', ($scope, socket, util) ->
  socket = socket.of '/admin'

  # get coupon list from server
  socket.emit 'coupon:read', null, (error, couponList)->
    return util.error error if error

    couponList.forEach (coupon) ->
      if coupon.redeemedAt
        coupon.redeemedAt = moment(coupon.redeemedAt).format('LLLL')
      else
        coupon.redeemedAt = 'Coupon available'


    $scope.couponList = couponList

  $scope.submit = ->
    coupon = value: $scope.couponValue
    $scope.couponValue = ''

    socket.emit 'coupon:create', coupon, (error, couponValue, couponCode)->
      # @todo error handling
      return util.error error if error

      coupon =
        value: couponValue
        couponCode: couponCode
        redeemedAt: 'Coupon available'
      # @todo success handling
      $scope.couponList.push coupon
]
