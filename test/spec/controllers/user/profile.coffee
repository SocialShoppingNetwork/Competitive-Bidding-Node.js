'use strict'

describe 'Controller: UserProfileCtrl', () ->

  # load the controller's module
  beforeEach module 'exhibiaApp'

  UserProfileCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller) ->
    scope = {}
    UserProfileCtrl = $controller 'UserProfileCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', () ->
    expect(3).toBe 3;
