function lyon_passive_ear(signal::AbstractVector; sample_rate = 16000, decimation_factor::Int = 1,
        ear_q = 8, step_factor = ear_q / 32, differ = true, useagc = true, tau_factor = 3)

    ear_filters, _ = design_lyon_filters(sample_rate, ear_q, step_factor)
    n_samples = length(signal)

    n_output_samples = floor(Int, n_samples / decimation_factor)
    n_channels = size(ear_filters, 1) ## ???

    sos_output = zeros(n_channels, decimation_factor)
    sos_state = zeros(n_channels, 2)
    agc_state = zeros(n_channels, 4)
    y = zeros(n_channels, n_output_samples)

    dec_eps = epsilon_from_tau(decimation_factor / sample_rate * tau_factor, sample_rate)

    dec_state = zeros(n_channels, 2)

    _coeffs = [0.0, 0, 1, -2 * (1 - dec_eps), (1 - dec_eps) ^ 2]
    dec_filt = set_gain(_coeffs, 1, 0, sample_rate)

    epses = [epsilon_from_tau(x, sample_rate) for x in [.64, .16, .04, .01]]
    tars = [.0032, .0016, .0008, .0004]

    # move agc_params out of loop
    agc_params = hcat(tars, epses)'

    for i in 1:n_output_samples

        @views window = signal[(i - 1) * decimation_factor + 1 : i * decimation_factor]
        sos_output, sos_state = soscascade(window, ear_filters, sos_state)

        sos_output = sos_output' # BUG why transpose?
        output = clamp!(sos_output, 0, Inf) # Half Wave Rectify
        output[1, 1] = 0 # Test Hack to make inversion easier.
        output[2, 1] = 0

        if useagc
            output, agc_state = agc(output, agc_params, agc_state)
        end
        if differ
            # @views output = vcat(output[1:1, :], output[1:end-1, :] .- output[2:end, :])
            output[2:end, :] .= @view(output[1:end-1, :]) .- @view(output[2:end, :])
            clamp!(output, 0, Inf)
        end
        if decimation_factor > 1

            output, dec_state = sosfilters(
                output,
                reshape(dec_filt, 1, :), #[:, np.newaxis])
                dec_state)

        end

        y[:, i] = output[:, end]
    end

    y[3:end, :]
end
