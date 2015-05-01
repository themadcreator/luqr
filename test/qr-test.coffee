{expect}  = require 'chai'
{luqr}    = require '../luqr'
{utils}   = require './utils'
{asserts} = require './asserts'

assertIsValidQRDecomposition = (A, Q, R) ->
  m = A.length
  n = A[0].length

  # ASSERT: Q has orthogonal unit vector columns
  cols = utils.transpose(Q)
  for i in [0...m]
    a = cols[i]
    expect(utils.dot(a, a)).to.be.closeTo(1, 1e-3) # Unit length
    continue unless i < (m - 1)
    b = cols[i + 1]
    expect(utils.dot(a, b)).to.be.closeTo(0, 1e-3) # Orthgonal

  # ASSERT: R is upper triangular
  for i in [1...m] by 1
    for j in [0...Math.min(n, i)]
      expect(R[i][j]).to.equal(0)

  # ASSERT: Q * R is A
  QR = utils.multiply(Q, R)
  asserts.assertIsSameMatrix(A, QR)

  return

assertIsLeastErrorSolution = (A, x, b) ->
  # ASSERT: ||A * x - b|| is minimized
  z = utils.vectorMultiply(A, x)
  diffBest = utils.normDifference(z, b)
  for i in [0...x.length]
    y = x.slice()
    y[i] += Math.random() - 0.5 # Perturb y to test if difference increases
    z = utils.vectorMultiply(A, y)
    diffPerturbed = utils.normDifference(z, b)
    expect(diffPerturbed).to.be.greaterThan(diffBest)
  return

describe 'QR Correctness', ->


  describe 'Decomposition of random matrices', ->
    it 'can decompose a random square matrix', ->
      for i in [0...10]
        A = utils.rand(5, 5)
        {Q, R} = luqr.decomposeQR(A)
        assertIsValidQRDecomposition(A, Q, R)

    it 'can decompose a random underdetermined matrix', ->
      for i in [0...10]
        A = utils.rand(3, 5)
        {Q, R} = luqr.decomposeQR(A)
        assertIsValidQRDecomposition(A, Q, R)

    it 'can decompose a random overdetermined matrix', ->
      for i in [0...10]
        A = utils.rand(5, 3)
        {Q, R} = luqr.decomposeQR(A)
        assertIsValidQRDecomposition(A, Q, R)

    it 'can decompose a random large matrix', ->
      A = utils.rand(100, 100)
      {Q, R} = luqr.decomposeQR(A)
      assertIsValidQRDecomposition(A, Q, R)


  describe 'Solution of random equations', ->
    it 'can solve an equation with a square matrix', ->
      for i in [0...10]
        A = utils.rand(5, 5)
        b = utils.rand(1, 5)[0]
        x = luqr.solveQR(A, b)
        asserts.assertIsCorrectSolution(A, x, b)

    it 'can solve an equation with a underdetermined matrix', ->
      for i in [0...10]
        A = utils.rand(3, 5)
        b = utils.rand(1, 3)[0]
        x = luqr.solveQR(A, b)
        asserts.assertIsCorrectSolution(A, x, b)

    it 'can solve a least squares approximation with a overdetermined matrix', ->
      for i in [0...10]
        A = utils.rand(5, 3)
        b = utils.rand(1, 5)[0]
        x = luqr.solveQR(A, b)
        assertIsLeastErrorSolution(A, x, b)
