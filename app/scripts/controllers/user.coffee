app.controller 'UserCtrl',
['$scope', '$routeParams', 'socket', ($scope, $routeParams, socket) ->
  socket = socket.of '/user'

  # on some conditions, set controller to its correspodent
  setController = ->
    if $routeParams.model in ['profile', 'address', 'card', 'checkout', 'feedback', 'coupon']
      $scope.model = "views/user/#{$routeParams.model}.html"

  # if already connected, possibly by previous admin controller, set it
  if socket.manager.connected
    setController()

  else if not socket.manager.connecting
    # otherwise, if socket is not connecting, display unauthorized
    $scope.model = "views/admin/unauthorized.html"


  # @todo error handling
  $scope.$on ':/user:disconnect', ->
    $scope.model = 'views/admin/unauthorized.html'

  $scope.$on ':/user:connect', setController
]
