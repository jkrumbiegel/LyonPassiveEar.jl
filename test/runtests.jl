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

@testset "design_lyon_filters" begin
    result = design_lyon_filters(4000.0)

    # from python version
    @test all(abs.(result[2] .- [1897.10751154, 1831.00638006, 1766.69348626, 1704.10601949, 1643.18285418,
        1583.86449022, 1526.0929948, 1469.81194586, 1414.96637697, 1361.50272363, 1309.368771,
        1258.51360287, 1208.88755196, 1160.44215137, 1113.1300873, 1066.90515279, 1021.72220264,
        977.53710928, 934.3067197, 891.98881327, 850.54206056, 809.92598293, 770.10091301,
        731.02795597, 692.66895152, 654.98643664, 617.943609, 581.50429104, 545.63289457,
        510.29438609, 475.45425253, 441.07846755, 407.13345831, 373.5860727, 340.40354693,
        307.55347355, 275.00376981, 242.72264629, 210.67857589, 178.84026303, 147.17661309,
        115.656702, 84.2497461]) .< 1e-6)
end

@testset "lyon_passive_ear" begin
    lyon_passive_ear([1.0, 0, 0, 0, 0, 0], sample_rate = 400, decimation_factor = 1)
end
