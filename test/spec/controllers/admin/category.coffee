describe 'Controller: AdminCategoryCtrl', () ->

  # load the controller's module
  beforeEach module 'exhibiaApp'

  AdminCategoryCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller) ->
    scope = {}
    AdminItemCtrl = $controller 'AdminItemCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', () ->
    expect(3).toBe 3;
