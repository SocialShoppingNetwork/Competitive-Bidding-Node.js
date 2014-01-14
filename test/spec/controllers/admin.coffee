'use strict'

describe 'Controller: AdminCtrl', () ->

  # load the controller's module
  beforeEach module 'exhibiaApp'

  AdminCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller) ->
    scope =
      $on: ->
    AdminCtrl = $controller 'AdminCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', () ->
    expect(3).toBe 3;
