((window)->
  toString = Object.prototype.toString
  Object.prototype.toString = ->
    if @ instanceof CArray
      return '[object Array]'
    toString.apply @

  class CArray extends Array
    size = null
    shift = Array.prototype.shift
    CArray::__defineGetter__ 'size', -> size
    constructor: (s)->
      if typeof s is 'number'
        size = s
        super
      else if s.length
        size = s.length
        super s.length
        @parse s
      else
        throw new Error 'Invalid constructor parameter'
    push: ->
      if @length is size
        # as if we were calling this.pop() and pop() werent undefined
        shift.apply @
      super
    parse: (a)->
      for e in a
        @.push e

    pop: undefined
    shift: undefined
    unshift: undefined

  window.CArray or= CArray
)(window)
