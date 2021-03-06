module BoxSymmetries
export BoxSym
export unit, inverse, ∘

using Random: AbstractRNG, Random
using ArgCheck
################################################################################
#### Perm
################################################################################
"""
Permutation
"""
struct Perm{N}
    perm::NTuple{N,Int}
    function Perm(perm::NTuple{N,Int}) where {N}
        @argcheck ispermutation(perm)
        return new{N}(perm)
    end
end
function Perm(args::Integer...)
    Perm(Int.(args))
end
function Base.show(io::IO, p::Perm)
    print(io, Perm, p.perm)
end
function ispermutation(perm::NTuple{N,Int}) where {N}
    ret = true
    for key in ntuple(identity, Val(N))
        ret = ret & (key in perm)
    end
    ret
end
ispermutation(perm::Perm) = true
function act_tuple(p::Perm{N}, t::NTuple{N}) where {N}
    map(p.perm) do i
        @inbounds t[i]
    end
end
function unit(::Type{Perm{N}}) where {N}
    Perm(ntuple(identity, Val(N)))
end
function Base.:(∘)(p1::Perm{N}, p2::Perm{N})::Perm{N} where {N}
    Perm(act_tuple(p1, p2.perm))
end
function inverse(p::Perm{N})::Perm{N} where {N}
    Perm(map(ntuple(identity, Val(N))) do i
        indexof(p.perm, i)
    end)
end
function indexof(t::NTuple, item)
    for i in eachindex(t)
        if t[i] === item
            return i
        end
    end
    error()
end
const PERM1 = [Perm(1)]
const PERM2 = [Perm(1,2), Perm(2,1)]
const PERM3 = [Perm(1,2,3), 
               Perm(1,3,2), Perm(3,2,1), Perm(2,1,3),
               Perm(2,3,1), Perm(3,1,2),
]
Base.instances(::Type{Perm{1}}) = PERM1
Base.instances(::Type{Perm{2}}) = PERM2
Base.instances(::Type{Perm{3}}) = PERM3


################################################################################
#### BoxSym
################################################################################
struct BoxSym{N}
    # BoxSym is the semidirect product Boolⁿ ⋊ Sₙ
    # here axesperm ∈ Sₙ controls the induced action on the set of coordinate axes
    # flipsign controls for each axis, whether the sign is flipped. E.g. whether
    # eᵢ ↦ eⱼ or eᵢ ↦ -eⱼ for the standard basis
    axesperm::Perm
    flipsign::NTuple{N,Bool}
end
Base.ndims(o::BoxSym{N}) where {N} = N
Base.ndims(::Type{BoxSym{N}}) where {N} = N

function outaxes(o::BoxSym, axes::Tuple)
    @argcheck length(axes) == ndims(o)
    act_tuple(o.axesperm, axes)
end

isunit(g) = (g === unit(typeof(g)))

act_array!(out, g::BoxSym, x) = act_array_generic!(out, g, x)
act_array(g::BoxSym, x) = act_array_generic(g, x)

function act_array_generic!(out::AbstractArray{<:Any, N}, o::BoxSym{N}, x) where {N}
    @argcheck axes(out) == outaxes(o, axes(x))
    flipped_axes = map(flipaxis, axes(out), o.flipsign)
    @inbounds for I in CartesianIndices(x)
        inds = Tuple(I)
        inds = act_tuple(o.axesperm, inds)
        inds = map(getindex,flipped_axes, inds)
        Iout = CartesianIndex(inds)
        out[Iout] = x[I]
    end
    out
end
function act_array_generic(o::BoxSym, x)
    out = similar(x, outaxes(o,axes(x)))
    act_array_generic!(out, o, x)
end

function (o::BoxSym)(x)
    act_array(o,x)
end

function flipaxis(ax::AbstractRange, flip::Bool)
    if flip
        last(ax):-step(ax):first(ax)
    else
        first(ax):step(ax):last(ax)
    end
end

"""

    BoxSym(args::Integer...)

Create a box symmetry, according to args.
"""
function BoxSym(args::Integer...)
    perm = Perm(map(Int∘abs, args))
    flip = map(<(0), args)
    ret = BoxSym(perm, flip)
    ret
end
function astuple(o::BoxSym)
    (-1) .^ (o.flipsign) .* o.axesperm.perm
end
function Base.show(io::IO, o::BoxSym)
    print(io, "BoxSym", astuple(o))
end

