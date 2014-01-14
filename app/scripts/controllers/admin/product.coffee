app.controller 'AdminProductCtrl',
['$scope', '$routeParams', 'socket', '$location', '$timeout', 'util', ($scope, $routeParams, socket, $location, $timeout, util) ->
  socket = socket.of '/admin'

  $scope.language = 'en'

  # init empty l10n
  $scope.description = {}
  $scope.name = {}

  $scope.productList = []
  # get category list from server
  socket.emit 'category:read', null, (error, categoryList)->
    return util.error error if error
    $scope.categoryList = categoryList

  $scope.delete = ->
    socket.emit 'product:delete', @product.id, (error)=>

      # @todo error handling
      # if 4041 (not found, not deleted), continue to remove it from scope
      if error
        util.error error
        return if error.code isnt 4041

      # success deleted on server, remove from scope
      $scope.productList = $scope.productList.exclude @product

  $scope.create = ->
    product =
      code: $scope.code
      name: $scope.name
      category: $scope.category
      description: $scope.description

    # only send sever image with 'data:' but not 'http:' or 'https:'
    if $scope.imageUrl?.slice(0,5) is 'data:'
      product.imageUrl = $scope.imageUrl

    socket.emit 'product:create', product, (error, res)->
      # @todo error handling
      return util.error error if error

      # @todo success handling
      util.success 'Successfully create product'
      # add newly created product to the list
      $scope.productList.push res

  $scope.edit = ->

    product = Object.select $scope, [
      'id'
      'code'
      'name'
      'category'
      'description'
    ]

    # only send sever image with 'data:' but not 'http:' or 'https:'
    if $scope.imageUrl?.slice(0,5) is 'data:'
      product.imageUrl = $scope.imageUrl

    socket.emit 'product:update', product, (error, res)->
      # @todo error handling
      return util.error error if error

      # @todo success handling
      util.success "Successfully edit product with code #{$scope.code}"

      # back to admin page
      $location.path '/admin/product/'

  $scope.editProductLocation = ->
    $location.path '/admin/product/' + @product.code

  socket.emit 'product:read', null, (error, productList)->
    return util.error error if error

    $scope.productList = productList
    $scope.enableEdit = false
    if $routeParams.code
      editProduct = $scope.productList.find (product) ->
        product.code == $routeParams.code
      $scope.enableEdit = true

      Object.merge $scope, editProduct
      $scope.id = editProduct.id
]
