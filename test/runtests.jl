using Test
using BoxSymmetries
using BoxSymmetries: BoxSymmetry
@testset "1d" begin
    @inferred BoxSymmetry((1,), (true,))([1,2,3])
    @test BoxSymmetry((1,), (true,))([1,2,3]) == [3,2,1]
    @test BoxSymmetry((1,), (false,))([1,2,3]) == [1,2,3]
end

@testset "2d" begin
    m = [1 2 3;
         4 5 6
    ]
    @test BoxSymmetry((1,2), (false, false))(m) == [1 2 3; 4 5 6]
    @test BoxSymmetry((1,2), (false,  true))(m) == [3 2 1; 6 5 4]
    @test BoxSymmetry((1,2), ( true, false))(m) == [4 5 6; 1 2 3]
    @test BoxSymmetry((1,2), ( true,  true))(m) == [6 5 4; 3 2 1]
    
    @test BoxSymmetry((2,1), (false, false))(m) == [1 4; 2 5; 3 6]
    @test BoxSymmetry((2,1), (false,  true))(m) == [3 6; 2 5; 1 4]
    @test BoxSymmetry((2,1), ( true, false))(m) == [4 1; 5 2; 6 3]
    @test BoxSymmetry((2,1), ( true,  true))(m) == [6 3; 5 2; 4 1]
end

@testset "sugar" begin
    @test sym(1,)  === BoxSymmetry((1,),(false,))
    @test sym(-1,) === BoxSymmetry((1,),(true,))
    @test_throws ArgumentError sym(2,)
    @test_throws ArgumentError sym(0,)
    @test_throws ArgumentError sym(-1,1)
    @test sym(1,2) == BoxSymmetry((1,2), (false,false))
end

@testset "symmetries" begin
    symmetries = BoxSymmetries.symmetries
    @test allunique(symmetries(1))
    @test length(symmetries(1)) == 2
    @test allunique(symmetries(2))
    @test length(symmetries(2)) == 8
    @test allunique(symmetries(3))
    @test length(symmetries(3)) == 48
end

@testset "show it like you build it" begin
    for dim in 1:3
        for g in BoxSymmetries.symmetries(dim)
            s = sprint(show, g)
            g2 = eval(Meta.parse(s))
            @test g === g2
        end
    end
end
