{expect} = require 'chai'
{luqr}   = require '../luqr'

pascal = [
  [1, 1,  1,  1,   1,   1]
  [1, 2,  3,  4,   5,   6]
  [1, 3,  6, 10,  15,  21]
  [1, 4, 10, 20,  35,  56]
  [1, 5, 15, 35,  70, 126]
  [1, 6, 21, 56, 126, 252]
]

pascalFlat = [
  1, 1,  1,  1,   1,   1
  1, 2,  3,  4,   5,   6
  1, 3,  6, 10,  15,  21
  1, 4, 10, 20,  35,  56
  1, 5, 15, 35,  70, 126
  1, 6, 21, 56, 126, 252
]

pi = [3, 1, 4, 1, 5, 9]

solution = [89, -361, 622, -547, 244, -44]

describe 'Library Compatibility', ->

  it 'decompose is compatible with Arrays of TypedArrays', ->
    A = pascal.map((r) -> new Float64Array(r))

    {L, d} = luqr.decomposeLDL(A)
    expect(L).to.be.an.instanceof(Array)
    expect(L[0]).to.be.an.instanceof(Float64Array)
    expect(d).to.be.an.instanceof(Float64Array)

    LF = luqr.flatten(L)
    expect(LF).to.be.an.instanceof(Float64Array)
    expect(LF.length).to.equal(36)

    {L, U} = luqr.decomposeLU(A)
    expect(L).to.be.an.instanceof(Array)
    expect(L[0]).to.be.an.instanceof(Float64Array)
    expect(U).to.be.an.instanceof(Array)
    expect(U[0]).to.be.an.instanceof(Float64Array)

    LF = luqr.flatten(L)
    expect(LF).to.be.an.instanceof(Float64Array)
    expect(LF.length).to.equal(36)

    {Q, R} = luqr.decomposeQR(A)
    expect(Q).to.be.an.instanceof(Array)
    expect(Q[0]).to.be.an.instanceof(Float64Array)
    expect(R).to.be.an.instanceof(Array)
    expect(R[0]).to.be.an.instanceof(Float64Array)

    QF = luqr.flatten(Q)
    expect(QF).to.be.an.instanceof(Float64Array)
    expect(QF.length).to.equal(36)

  it 'decompose is compatible with flat TypedArrays', ->
    A = luqr.fold(new Float64Array(pascalFlat), 6)

    {L, d} = luqr.decomposeLDL(A)

    expect(L).to.be.an.instanceof(Array)
    expect(L[0]).to.be.an.instanceof(Float64Array)
    expect(d).to.be.an.instanceof(Float64Array)

    LF = luqr.flatten(L)
    expect(LF).to.be.an.instanceof(Float64Array)
    expect(LF.length).to.equal(36)

    {L, U} = luqr.decomposeLU(A)
    expect(L).to.be.an.instanceof(Array)
    expect(L[0]).to.be.an.instanceof(Float64Array)
    expect(U).to.be.an.instanceof(Array)
    expect(U[0]).to.be.an.instanceof(Float64Array)

    LF = luqr.flatten(L)
    expect(LF).to.be.an.instanceof(Float64Array)
    expect(LF.length).to.equal(36)

    {Q, R} = luqr.decomposeQR(A)
    expect(Q).to.be.an.instanceof(Array)
    expect(Q[0]).to.be.an.instanceof(Float64Array)
    expect(R).to.be.an.instanceof(Array)
    expect(R[0]).to.be.an.instanceof(Float64Array)

    QF = luqr.flatten(Q)
    expect(QF).to.be.an.instanceof(Float64Array)
    expect(QF.length).to.equal(36)

  it 'decompose is compatible with glMat4', ->
    mat4 = require('gl-mat4')
    A = luqr.fold(mat4.create(), 4)

    {L, d} = luqr.decomposeLDL(A)
    expect(L).to.be.an.instanceof(Array)
    expect(L[0]).to.be.an.instanceof(Float32Array)
    expect(d).to.be.an.instanceof(Float32Array)

    {L, U} = luqr.decomposeLU(A)
    expect(L).to.be.an.instanceof(Array)
    expect(L[0]).to.be.an.instanceof(Float32Array)
    expect(U).to.be.an.instanceof(Array)
    expect(U[0]).to.be.an.instanceof(Float32Array)

    {Q, R} = luqr.decomposeQR(A)
    expect(Q).to.be.an.instanceof(Array)
    expect(Q[0]).to.be.an.instanceof(Float32Array)
    expect(R).to.be.an.instanceof(Array)
    expect(R[0]).to.be.an.instanceof(Float32Array)

  it 'decompose is compatible with ndarrays', ->
    ndarray = require('ndarray')
    A = ndarray([
      1, 1,  1,  1,
      1, 2,  3,  4,
      1, 3,  6, 10,
      1, 4, 10, 20
    ], [4, 4])
    A = luqr.fold(A.data, 4)

    {L, d} = luqr.decomposeLDL(A)
    expect(L).to.be.an.instanceof(Array)
    expect(L[0]).to.be.an.instanceof(Array)
    expect(d).to.be.an.instanceof(Array)

    {L, U} = luqr.decomposeLU(A)
    expect(L).to.be.an.instanceof(Array)
    expect(L[0]).to.be.an.instanceof(Array)
    expect(U).to.be.an.instanceof(Array)
    expect(U[0]).to.be.an.instanceof(Array)

    {Q, R} = luqr.decomposeQR(A)
    expect(Q).to.be.an.instanceof(Array)
    expect(Q[0]).to.be.an.instanceof(Array)
    expect(R).to.be.an.instanceof(Array)
    expect(R[0]).to.be.an.instanceof(Array)


  it 'solve compatible with Arrays of TypedArrays', ->
    A = pascal.map((r) -> new Float64Array(r))
    b = new Float64Array(pi)
    x = new Float64Array(solution)

    res = luqr.solve(A, b)
    expect(x).to.be.an.instanceof(Float64Array)
    expect(res).to.be.an.instanceof(Float64Array)
    expect(x).to.deep.equal(res)

  it 'solve compatible with flat TypedArrays', ->
    A = luqr.fold(new Float64Array(pascalFlat), 6)
    b = new Float64Array(pi)

    res = Array.prototype.slice.call luqr.solve(A, b)
    expect(solution).to.deep.equal(res)





