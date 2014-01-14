app.controller 'AdminItemCtrl', ['$scope', '$routeParams', 'socket', '$location', '$locale', 'util', ($scope, $routeParams, socket, $location, $locale, util) ->
  socket = socket.of '/admin'

  $scope.productMap = {}
  $scope.itemList = []

  # pass the whole $locale object, so that when this object immuates, specifically $locale.id changes, we don't have to do a thing
  $scope.$locale = $locale

  socket.emit 'product:read', null, (error, productList)->
    return util.error error if error

    for product in productList
      $scope.productMap[product.id] = product

  $scope.delete = ->
    socket.emit 'item:delete', @item._id, (err, res)=>

      # @todo error handling
      # if 4041 (not found, not deleted), continue to remove it from scope
      if err
        util.error err
        return if err.code isnt 4041

      # success deleted on server, remove from scope
      $scope.itemList = $scope.itemList.exclude @item

  $scope.create = ->
    productField = ['_id', 'code', 'name', 'description', 'image']
    product = Object.select $scope.productMap[$scope.product], productField
    item =
      product: product
      fundSizeRequired: $scope.newItem.fundSizeRequired
      sponsorCountRequired: $scope.newItem.sponsorCountRequired
      transitionTimeout: $scope.newItem.transitionTimeS * 1000
      competitionTimeout: $scope.newItem.competitionTimeS * 1000

    socket.emit 'item:create', item, (error, res)->
      # @todo error handling
      return util.error error if error
      # @todo success handling
      $scope.itemList.push res

      $scope.newItem = ''

  $scope.enableItem = ->
    item =
      id: @item._id
      state: 1
      openAt: Date.now()

    socket.emit 'item:enable', item, (error, res) ->
      # @todo error handling
      return util.error error if error

      # @todo success handling
      # back to admin page
      $location.path '/admin/item/'

  socket.emit 'item:read', null, (error, itemList) ->
    return util.error error if error
    $scope.itemList = itemList
]
