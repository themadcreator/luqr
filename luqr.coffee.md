# Matrix Decomposer and Solver

This javascript library decomposes a matrix {{tex('A')}} using **LU**,
**LDL**, or **QR** decomposition and solves linear matrix equations such as
{{tex('A x = b')}}.

Written in **literate coffescript**, this document is generated directly from the
library source.

100% unit test coverage for correctness and compatibility. No outside dependencies.

[github repository](https://github.com/themadcreator/luqr)

### Installation

~~~
npm install luqr
~~~

or

~~~
bower install luqr
~~~

or

[download minified javascript](https://raw.githubusercontent.com/themadcreator/luqr/latest/luqr.min.js)


### Usage

For example, to decompose a matrix {{tex('A')}} into lower and upper
triangular matrices:

~~~
luqr = require('luqr').luqr

A = [
  [1, 1,  1]
  [0, 2,  5]
  [2, 5, -1]
]

{L, U} = luqr.decomposeLU(A)
~~~

Then, `L` is
~~~
[
  [1,   0, 0]
  [0,   1, 0]
  [2, 1.5, 1]
]
~~~

`U` is
~~~
[
  [1, 1,     1]
  [0, 2,     5]
  [0, 0, -10.5]
]
~~~

And, for example, to solve {{tex('A x = b')}}:
~~~
b = [6, -4, 27]
x = luqr.solve(A, b)
~~~

then `x` is
~~~
[5, 3, -2]
~~~

### What's the Difference between LU, LDL, and QR decomposition?

**LU Decomposition** decomposes a **square** matrix {{tex('A')}} into a lower
triangular matrix, {{tex('L')}}, and an upper triangular matrix, {{tex('U')}},
such that {{tex('A = L U')}}. To solve a linear equation like
{{tex('A x = b')}} we can use forward substition to solve {{tex('L y = b')}}
for {{tex('y')}}, then backward subtitution to solve {{tex('U x = y')}} for
{{tex('x')}}.

**LDL Decomposition**, on the other hand, decomposes a **square**,
**symmetric** matrix into a lower triangular matrix, {{tex('L')}}, and a
diagonal matrix {{tex('D')}}, such that {{tex('A = L D L^\\intercal')}}. To
solve a linear equation like {{tex('A x = b')}} we can use forward substition
to solve {{tex('L y = b')}} for {{tex('y')}}, then solve diagonal {{tex('D z = y')}}
for {{tex('z')}}, then finally use backward subtitution to solve
{{tex('L^\\intercal x = z')}} for {{tex('x')}}.

**QR Decomposition** decomposes any m-by-n matrix {{tex('A')}} into an m-by-m
matrix {{tex('Q')}} whose columns are orthogonal unit vectors and an m-by-n
upper triangular matrix, {{tex('R')}}, such that {{tex('A = Q R')}}. Works for
both overdetermined and underdetermined matrices. To solve a linear equation
like {{tex('A x = b')}}, our algorithm produces a partial result {{tex('QR')}}
from which we construct {{tex('Q^\\intercal b = y')}} then solve
{{tex('R x = y')}} for {{tex('x')}}.

### Which one should I use?

If you aren't sure, just use the `solve` method, and it will choose the best
decomposition method for you.

Otherwise, this table may help you choose a decomposition method based on the
characteristics of your matrix {{tex('A')}}.

| Method | Matrix Requirements | Speed |
| --- | --- | --- |
| LDL | square, symmetric, non-singular | Fastest |
| LU | square, non-singular | Fast |
| QR | any | Moderate |


### What about Cholesky Decomposition?

LDL decomposition is just as fast as Cholesky decomposition, but LDL avoids
performing any square roots and is therefore faster and more numerically
stable. For more, see this
[wikipedia article](http://en.wikipedia.org/wiki/Cholesky_decomposition#LDL_decomposition).

### Compatibility

By default, all methods expect matrices to be an Array of Arrays or an Array
of TypedArrays.

But, since we want this library to be utilized across many different formats
for matrix storage, we support input and output of flat or multidimensional
Arrays or TypedArrays.

To use a flat array, simply use the `fold` and `flatten` methods.

~~~
luqr = require('luqr').luqr

# A flat TypedArray representing a 3-by-3 matrix
flat = new Float32Array([1, 1, 1, 0, 2, 5, 2, 5, -1])

# Fold the TypedArray
A = luqr.fold(flat, 3)

# Perform decomposition
{L, U} = luqr.decomposeLU(A)

# Flatten the output matrices. These will be Float32Arrays
L = luqr.flatten(L)
U = luqr.flatten(U)
~~~

# API

## module wrapper

    ((namespace) ->

## decomposeLU(A)

Decomposes a **square** matrix {{tex('A')}} into a lower triangular matrix,
{{tex('L')}}, and an upper triangular matrix, {{tex('U')}}, such that
{{tex('A = L U')}}.

### Input:
- `A` : An n-length Array containing n-length Arrays or TypedArrays.

### Output:
Returns an `Object` that contains:
- `L` : An Array containing the rows of the decomposition result L, a lower triangular matrix
- `U` : An Array containing the rows of the decomposition result U, an upper triangular matrix

      decomposeLU = (A) ->
        # Verify inputs. Require an n-by-n matrix `A`.
        return null unless isSquareMatrix(A)

        n = A.length
        L = [0...n].map(-> copy(A[0], -> 0))
        U = [0...n].map(-> copy(A[0], -> 0))

        # Initialize L's daigonal
        for j in [0...n]
          L[j][j] = 1

        # Initialize U's first row
        for j in [0...n]
          U[0][j] = A[0][j]

        # Doolittle's Algorithm
        for i in [1...n]
          for j in [0...n]

            # Fill in L's row up to i
            for k in [0...i]
              s = A[i][k]
              for p in [0...k]
                s -= L[i][p] * U[p][k]
              L[i][k] = s / U[k][k]

            # Fill in U's row from i to n
            for k in [i...n]
              s = A[i][k]
              for p in [0...i]
                s -= L[i][p] * U[p][k]
              U[i][k] = s

        return {L, U}

## decomposeLDL(A)

Decomposes a **square**, **symmetric** matrix into a lower triangular matrix,
{{tex('L')}}, and a diagonal matrix {{tex('D')}}, such that
{{tex('A = L D L^\\intercal')}}

### Input:
- `A` : An n-length Array containing n-length Arrays or TypedArrays.

### Output:
If no decomposition exists, this method returns `null`. Otherwise, it returns
an `Object` that contains:
- `L` : An Array containing the rows of the decomposition result matrix
- `d` : An Array containing the diagonal elements of D

      decomposeLDL = (A) ->
        # Verify inputs. Require an n-by-n symmetric matrix `A`.
        return null unless isSquareMatrix(A) and isSymmetricMatrix(A)

        # Intialize outputs matrix `L` and diagonal array `d`.
        n = A.length
        L = [0...n].map(-> copy(A[0], -> 0))
        d = copy(A[0], -> 0)

        # For each row in `L`:
        for j in [0...n]

          # Compute diagonal of `L` and `D`.
          L[j][j] = 1
          a       = A[j][j]
          for k in [0...j]
            a -= d[k] * L[j][k] * L[j][k]
          d[j] = a

          # If diagonal `d[j]` is zero, then `A` has no decomposition.
          # So, return `null`.
          if d[j] is 0 then return null

          # Zero rest of row and adjust further rows of `L`.
          for i in [(j + 1)...n]
            L[j][i] = 0
            a       = A[i][j]
            for k in [0...j]
              a -= d[k] * L[i][k] * L[j][k]
            L[i][j] = a / d[j]

        # Finally, return decomposition.
        return {L, d}

## decomposeQRPartial(A)

Decomposes any m-by-n matrix {{tex('A')}} into an m-by-m matrix {{tex('Q')}}
whose columns are orthogonal unit vectors and an m-by-n upper triangular
matrix, {{tex('R')}}, such that {{tex('A = Q R')}}. Works for both
overdetermined and underdetermined matrices.

This algorithm uses the *Householder Reflections* approach which is more
stable than the *Gram–Schmidt* process. For more, see this [wikipedia article](http://en.wikipedia.org/wiki/QR_decomposition).

The output is somewhat awkward, but it is not necessary to completely
construct {{tex('Q')}} and {{tex('R')}} to solve {{tex('A x = b')}}.

This method based on [this mapack implementation](https://github.com/lutzroeder/Mapack/blob/master/Source/QrDecomposition.cs)

### Input:
- `A` : An m-length Array containing n-length Arrays or TypedArrays.

### Output:
Returns an `Object` that contains:
- `QR` : An Array containing the rows of the decomposition result QR. The
lower triangular part contains the essential components of Q as well as
most of R in the upper triangular part.
- `d` : An Array containing the remanining diagonal components of R.
- `singular` : A boolean indicating weather or not the matrix A is singular.
algorithm will still produce a value for Q and R regardless.

      decomposeQRPartial = (A) ->
        QR       = copy(A, (a) -> copy(a))
        m        = A.length
        n        = A[0].length
        d        = [0...m].map -> 0
        singular = false

        for k in [0...n] by 1
          # Compute 2-norm of k-th column.
          # TODO use hypotenuse to avoid over/underflow
          sum = 0
          for i in [k...m] by 1
            sum += QR[i][k] * QR[i][k]
          nrm = Math.sqrt(sum)

          # Detect singular case.
          if nrm is 0.0
            d[k]     = 0
            singular = true
            continue

          # Form k-th Householder vector.
          if QR[k][k] < 0 then nrm *= -1
          for i in [k...m] by 1
            QR[i][k] /= nrm
          QR[k][k] += 1.0

          # Apply transformation to remaining columns.
          for j in [(k+1)...n] by 1
            sum = 0
            for i in [k...m] by 1
              sum += QR[i][k] * QR[i][j]
            sum = -sum / QR[k][k]

            for i in [k...m] by 1
              QR[i][j] += sum * QR[i][k]

          d[k] = -nrm
        return {QR, d, singular}

## decomposeQR(A)

Decomposes any m-by-n matrix {{tex('A')}} into an m-by-m matrix {{tex('Q')}}
whose columns are orthogonal unit vectors and an m-by-n upper triangular
matrix, {{tex('R')}}, such that {{tex('A = Q R')}}. Works for both
overdetermined and underdetermined matrices.

This method computes the partial solution and then constructs the matrices
{{tex('Q')}} and {{tex('R')}}.

### Input:
- `A` : An m-length Array containing n-length Arrays or TypedArrays.

### Output:
Returns an `Object` that contains:
- `Q` : An Array containing the rows of the decomposition result Q, whose
columns are orthogonal unit vectors and an upper triangular matrix. i.e.
{{tex('Q^\\intercal Q = I')}}
- `R` : An m-by-n Array containing decomposition result R, an upper triangular matrix
- `singular` : A boolean indicating weather or not the matrix A is singular. This
algorithm will still produce a value for Q and R regardless.

      decomposeQR = (A) ->
        {QR, d, singular} = decomposeQRPartial(A)
        m = A.length
        n = A[0].length

        # Create m-by-n upper triangular matrix R.
        R = reshape(m, n, A[0])

        # Fill in R
        for i in [0...m]
          for j in [0...n]
            if i < j or j >= m then R[i][j] = QR[i][j]
            else if i is j then R[i][j] = d[i]
            else R[i][j] = 0

        # Create the orthogonal matrix Q.
        Q = reshape(m, m, A[0])

        # Construct the rest of Q
        for k in [(m - 1)..0] by -1
          for i in [0...m] by 1
            Q[i][k] = 0.0

          Q[k][k] = 1.0
          for j in [k...m] by 1
            if not (j < m) then continue
            if QR[k][k] isnt 0 and QR[k]?[k]?
              s = 0
              for i in [k...m] by 1
                s += QR[i][k] * Q[i][j]
              s = -s / QR[k][k]

              for i in [k...m] by 1
                Q[i][j] += s * QR[i][k]

        return {Q, R, singular}

## solve(A,b)

Solves a system of linear equations expressed by the matrix equation {{tex('A x = b')}}.

{{tex('A')}} is an m-by-n matrix and {{tex('b')}} is a 1-by-n vector.

### Input:
- `A` : An m-length Array containing n-length Arrays or TypedArrays.
- `b` : An n-length Array or TypedArray

### Output
- `x` : An n-length Array or TypedArray withe the solution or `null` if no solution exists.

      solve = (A, b) ->
        # Verify inputs. Require an m-by-n matrix `A` and 1-by-n vector `b`.
        return null unless b.length is A.length

        if not isSquareMatrix(A)
          return solveQR(A, b)
        else if isSymmetricMatrix(A)
          return solveLDL(A, b)
        else
          return solveLU(A, b)

## solveLU(A,b)

Solves {{tex('A x = b')}} using LU decomposition.

Same input/output as `solve`.

      solveLU = (A, b) ->
        # Decompose `A` into `L * U`
        res = decomposeLU(A)
        return null unless res?
        {L, U} = res

        # Solve `L * y = b`.
        y = forwardSubstition(L, b)

        # Solve `U * x = y`.
        x = backwardSubtitution(U, y)

        return x

## solveLDL(A,b)

Solves {{tex('A x = b')}} using LDL decomposition. Note that {{tex('A')}} must be **symmetric**.

Same input/output as `solve`.

      solveLDL = (A, b) ->
        # Decompose `A` into `L * D * L'`
        res = decomposeLDL(A)
        return null unless res?
        {L, d} = res

        # Solve `L * y = b`.
        y = forwardSubstition(L, b)

        # Solve `L * z = y`.
        z = copy(y, (yi, i) -> yi / d[i])

        # Solve `U * x = y`.
        x = backwardSubtitution(L, z, transposed = true)

        return x


## solveQR(A,b)

Solves {{tex('A x = b')}} using QR decomposition. Note that {{tex('A')}} may
be any m-by-n matrix.

In the case that {{tex('A')}} is overdetermined, this method produces the
least-squares estimate of the solution, i.e. it minimizes
{{tex('\\parallel A x - b \\parallel')}}.

Same input/output as `solve`.

      solveQR = (A, b) ->
        {QR, d} = decomposeQRPartial(A)

        y = copy(b)
        m = QR.length
        n = QR[0].length

        # Only use m columns if underdetermined.
        cols = if m < n then m else n

        # Compute y = Q' * b for y
        for k in [0...cols] by 1
          sum = 0
          for i in [k...m] by 1
            sum += QR[i][k] * y[i]
          sum = -sum / QR[k][k]
          for i in [k...m] by 1
            y[i] += sum * QR[i][k]

        # Solve R * x = y for x
        x = copy(y)
        for k in [(cols-1)..0] by -1
          x[k] /= d[k]
          for i in [0...k]
            x[i] -= x[k] * QR[i][k]

        # Fill in zeros for the underdetermined case.
        if m < n
          for k in [cols...n] by 1
            x[k] = 0

        # Finally, truncate for the result to match the column count of A for
        # the overdetermined case.
        else if n < m
          x = x.slice(0, n)

        return x

## forwardSubstition(L, b)

Performs forward substitution with n-by-n lower triangular matrix {{tex('L')}} and
1-by-n vector {{tex('b')}} to solve {{tex('L x = b')}} .

      forwardSubstition = (L, b) ->
        n = L.length
        x = copy(b, -> 0)

        for i in [0...n]
          x[i] = b[i]
          for j in [0...i]
            x[i] -= x[j] * L[i][j]
          x[i] /= L[i][i]

        return x


## backwardSubtitution(U, b, [transposed = false])

Performs back substitution with n-by-n upper triangular matrix {{tex('U')}}
and 1-by-n vector {{tex('b')}} to solve {{tex('U x = b')}}. When used with LDL
decomposition, {{tex('U = L^\\intercal')}} is actually {{tex('L')}}, so we
transpose to coordinates on lookup.

      backwardSubtitution = (U, b, transposed = false) ->
        n = U.length
        x = copy(b, -> 0)

        for i in [(n-1)..0] by -1
          x[i] = b[i]
          for j in [(i + 1)...n] by 1
            x[i] -= x[j] * (if transposed then U[j][i] else U[i][j])
          x[i] /= U[i][i]

        return x


## Utility methods

We verify that the inputs to our `solve` and `decompose` methods are actually
n-by-n matrices. LDL further requires a symmetric matrix.

      isSquareMatrix = (A) ->
        return false unless Array.isArray(A)
        return false unless A.length > 0
        return false unless A[0].length is A.length
        return true

      isSymmetricMatrix = (A) ->
        n = A.length
        for i in [0...n]
          for j in [0...n]
            if j isnt i and A[i][j] isnt A[j][i] then return false
        return true

In order to support multiple matrix data types, we use this `copy` method to
construct new Arrays or TypedArrays. This method creates a new instance of `x`'s
type, and then copies its elements, which are optionally passed through a `map`
method.

      copy = (x, map) ->
        y = x.constructor.apply(null, [x.length])
        for i in [0...x.length] then do -> y[i] = map?(x[i], i) ? x[i]
        return y

Furthermore, for QR decomposition, we need to create arbitrary m-by-n matrices
using the internal Array or TypedArray type.

      reshape = (rows, cols, typedObject) ->
        return [0...rows].map ->
         y = typedObject.constructor.apply(null, [cols])
         for i in [0...cols] then y[i] = 0
         return y

In order to support multiple matrix layouts, we use this `fold` method to fold
an Array or TypedArray of length `n * width` into an Array of rows with
`width` elements each.

      fold = (array, width = 1) ->
        folder = array.slice ? array.subarray
        A = for n in [0...array.length] by width then do ->
          folder.apply(array, [n, n + width])
        return A

The `flatten` method will combine a row-major Array of arrays and flatten it
back into the type of the folded array.

      flatten = (matrix) ->
        n = matrix.length
        array = matrix[0].constructor.apply(null, [n*n])
        for i in [0...n]
          for j in [0...n]
            array[i * n + j] = matrix[i][j]
        return array

## Exports

This library uses universal module export syntax. This will work in node.js
(CommonJS), ADMs (RequireJS), and a `<script>` in the browser.

      namespace.luqr = {
        solve
        solveLU
        solveLDL
        solveQR
        decomposeLU
        decomposeLDL
        decomposeQR
        decomposeQRPartial
        forwardSubstition
        backwardSubtitution
        fold
        flatten
      }

    )(this)

© themadcreator@github