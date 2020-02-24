using LibSndFile
using FileIO
using LyonPassiveEar
using ClearStacktrace
using Makie, MakieLayout
using PyCall



aeiou = load("aeiou.wav")

mono = Float64.(aeiou[:, 1].data)

coch = lyon_passive_ear(mono, sample_rate = 44100, decimation_factor = 64);

using BenchmarkTools
@btime lyon_passive_ear($mono[1:1000], sample_rate = 44100, decimation_factor = 64);

@profiler lyon_passive_ear(mono[1:1000], sample_rate = 44100, decimation_factor = 64)



##
scene, layout = layoutscene()

ax1 = layout[1, 1] = LAxis(scene)
ax2 = layout[2, 1] = LAxis(scene)

linkxaxes!(ax1, ax2)

tightlimits!(ax1, Left(), Right())
tightlimits!(ax2)

xs = (1:length(mono)) ./ 44100
lines!(ax1, xs, mono)
hm = heatmap!(ax2, xs, 1:size(coch, 1), coch')

layout[2, 2] = LColorbar(scene, hm, width = 30)

foreach(Union{LAxis, LColorbar}, layout) do x
    tight_ticklabel_spacing!(x)
end

scene
