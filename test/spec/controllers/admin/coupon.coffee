'use strict'

describe 'Controller: AdminCouponCtrl', () ->

  # load the controller's module
  beforeEach module 'exhibiaApp'

  AdminCouponCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller) ->
    scope = {}
    AdminCouponCtrl = $controller 'AdminCouponCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', () ->
    expect(scope.awesomeThings.length).toBe 3;
