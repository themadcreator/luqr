
transpose = (x) ->
  m = x.length
  n = x[0].length
  y = x.constructor.apply(null, [n])
  for i in [0...n]
    y[i] = x[0].constructor.apply(null, [m])
    for j in [0...m]
      y[i][j] = x[j][i]
  return y

multiply = (A, B) ->
  m = A.length
  n = A[0].length
  k = B.length

  res = []
  p = if k is 1 then 0 else B[0].length - 1

  if k is 0
    throw new Error("BAD SIZE: Zero width B")
  else if n isnt k
    throw new Error("BAD SIZE: #{n} vs #{k}")
  else
    n = k

    for q in [0...m]
      res.push [0]

    for q in [0...m]
      for w in [0...p]
        res[q].push 0

    for i in [0...m]
      for j in [0...(p+1)]
        for r in [0...n]
          res[i][j] = A[i][r] * B[r][j] + res[i][j]
  return res

vectorMultiply = (A, x) ->
  z = utils.transpose([x])
  z = utils.multiply(A, z)
  z = utils.transpose(z)[0]
  return z

normDifference = (a, b) ->
  sumSquares = a.map((v, i) ->
    d = (v - b[i])
    return d * d
  ).reduce((x, y) -> x + y)
  return Math.sqrt(sumSquares)

rand = (rows, cols, scale = 10) ->
  return [0...rows].map -> [0...cols].map -> Math.random() * scale

dot = (a, b) ->
  sum = 0
  for ai, i in a
    sum += ai * b[i]
  return sum

hypotenuse = (a, b) ->
  if Math.abs(a) > Math.abs(b)
    r = b / a
    return Math.abs(a) * Math.sqrt(1 + r * r)

  if b isnt 0
    r = a / b
    return Math.abs(b) * Math.sqrt(1 + r * r)

  return 0.0

prettyPrint = (A, fixed = 4, delim = '  ') ->
  m = A.length
  n = A[0].length

  str = '[\n'
  for i in [0...m]
    str += '  ' + A[i].map((v) ->
      v = v.toFixed(fixed)
      if v >= 0 then v = ' ' + v
      return v
     ).join(delim) + '\n'
  str += ']'
  return str

utils = {
  rand
  dot
  vectorMultiply
  normDifference
  transpose
  multiply
  prettyPrint
}
module.exports = {utils}