# BoxSymmetries

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://jw3126.github.io/BoxSymmetries.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://jw3126.github.io/BoxSymmetries.jl/dev)
[![Build Status](https://github.com/jw3126/BoxSymmetries.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jw3126/BoxSymmetries.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/jw3126/BoxSymmetries.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/jw3126/BoxSymmetries.jl)

[BoxSymmetries.jl](https://github.com/jw3126/BoxSymmetries.jl) allows applying box symmetries to arrays in arbitrary dimensions.

# Usage
```julia
julia> using BoxSymmetries

julia> g = BoxSym(-1,2) # flip the first axis
BoxSym(-1, 2)

julia> g([1 2 3; 4 5 6])
2×3 Matrix{Int64}:
 4  5  6
 1  2  3

julia> g = BoxSym(2,1) # permute axes
BoxSym(2, 1)

julia> g([1 2 4; 4 5 6])
3×2 Matrix{Int64}:
 1  4
 2  5
 4  6

julia> g = BoxSym(-1,-2) # flip both axes
BoxSym(-1, -2)

julia> g([1 2; 3 4])
2×2 Matrix{Int64}:
 4  3
 2  1

julia> arr = randn(1,2,3,4);

julia> g = BoxSym(4,-2,1,-3) # permute axes and flip some of them
BoxSym(4, -2, 1, -3)

julia> size(g(arr))
(4, 2, 1, 3)
```
# Theory
We define the group of box symmetries of dimension N to be the group of all linear maps
ℝᴺ → ℝᴺ that restrict to bijections on the unit cube [-1,1]ᴺ → [-1,1]ᴺ.
One can check that such maps must map coordinate axes onto coordinate axes and preserve length.
So essentially they are allowed to permute axes and flip signs of axes, nothing else.
It follows that box symmetries are in bijection with the following data:
```julia
struct BoxSym{N}
    # BoxSym is the semidirect product Boolⁿ ⋊ Sₙ
    # here axesperm ∈ Sₙ controls the induced action on the set of coordinate axes
    # flipsign controls for each axis, whether the sign is flipped. E.g. whether
    # eᵢ ↦ eⱼ or eᵢ ↦ -eⱼ for the standard basis
    axesperm::Perm
    flipsign::NTuple{N,Bool}
end
```

To compactly denote this data, we use the following notation, that is best explained by example:
* `BoxSym( 2, 1)`: (x,y) ↦ ( y, x)
* `BoxSym(-1, 2)`: (x,y) ↦ (-x, y)
* `BoxSym( 1,-2)`: (x,y) ↦ ( x,-y)
* `BoxSym( 2, 1, -3)`: (x,y,z) ↦ ( y, x, -z)
* `BoxSym(-2, -3, 1)`: (x,y,z) ↦ ( z,-x, -y)

In other words `1,2,3` stand for the directed coordinate axes and `-1,-2,-3` stand for the coordinate axes directed in the opposite direction. `Box(a,b,c)` means that axis 1 maps to axis a,
axis 2 maps to axis b and axis 3 maps to axis c.

# Alternatives 
For the use case of 2d images, there are alternatives:
* [SquareSymmetries.jl](https://github.com/icetube23/SquareSymmetries.jl)
* [Augmentor.jl](https://github.com/Evizero/Augmentor.jl)
