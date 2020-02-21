using LyonPassiveEar
using Test

@testset "LyonPassiveEar.jl" begin
    EPS = 0.01

    input = [-0.50, -0.50, -0.70, -1.10, -1.70]

    coeffs = reshape(0:9, 2, 5) ./ 100

    state = zeros(2, 2)

    output = soscascade(input, coeffs, state)

    exp_state = [-0.07 -0.06; -0.00 -0.00]'
    @test all(abs.(state .- exp_state) .< EPS)

    exp_output = [0.00 -0.01 -0.03 -0.03 -0.05;
                  0.00 -0.00 -0.00 -0.00 -0.00]'

    @test all(abs.(output .- exp_output) .< EPS)
end


@testset "sosfilters" begin
    EPS = 0.01

    coeffs = reshape(0:9, 2, 5) ./ 100
    state = zeros(2, 2)
    agcOut = reshape(0:9, 2, 5)' .* 0.1

    output = sosfilters(agcOut, coeffs, state)

    exp_state = [0.04 0.03; 0.06 0.04]'
    @test all(abs.(state .- exp_state) .< EPS)

    exp_output = [0.00 0.00 0.00 0.02 0.03;
                  0.00 0.01 0.02 0.04 0.05]'
    @test all(abs.(output .- exp_output) .< EPS)
end
