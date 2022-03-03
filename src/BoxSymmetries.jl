module BoxSymmetries
export sym

using ArgCheck
struct BoxSymmetry{N}
    permutation::NTuple{N,Int}
    flipsign::NTuple{N,Bool}
end
Base.ndims(o::BoxSymmetry{N}) where {N} = N
Base.ndims(::Type{BoxSymmetry{N}}) where {N} = N

function outaxes(o::BoxSymmetry, axes::Tuple)
    @argcheck length(axes) == ndims(o)
    check(o)
    unsafe_permute(o.permutation, axes)
end

function unsafe_permute(perm::NTuple{N}, items::NTuple{N,Any}) where {N}
    map(perm) do i
        @inbounds items[i]
    end
end

function apply_symmetry!(out::AbstractArray{<:Any, N}, o::BoxSymmetry{N}, x) where {N}
    check(o)
    @argcheck axes(out) == outaxes(o, axes(x))
    flipped_axes = map(flipaxis, axes(x), o.flipsign)
    @inbounds for I in CartesianIndices(x)
        indsx = Tuple(I)
        indsf = map(getindex,flipped_axes, indsx)
        indsfp = unsafe_permute(o.permutation, indsf)
        Iout = CartesianIndex(indsfp)
        out[Iout] = x[I]
    end
    out
end
function apply_symmetry(o::BoxSymmetry, x)
    out = similar(x, outaxes(o,axes(x)))
    apply_symmetry!(out, o, x)
end

function (o::BoxSymmetry)(x)
    apply_symmetry(o,x)
end

function flipaxis(ax::AbstractRange, flip::Bool)
    if flip
        last(ax):-step(ax):first(ax)
    else
        first(ax):step(ax):last(ax)
    end
end

function check(o::BoxSymmetry)
    for key in 1:ndims(o)
        if !(key in o.permutation)
            msg = """
            Invalid permutation, key missing:
            key = $key
            symmetry = $o
            permutation = $(o.permutation)
            """
            throw(ArgumentError(msg))
        end
    end
end
"""

    sym(args::Integer...)

Create a box symmetry, according to args.
"""
function sym(args::Integer...)
    perm = map(abs, args)
    flip = map(<(0), args)
    ret = BoxSymmetry(perm, flip)
    check(ret)
    ret
end
function astuple(o::BoxSymmetry)
    (-1) .^ (o.flipsign) .* o.permutation
end

function Base.show(io::IO, o::BoxSymmetry)
    print(io, "sym", astuple(o))
end

################################################################################
#### symmetries
################################################################################

function symmetries(::Val{1})
    [sym(1), sym(-1)]
end
function symmetries(::Val{2})
    [
        sym(1,2), sym(1,-2), sym(-1,2), sym(-1,-2),
        sym(2,1), sym(2,-1), sym(-2,1), sym(-2,-1),
    ]
end
function symmetries(::Val{3})
    [
        sym(1,2,3), sym(1,2,-3), sym(1,-2,3), sym(1,-2,-3), sym(-1,2,3), sym(-1,2,-3), sym(-1,-2,3), sym(-1,-2,-3), 
        sym(1,3,2), sym(1,3,-2), sym(1,-3,2), sym(1,-3,-2), sym(-1,3,2), sym(-1,3,-2), sym(-1,-3,2), sym(-1,-3,-2), 
        sym(3,2,1), sym(3,2,-1), sym(3,-2,1), sym(3,-2,-1), sym(-3,2,1), sym(-3,2,-1), sym(-3,-2,1), sym(-3,-2,-1), 
        sym(2,1,3), sym(2,1,-3), sym(2,-1,3), sym(2,-1,-3), sym(-2,1,3), sym(-2,1,-3), sym(-2,-1,3), sym(-2,-1,-3), 
        sym(2,3,1), sym(2,3,-1), sym(2,-3,1), sym(2,-3,-1), sym(-2,3,1), sym(-2,3,-1), sym(-2,-3,1), sym(-2,-3,-1), 
        sym(3,1,2), sym(3,1,-2), sym(3,-1,2), sym(3,-1,-2), sym(-3,1,2), sym(-3,1,-2), sym(-3,-1,2), sym(-3,-1,-2), 
    ]
end

"""
    symmetries(dim::Integer)
    symmetries(dim::Val(::Integer))

Return an iterator over all box symmeties of a given dimension.
"""
function symmetries(n::Integer)
    symmetries(Val(n))
end

end

# TODO composition of symmetries
# TODO inversion of symmetries
# TODO lazy iterator of all symmetries of given dimension
# TODO isrotation for checking if orientation is preserved