function unit(::Type{BoxSym{N}})::BoxSym{N} where {N}
    BoxSym(ntuple(identity, Val(N))...)
end
function inverse(g::BoxSym{N})::BoxSym{N} where {N}
    n = g.flipsign
    h = g.axesperm
    h⁻¹ = inverse(h)
    n⁻¹ = n
    BoxSym{N}(
        h⁻¹,
        act_tuple(h⁻¹, n⁻¹),
   )
end
function Base.:(∘)(g1::BoxSym{N}, g2::BoxSym{N})::BoxSym{N} where {N}
    # We have
    # BoxSym = Boolⁿ ⋊ Sₙ
    # and we use the semidirect product formular
    n1 = g1.flipsign
    n2 = g2.flipsign
    h1 = g1.axesperm
    h2 = g2.axesperm
    h = h1∘h2
    n = map(⊻, n1, act_tuple(h1, n2))
    BoxSym{N}(h,n)
end

################################################################################
#### ALIASES
################################################################################
const BOXSYM_FROM_ALIAS2D = Dict(
    :unit      => BoxSym( 1, 2),
    :rot90     => BoxSym(-2, 1),
    :rot180    => BoxSym(-1,-2),
    :rot270    => BoxSym( 2,-1),
    :flipx     => BoxSym(-1, 2),
    :flipy     => BoxSym( 1,-2),
    :flipdiag  => BoxSym( 2, 1),
    :flipadiag => BoxSym(-2,-1),
)

BoxSym{2}(alias::Symbol) = BOXSYM_FROM_ALIAS2D[alias]

# TODO 3d aliases

################################################################################
#### instances
################################################################################

const SYMMETRIES1D = [BoxSym(1), BoxSym(-1)]
const SYMMETRIES2D = [
    BoxSym(1,2), BoxSym(1,-2), BoxSym(-1,2), BoxSym(-1,-2),
    BoxSym(2,1), BoxSym(2,-1), BoxSym(-2,1), BoxSym(-2,-1),
]
const SYMMETRIES3D = [
    BoxSym(1,2,3), BoxSym(1,2,-3), BoxSym(1,-2,3), BoxSym(1,-2,-3), BoxSym(-1,2,3), BoxSym(-1,2,-3), BoxSym(-1,-2,3), BoxSym(-1,-2,-3), 
    BoxSym(1,3,2), BoxSym(1,3,-2), BoxSym(1,-3,2), BoxSym(1,-3,-2), BoxSym(-1,3,2), BoxSym(-1,3,-2), BoxSym(-1,-3,2), BoxSym(-1,-3,-2), 
    BoxSym(3,2,1), BoxSym(3,2,-1), BoxSym(3,-2,1), BoxSym(3,-2,-1), BoxSym(-3,2,1), BoxSym(-3,2,-1), BoxSym(-3,-2,1), BoxSym(-3,-2,-1), 
    BoxSym(2,1,3), BoxSym(2,1,-3), BoxSym(2,-1,3), BoxSym(2,-1,-3), BoxSym(-2,1,3), BoxSym(-2,1,-3), BoxSym(-2,-1,3), BoxSym(-2,-1,-3), 
    BoxSym(2,3,1), BoxSym(2,3,-1), BoxSym(2,-3,1), BoxSym(2,-3,-1), BoxSym(-2,3,1), BoxSym(-2,3,-1), BoxSym(-2,-3,1), BoxSym(-2,-3,-1), 
    BoxSym(3,1,2), BoxSym(3,1,-2), BoxSym(3,-1,2), BoxSym(3,-1,-2), BoxSym(-3,1,2), BoxSym(-3,1,-2), BoxSym(-3,-1,2), BoxSym(-3,-1,-2), 
]


Base.instances(::Type{BoxSym{1}}) = SYMMETRIES1D
Base.instances(::Type{BoxSym{2}}) = SYMMETRIES2D
Base.instances(::Type{BoxSym{3}}) = SYMMETRIES3D

Random.rand(rng::AbstractRNG, G::Type{<:BoxSym}) = rand(rng, instances(G))

################################################################################
#### Precompile
################################################################################
let
    BoxSym(1)(fill(1.0, 1))
    BoxSym(1,-2)(fill(1.0, 1,1))
    BoxSym(1,-2,3)(fill(1.0, 1,1,1))
end

# TODO lazy iterator of all symmetries of given dimension
# TODO isrotation for checking if orientation is preserved
end #module
