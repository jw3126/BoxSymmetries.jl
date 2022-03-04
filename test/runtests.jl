using Test
using BoxSymmetries
using BoxSymmetries: Perm

@testset "1d" begin
    @inferred BoxSym(1)([1,2,3])
    @test BoxSym(-1)([1,2,3]) == [3,2,1]
    @test BoxSym( 1)([1,2,3]) == [1,2,3]

    @test inverse(BoxSym(1)) === BoxSym(1)
    @test inverse(BoxSym(-1)) === BoxSym(-1)
    @test BoxSym(1) ∘ BoxSym(-1) === BoxSym(-1)
    @test BoxSym(-1) ∘ BoxSym(1) === BoxSym(-1)
    @test BoxSym(1) ∘ BoxSym(1) === BoxSym(1)
    @test BoxSym(-1) ∘ BoxSym(-1) === BoxSym(1)
    @test unit(BoxSym{1}) === BoxSym(1)
end

@testset "2d" begin
    m = [1 2 3;
         4 5 6
    ]
    @test BoxSym( 1, 2)(m) == [1 2 3; 4 5 6]
    @test BoxSym( 1,-2)(m) == [3 2 1; 6 5 4]
    @test BoxSym(-1, 2)(m) == [4 5 6; 1 2 3]
    @test BoxSym(-1,-2)(m) == [6 5 4; 3 2 1]
    
    @test BoxSym( 2, 1)(m) == [1 4; 2 5; 3 6]
    @test BoxSym( 2,-1)(m) == [4 1; 5 2; 6 3]
    @test BoxSym(-2, 1)(m) == [3 6; 2 5; 1 4]
    @test BoxSym(-2,-1)(m) == [6 3; 5 2; 4 1]
end

@testset "action associative" begin
    for dim in 1:3
        for _ in 1:10
            dims = Tuple(rand(1:5) for _ in 1:dim)
            x = randn(dims)
            g1 = rand(BoxSym{dim})
            g2 = rand(BoxSym{dim})
            @test (g1∘g2)(x) == g1(g2(x))
        end
    end
end

@testset "sugar" begin
    @test_throws ArgumentError BoxSym(2,)
    @test_throws ArgumentError BoxSym(0,)
    @test_throws ArgumentError BoxSym(-1,1)
end

@testset "instances" begin
    G = instances(BoxSym{1})
    @test allunique(G)
    @test length(G) == 2
    @test rand(G) isa BoxSym{1}
    @test rand(BoxSym{1}) isa BoxSym{1}

    G = instances(BoxSym{2})
    @test allunique(G)
    @test length(G) == 8
    @test rand(G) isa BoxSym{2}
    @test rand(BoxSym{2}) isa BoxSym{2}

    G = instances(BoxSym{3})
    @test allunique(G)
    @test length(G) == 48
    @test rand(G) isa BoxSym{3}
    @test rand(BoxSym{3}) isa BoxSym{3}
end

@testset "show it like you build it" begin
    for dim in 1:3
        for G in [BoxSym{dim}, Perm{dim}]
            for g in instances(G)
                s = sprint(show, g)
                g2 = eval(Meta.parse(s))
                @test g === g2
            end
        end
    end
end

function test_group_laws(G)
    @testset "unit" begin
        @test unit(G) isa G
        for g in instances(G)
            @test unit(G) ∘ g === g
            @test g ∘ unit(G) === g
        end
    end
    @testset "inverse" begin
        for g in instances(G)
            @test inverse(g) isa G
            @test (g∘inverse(g)) === unit(G)
            @test (inverse(g)∘g) === unit(G)
        end
    end
    @testset "associative" begin
        for g1 in instances(G)
            for g2 in instances(G)
                for g3 in instances(G)
                    @test g1∘(g2∘g3) === (g1∘g2)∘g3
                end
            end
        end
    end
end

@testset "group laws" begin
    test_group_laws(Perm{1})
    test_group_laws(Perm{2})
    test_group_laws(Perm{3})

    test_group_laws(BoxSym{1})
    test_group_laws(BoxSym{2})
    test_group_laws(BoxSym{3})
end
