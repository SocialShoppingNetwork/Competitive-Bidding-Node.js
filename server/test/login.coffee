uril = require '../util'
Calculator = Calculator = ->
  add: add = (firstNum, secondNum) ->
    firstNum + secondNum

describe "Calculator", ->
  calculator = undefined
  beforeEach ->
    calculator = Calculator()

  describe "empty password cause crashing", ->
    it "adds two numbers together", ->
      numOne = 2
      numTwo = 6
      expectedResult = 8
      actualResult = calculator.add(numOne, numTwo)
      expect(actualResult).toEqual expectedResult


describe 'Util', ->
  describe 'encrypt()', ->
    it 'encrypt', ->
      plainText = 'abc'
      expectedEncrypt = 'CWX+o9aslRcdHKYyJpRx5g=='
      actualEncrypt = uril.encrypt plainText
      expect(actualEncrypt).toEqual expectedEncrypt
