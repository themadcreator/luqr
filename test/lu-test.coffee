{expect}  = require 'chai'
{luqr}    = require '../luqr'
{utils}   = require './utils'
{asserts} = require './asserts'

describe 'LU Correctness', ->
  it 'can decompose a non-symmetric matrix equation', ->
    for i in [0...10]
      A = utils.rand(5, 5)
      {L, U} = luqr.decomposeLU(A)
      LU = utils.multiply(L, U)
      asserts.assertIsSameMatrix(A, LU)

  it 'can solve a non-symmetric matrix equation', ->
    for i in [0...10]
      A = utils.rand(5, 5)
      b = utils.rand(1, 5)[0]
      x = luqr.solve(A, b)
      asserts.assertIsCorrectSolution(A, x, b)
