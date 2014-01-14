'use strict'

describe 'Controller: ChatCtrl', () ->

  # load the controller's module
  beforeEach module 'exhibiaApp'

  ChatCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller) ->
    scope =
      $on: ->
    ChatCtrl = $controller 'ChatCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', () ->
    expect(true).toBe true;
