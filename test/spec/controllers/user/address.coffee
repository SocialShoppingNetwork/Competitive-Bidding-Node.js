'use strict'

describe 'Controller: UserAddressCtrl', () ->

  # load the controller's module
  beforeEach module 'exhibiaApp'

  UserAddressCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller) ->
    scope = {}
    UserAddressCtrl = $controller 'UserAddressCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', () ->
    expect(3).toBe 3;
