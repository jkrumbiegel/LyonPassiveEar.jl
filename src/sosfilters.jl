function sosfilters(input::AbstractMatrix, coeffs::AbstractMatrix, state)

    nFilterChannels = size(coeffs, 1)
    nInputChannels, nSamples = size(input)
    nOutputChannels = max(nFilterChannels, nInputChannels)

    # if !(nFilterChannels == nInputChannels == nOutputChannels)
    #     error("Channel numbers don't match: $nFilterChannels filter, $nInputChannels input and $nOutputChannels output channels.")
    # end

    output = similar(input, (nOutputChannels, nSamples))

    if nInputChannels == 1
        error("1 input channel not implemented.")
    elseif nFilterChannels == 1
        a0 = coeffs[1, 1]
        a1 = coeffs[1, 2]
        a2 = coeffs[1, 3]
        b1 = coeffs[1, 4]
        b2 = coeffs[1, 5]

        for n in 1:nSamples
            for i in 1:nOutputChannels
                inp = input[i, n]
                output[i, n] = a0 * inp + state[i, 1]
                state[i, 1] = a1 * inp - b1 * output[i, n] + state[i, 2]
                state[i, 2] = a2 * inp - b2 * output[i, n]
            end
        end
    else
        for n in 1:nSamples
            for i in 1:nOutputChannels

                a0 = coeffs[i, 1]
                a1 = coeffs[i, 2]
                a2 = coeffs[i, 3]
                b1 = coeffs[i, 4]
                b2 = coeffs[i, 5]

                inp = input[i, n]
                output[i, n] = a0 * inp + state[i, 1]
                state[i, 1] = a1 * inp - b1 * output[i, n] + state[i, 2]
                state[i, 2] = a2 * inp - b2 * output[i, n]
            end
        end
    end

    output, state
end
