describe 'Controller: MainCtrl', ->
  # global variable wrapped in _ object
  $controller = null
  $scope = null
  socket = null

  class $dialogMock
    constructor: ->
      @
    $setResult: (result)->
      @$callback(result)

    messageBox: ->
      @
    open: ->
      @
    then: (callback)->
      @$callback = callback

  # load the controller's module
  beforeEach module 'exhibiaApp'

  # Initialize the controller and a mock scope
  beforeEach inject (_$controller_, _$rootScope_, _socket_)->
    $scope = _$rootScope_.$new()
    socket = _socket_
    $controller = _$controller_


  describe 'Socket namespace /user', ->

    it 'should be established', ->
      spyOn(socket, 'of').andCallThrough()
      $controller 'MainCtrl',
        $scope: $scope
        socket: socket

      expect(socket.of.callCount).toBe 1
      expect(socket.of).toHaveBeenCalledWith '/user'

    it 'should read item', ->
      spyOn(socket, 'emit')
      $controller 'MainCtrl',
        $scope: $scope
        socket: socket
        $route:
          current:
            controller: 'MainCtrl'
            params: {}
      $scope.$apply()
      expect(socket.emit.callCount).toBe 1
      expect(socket.emit.mostRecentCall.args[0]).toBe 'item:read'
      expect(socket.emit.mostRecentCall.args[1]).toBeNull()

  describe 'Compete button', ->

    #==============================================================================
    it 'is a function', ->
      socketUser = socket.of('/user')
      spyOn(socketUser, 'emit')
      $controller 'MainCtrl',
        $scope: $scope
        socket: socket
      context =
        item:
          id: 'itemId'
      expect(socketUser.emit.callCount).toBe 0
      $scope.compete.apply context
      expect(socketUser.emit.callCount).toBe 1
      expect(socketUser.emit.mostRecentCall.args[0]).toBe 'item:compete'
      expect(socketUser.emit.mostRecentCall.args[1].id).toBe context.item.id
    #==============================================================================
    # Error due to integration modal into main controller
    ###
    it 'should be disabled and enabled corespondingly', ->
      socketUser = socket.of('/user')
      spyOn(socketUser, 'emit').andCallThrough()
      dialog = new $dialogMock()
      $controller 'MainCtrl',
        $scope: $scope
        socket: socket
        $dialog: dialog
      context =
        item:
          id: 'itemId'
      # at first, it should undefined
      expect(context.competeDisabled).toBeUndefined()
      # call the compete function with context
      $scope.compete.apply context
      # then it sould be true
      expect(context.competeDisabled).toBeTruthy()
      # callback function is called
      socketUser.emit.mostRecentCall.args[2] {}
      # the it should be false
      expect(context.competeDisabled).toBeFalsy()
    ###
