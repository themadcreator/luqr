{expect}  = require 'chai'
{luqr}    = require '../luqr'
{utils}   = require './utils'
{asserts} = require './asserts'

makeSymmetric = (A) ->
  n = A.length
  for i in [0...n]
    for j in [i...n]
      A[i][j] = A[j][i]
  return A

diagonalize = (d) ->
  n = d.length
  D = [0...n].map (i) -> [0...n].map (j) -> if i is j then d[i] else 0
  return D

describe 'LDL Correctness', ->
  it 'can decompose a symmetric matrix equation', ->
    for i in [0...10]
      A = makeSymmetric utils.rand(5, 5)
      {L, d} = luqr.decomposeLDL(A)
      D   = diagonalize(d)
      LT  = utils.transpose(L)
      LDL = utils.multiply(L, utils.multiply(D, LT))
      asserts.assertIsSameMatrix(A, LDL)

  it 'can solve a symmetric matrix equation', ->
    for i in [0...10]
      A = makeSymmetric utils.rand(5, 5)
      b = utils.rand(1, 5)[0]
      x = luqr.solveLDL(A, b)
      asserts.assertIsCorrectSolution(A, x, b)
