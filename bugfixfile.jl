using LibSndFile
using FileIO
using LyonPassiveEar
using ClearStacktrace


vowel = load("vowel_a.wav")

mono = Float64.(vowel[:, 1]).data

coch = lyon_passive_ear(mono[1:100], sample_rate = 44100, decimation_factor = 64, differ = false)

lyon_passive_ear([1.0, 0, 0, 0, 0, 0], sample_rate = 400, decimation_factor = 1)
