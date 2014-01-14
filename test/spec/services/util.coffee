'use strict'

describe 'Service: util', () ->

  # load the service's module
  beforeEach module 'exhibiaApp'

  # instantiate service
  util = {}
  beforeEach inject (_util_) ->
    util = _util_

  it 'should do something', () ->
    expect(!!util).toBe true;
