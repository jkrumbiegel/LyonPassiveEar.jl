using LibSndFile
using FileIO
using LyonPassiveEar
using ClearStacktrace
using Makie, MakieLayout
using PyCall



aeiou = load("aeiou.wav")

mono = Float64.(aeiou[:, 1].data)

coch = lyon_passive_ear(mono, sample_rate = 44100, decimation_factor = 64)

@profiler lyon_passive_ear(mono, sample_rate = 44100, decimation_factor = 64)



##
scene, layout = layoutscene()

ax1 = layout[1, 1] = LAxis(scene)
ax2 = layout[2, 1] = LAxis(scene)

tightlimits!(ax2)

lines!(ax1, mono)
heatmap!(ax2, coch')


scene
