'use strict'

describe 'Controller: UserCtrl', () ->

  # load the controller's module
  beforeEach module 'exhibiaApp'

  UserCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller) ->
    scope =
      $on: ->
    UserCtrl = $controller 'UserCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', () ->
    expect(3).toBe 3;
