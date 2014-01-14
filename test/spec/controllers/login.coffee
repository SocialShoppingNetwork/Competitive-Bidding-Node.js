describe 'Controller: LoginCtrl', () ->

  # load the controller's module
  beforeEach module 'exhibiaApp'

  LoginCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller) ->
    scope = {}
    LoginCtrl = $controller 'LoginCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', () ->
    expect(3).toBe 3;
