app.controller 'LoginCtrl',
['$rootScope', '$scope', 'socket', 'util', 'FB', ($rootScope, $scope, socket, util, FB)->

  socketUser = socket.of '/user'
  $scope.loginAction = false
  $scope.signupAction = false
  $scope.initAction = true

  $scope.enableLogin = ->
    $scope.initAction = false
    $scope.loginAction = true

  $scope.enableSignup = ->
    $scope.initAction = false
    $scope.signupAction = true

  # login function
  $scope.login = ->
    data =
      username: $scope.username
      password: $scope.password
    socket.emit 'user:login', data

  $scope.fbLogin = ->
    $scope.loginDisabled = true
    fn = (res)->
      $scope.loginDisabled = false
      if authResponse = res.authResponse
        socket.emit 'user:login'
          fbAccessToken: authResponse.accessToken
          #expiresIn
          #fbSignedRequest: authResponse.signedRequest
          fbUserID: Number(authResponse.userID)
    # @todo else
    FB.login fn, scope: 'email'

  # logout function
  $scope.logout = ->

    # @todo no acknowledge function
    socket.emit 'user:logout'

    # clear session
    util.cookie 'session', ''

    # null user
    $rootScope.session.user = null

    $rootScope.$broadcast 'user:logout'

  # signup function
  $scope.signup = ->
    user =
      username: $scope.username
      password: $scope.password
    socket.emit 'user:signup', user, (res) ->
      return util.error res if res.error
      socket.emit 'user:login', user
]

app.run ['$rootScope', 'util', 'socket', 'FB', ($rootScope, util, socket, FB)->
  # session init
  $rootScope.session = {}

  # listen for socket.io root namespace event in user:login
  $rootScope.$on '::user:login', (scope, res)->
    # @todo error handling
    if res.error
      return util.error res

    # @todo configurable cookie expiration
    util.cookie 'session', res.session, 30
    $rootScope.session.user = res.user

    # @todo dont auto connect to user
    socket.of('/admin').manager.connect()
    socket.of('/user').manager.connect()


  $rootScope.$on 'user:logout', ->
    # @todo dont auto connect to user
    socket.of('/admin').manager.disconnect()
    socket.of('/user').manager.disconnect()
]
