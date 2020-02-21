function sosfilters(input::AbstractMatrix, coeffs::AbstractMatrix, state)

    nFilterChannels = size(coeffs, 1)
    nSamples, nInputChannels = size(input)
    nOutputChannels = max(nFilterChannels, nInputChannels)

    @assert nFilterChannels == nInputChannels == nOutputChannels

    output = similar(input, (nSamples, nOutputChannels))

    for n in 1:nSamples
        for i in 1:nOutputChannels

            a0 = coeffs[i, 1]
            a1 = coeffs[i, 2]
            a2 = coeffs[i, 3]
            b1 = coeffs[i, 4]
            b2 = coeffs[i, 5]

            inp = input[n, i]
            output[n, i] = a0 * inp + state[1, i]
            state[1, i] = a1 * inp - b1 * output[n, i] + state[2, i]
            state[2, i] = a2 * inp - b2 * output[n, i]
        end
    end

    output
end
