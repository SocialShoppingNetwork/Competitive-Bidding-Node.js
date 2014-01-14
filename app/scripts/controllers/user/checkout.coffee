app.controller 'UserChekoutCtrl', ['$scope', '$rootScope', '$routeParams', 'socket', '$location', 'util', '$dialog', ($scope, $rootScope, $routeParams, socket, $location, util, $dialog) ->
  socket = socket.of '/user'

  socket.emit 'basket:read', 'checkout', (error, data) ->
    return util.error error if error

    if data.item.isEmpty()
      $scope.noCheckoutItem = "You don't have any available item for checkout."
    else
      $scope.winItem = data.item

      if $routeParams.code
        $scope.checkingout = true
        checkoutItem = $scope.winItem.find (item) ->
          item._id is $routeParams.code
        socket.emit 'profile:read', 'proxy', (error, addSet) ->
          return util.error error if error

          $scope.addressSet = addSet.addressSet

          # initial shipping address to prevent null value
          unless $scope.addressSet.isEmpty()
            $scope.shipAddId = $scope.addressSet.first().id
            $scope.shipAdd = $scope.addressSet.first()

        Object.merge $scope, checkoutItem

  $scope.checkout = ->
    $location.path '/user/checkout/' + @item._id

  $scope.change = ->
    $scope.shipAdd = $scope.addressSet.find (address) =>
      address.id == @shipAddId

  $scope.pay = ->
    title = 'Final Payment'
    msg = 'Please confirm your final payment.'
    btns = [{result: false, label: 'Cancel'}, {result: true, label: 'OK', cssClass: 'btn-primary'}]

    # popup a confirm dialog
    $dialog.messageBox(title, msg, btns)
      .open()
      # process if user choose 'OK', nothing happens otherwise
      .then (confirm) =>
        if confirm
          shipAdd = $scope.addressSet.find (address) =>
            address.id is @shipAddId

          # @todo shipAdd and billAdd are required
          data =
            itemId: @_id
            amount: @price
            shipAdd: shipAdd

          socket.emit 'basket:pay', data, (error, res) ->
            return util.error error if error
            # back to general checkout page and display success message
            $location.path '/user/checkout/'
            util.success 'Payment successfull'
]
