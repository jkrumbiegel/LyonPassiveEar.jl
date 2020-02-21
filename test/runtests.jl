using LyonPassiveEar
using Test

@testset "soscascade" begin
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


@testset "agc" begin

    EPS = 0.01
    nSamples = 5
    nChannels = 2
    nStages = 3

    output = (0:nChannels*nSamples-1) .* 0.1
    agcParams = fill(0.5, 2 * nStages)
    agcState = zeros(nChannels * nStages)
    agcOut = zeros(nChannels * nSamples)

    agc(output, nChannels, nSamples, nStages, agcParams, agcState, agcOut)

    exp_agcState = vec([0.64 0.41 0.30;
                        0.66 0.42 0.30])
    @test all(abs.(agcState .- exp_agcState) .< EPS)

    exp_agcOut = vec([0.00 0.20 0.19 0.15 0.15;
                      0.10 0.22 0.19 0.15 0.15])

    @test all(abs.(agcOut .- exp_agcOut) .< EPS)

end
