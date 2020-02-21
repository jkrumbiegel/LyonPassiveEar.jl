function soscascade(signal::AbstractVector, coeffs, state)

    nSamples = size(signal, 1)
    nChannels = size(coeffs, 1)

    output = similar(signal, nSamples, nChannels)

    for n in 1:nSamples

        inp = signal[n]

        for i in 1:nChannels

            a0 = coeffs[i, 1]
            a1 = coeffs[i, 2]
            a2 = coeffs[i, 3]
            b1 = coeffs[i, 4]
            b2 = coeffs[i, 5]

            output[n, i] = a0 * inp + state[1, i]

            state[1, i] = a1 * inp - b1 * output[n, i] + state[2, i]
            state[2, i] = a2 * inp - b2 * output[n, i]

            inp = output[n, i]
        end

    end

    output

end
