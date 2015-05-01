{expect} = require 'chai'
{utils}  = require './utils'

# ASSERT: A is B
assertIsSameMatrix = (A, B) ->
  for i in [0...A.length]
    for j in [0...A[0].length]
      expect(A[i][j]).to.be.closeTo(B[i][j], 1e-3)
  return

# ASSERT: A * x is b
assertIsCorrectSolution = (A, x, b) ->
  z = utils.vectorMultiply(A, x)
  for i in [0...b.length]
    expect(b[i]).to.be.closeTo(z[i], 1e-3)
  return

asserts = {
  assertIsSameMatrix
  assertIsCorrectSolution
}
module.exports = {asserts}