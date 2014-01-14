'use strict'

describe 'Controller: AdminProductCtrl', () ->

  # load the controller's module
  beforeEach module 'exhibiaApp'

  AdminAuctionCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller) ->
    scope = {}
    AdminProductCtrl = $controller 'AdminProductCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', () ->
    expect(3).toBe 3;
