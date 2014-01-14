app.controller 'AdminCtrl',
['$scope', '$routeParams', 'socket', ($scope, $routeParams, socket) ->
  socket = socket.of '/admin'

  # on some conditions, set controller to its correspodent
  setController = ->
    if $routeParams.model in ['category', 'item', 'product', 'coupon']
      $scope.model = "views/admin/#{$routeParams.model}.html"

  if socket.manager.connected
    # if already connected, possibly by previous admin controller, set it
    setController()

  else if not socket.manager.connecting
    # otherwise, if socket is not connecting, display unauthorized
    $scope.model = "views/admin/unauthorized.html"


  # @todo error handling
  $scope.$on ':/admin:disconnect', ->
    $scope.model = "views/admin/unauthorized.html"

  $scope.$on ':/admin:connect', setController
]
