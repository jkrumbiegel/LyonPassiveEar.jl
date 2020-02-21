function second_order_filter(f, q, fs)
    cft = f / fs
    rho = exp(-pi * cft / q)
    theta = 2pi * cft * sqrt(1 - 1.0 / (4 * q ^ 2))
    filts = [1, -2rho * cos(theta), rho ^ 2]
end

function freq_resp(filter, f, fs)
    cf = exp(1im * 2 * pi * f / fs)
    denom = filter[5] + filter[4] * cf + cf ^ 2
    mag = (filter[3] + filter[2] * cf + filter[1] * cf ^ 2) / denom
    mag = 20 * log10(abs(mag))
end

function set_gain(filter, desired, f, fs)
    old_gain = 10 ^ (freq_resp(filter, f, fs) / 20)
    filter[1:3] *= desired / old_gain
    filter
end

function design_lyon_filters(fs; ear_q = 8, step_factor = ear_q / 32)
    Eb = 1000.0
    EarZeroOffset = 1.5
    EarSharpness = 5.0
    EarPremphCorner = 300

    # Find top frequency, allowing space for first cascade filter.
    topf = fs / 2.0
    topf_neg_delta = sqrt(topf ^ 2 + Eb ^ 2) / ear_q * step_factor * EarZeroOffset
    topf = topf - topf_neg_delta + sqrt(topf ^ 2 + Eb ^ 2) / ear_q * step_factor

    # Find place where CascadePoleQ < .5
    lowf = Eb / sqrt(4 * ear_q ^ 2 - 1)
    _log_val_low = log(lowf + sqrt(lowf ^ 2 + Eb ^ 2))
    _log_val_top = log(topf + sqrt(Eb ^ 2 + topf ^ 2))
    NumberOfChannels = floor(Int, (ear_q * (-_log_val_low + _log_val_top)) / step_factor)

    # Now make an array of CenterFreqs..... This expression was derived by
    # Mathematica by integrating 1/EarBandwidth(cf) and solving for f as a
    # function of channel number.
    cn = 1:NumberOfChannels
    denom = exp.((cn .* step_factor) ./ ear_q)
    nom_add = topf + sqrt(Eb ^ 2 + topf ^ 2)
    center_freqs = (-1 .* ((exp.((cn .* step_factor) ./ ear_q) .* Eb ^ 2) ./ nom_add) .+ nom_add ./ denom) ./ 2.0

    # OK, now we can figure out the parameters of each stage filter.
    EarBandwidth = sqrt.(center_freqs .^ 2 .+ Eb ^ 2) ./ ear_q
    CascadeZeroCF = center_freqs .+ EarBandwidth .* step_factor .* EarZeroOffset
    CascadeZeroQ = EarSharpness .* CascadeZeroCF ./ EarBandwidth
    CascadePoleCF = center_freqs
    CascadePoleQ = center_freqs ./ EarBandwidth

    # Now lets find some filters.... first the zeros then the poles
    zerofilts = second_order_filter(CascadeZeroCF, CascadeZeroQ, fs)
    polefilts = second_order_filter(CascadePoleCF, CascadePoleQ, fs)
    # filters = np.vstack([zerofilts, polefilts[1:, :]])
    filters = cat(zerofilts, polefilts[:, 2:end])

    # Now we can set the DC gain of each stage.
    dcgain = zeros(NumberOfChannels)
    dcgain[1:end] = center_freqs[1:end-1] / center_freqs[2:end]
    dcgain[1] = dcgain[2]

    for i in 1:NumberOfChannels
        filters[i, :] = set_gain(filters[i, :], dcgain[i], 0, fs)
    end

    # Finally, let's design the front filters.
    front = zeros(2, 5)
    front_0 = [0, 1, -exp(-2 * pi * EarPremphCorner / fs), 0, 0]
    front[1, :] = set_gain(front_0, 1, fs / 4, fs)
    top_poles = second_order_filter(topf, CascadePoleQ[1], fs)
    front_1 = [1, 0, -1, top_poles[2], top_poles[3]]
    front[2, :] = set_gain(front_1, 1, fs / 4, fs)

    # Now, put them all together.
    filters = cat(front, filters)
    return filters, center_freqs
end
