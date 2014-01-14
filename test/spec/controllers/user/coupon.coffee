'use strict'

describe 'Controller: UserCouponCtrl', () ->

  # load the controller's module
  beforeEach module 'exhibiaApp'

  UserCouponCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller) ->
    scope = {}
    UserCouponCtrl = $controller 'UserCouponCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', () ->
    expect(scope.awesomeThings.length).toBe 3;
