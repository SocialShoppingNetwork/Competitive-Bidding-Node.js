app.controller 'AdminCategoryCtrl', ['$scope', '$routeParams', 'socket', 'util', ($scope, $routeParams, socket, util) ->
  socket = socket.of '/admin'

  # get category list from server
  socket.emit 'category:read', null, (error, categoryList)->
    return util.error error if error
    $scope.categoryList = categoryList

  $scope.delete = ->
    socket.emit 'category:delete', @category.id, (error)=>

      # @todo error handling
      # if 4041 (not found, not deleted), continue to remove it from scope
      if error
        util.error error
        return if error.code isnt 4041

      # success deleted on server, remove from scope
      $scope.categoryList = $scope.categoryList.exclude @category

  $scope.submit = ->
    category =
      code: $scope.code
      name: $scope.name
    socket.emit 'category:create', category, (error, res)->
      # @todo error handling
      return util.error error if error
      category.id = res.id
      # @todo success handling
      $scope.categoryList.push category
]
