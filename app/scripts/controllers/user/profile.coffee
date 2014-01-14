app.controller 'UserProfileCtrl', ['$scope', '$rootScope', '$routeParams', 'socket', '$location', 'util' , ($scope, $rootScope, $routeParams, socket, $location, util) ->
  socket = socket.of '/user'

  if $routeParams.code
    $scope.otherUserProfile = true

    socket.emit 'profile:list', $routeParams.code, (error, userProfile) ->
      return util.error error if error

      $scope.visitedProfile = userProfile

  else
    # @todo no need to retrieve user's password
    socket.emit 'profile:read', 'simple', (error, userProfile)->
      # @todo error handling
      return util.error error if error
      $scope = Object.merge $scope, userProfile

    socket.emit 'profile:read', 'proxy', (error, res)->
      # @todo error handling
      return util.error error if error

      $scope.addressSet = res.addressSet
      $scope.cardSet = res.cardSet

    $scope.edit = ->
      user =
        username: $scope.username
        firstName: $scope.firstName
        lastName: $scope.lastName
        email: $scope.email

      socket.emit 'profile:edit', user, (error, res) ->
        return util.error error if error

        # @todo success handling
        $location.path '/user/profile/'

    $scope.addAddress = ->
      $location.path '/user/address'

    $scope.createCard = ->
      $location.path '/user/card'

    $scope.deleteCard = ->
      @deleteDisabled = true
      socket.emit 'card:delete', @card.token, (error, res) =>
        if error
          @deleteDisabled = false
          return util.error error
        # success deleted on server, remove from scope
        $scope.cardSet = $scope.cardSet.exclude @card

    $scope.promoteCard = ->
      @promoteDisabled = true
      data =
        token: @card.token
        options: makeDefault: true

      socket.emit 'card:update', data, (error, res) =>

        # regardless the response, the button should be reenabled
        @promoteDisabled = false

        return util.error error if error

        # success promoting, change default attribute of each
        for card in $scope.cardSet
          if card.token is @card.token
            card['default'] = true
          else
            card['default'] = false

    $scope.removeAddress = ->
      @disabled = true
      socket.emit 'address:delete', @address.id, (error, res) =>
        if error
          @disabled = false
          return util.error error
        # success deleted on server, remove from scope
        $scope.addressSet = $scope.addressSet.exclude @address
]
