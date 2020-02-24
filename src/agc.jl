const EPS = 1e-1

function agc_step(input, inputindexoffset, output, outputindexoffset,
        state, stateindexoffset, epsilon, target, n)

    StateLimit = 1 - EPS
    OneMinusEpsOverThree = (1.0 - epsilon) / 3.0
    EpsOverTarget = epsilon / target

    prevState = state[1 + stateindexoffset]

    f = 0.0

    @inbounds for i in 1:n-1
        oi = outputindexoffset + i
        ii = inputindexoffset + i
        si = stateindexoffset + i

        output[oi] = abs(input[ii] * (1.0 - state[si]))
        f = output[oi] * EpsOverTarget + OneMinusEpsOverThree *
            (prevState + state[si] + state[si + 1])

        f = f < StateLimit ? f : StateLimit
        prevState = state[si]
        state[si] = f
    end

    i = n
    oi = outputindexoffset + i
    ii = inputindexoffset + i
    si = stateindexoffset + i

    output[oi] = abs(input[ii] * (1.0 - state[si]))
    f = output[oi] * EpsOverTarget + OneMinusEpsOverThree *
        (prevState + state[si] + state[si])
    f = f < StateLimit ? f : StateLimit
    state[si] = f

    nothing
end


function agc(input, nChannels, nSamples, nStages, agcParams, state, output)

    @inbounds for j in 0:nSamples-1
        agc_step(input, j * nChannels, output, j * nChannels, state, 0, agcParams[2], agcParams[1], nChannels)

        for i in 1:nStages-1
            agc_step(output, j * nChannels, output, j * nChannels, state, i * nChannels, agcParams[2 + 2i], agcParams[1 + 2i], nChannels)
        end

    end

    nothing

end

function agc(input::AbstractMatrix, agcParams, state = nothing, output_prealloc = nothing)

    nChannels, nSamples = size(input)
    nStages = size(agcParams)[2]

    if isnothing(state)
        state = zeros(nChannels, nStages)
    end

    output = if isnothing(output_prealloc)
        zeros(nChannels, nSamples)
    else
        if size(output_prealloc) != size(input)
            error("Invalid output preallocation size $(size(output_prealloc)), should be $(size(input)).")
        end
        output_prealloc
    end

    agc(input, nChannels, nSamples, nStages, agcParams, state, output)

    output, state

end
