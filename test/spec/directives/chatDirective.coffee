'use strict'

describe 'Directive: chatDirective', () ->
  beforeEach module 'exhibiaApp'

  element = {}

  it 'should make hidden element visible', inject ($rootScope, $compile) ->
    element = angular.element '<chat-directive></chat-directive>'
    element = $compile(element) $rootScope
    #expect(element text()).toBe 'this is the chatDirective directive'
