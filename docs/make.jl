using Documenter, LyonPassiveEar

makedocs(;
    modules=[LyonPassiveEar],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/jkrumbiegel/LyonPassiveEar.jl/blob/{commit}{path}#L{line}",
    sitename="LyonPassiveEar.jl",
    authors="Julius Krumbiegel <julius.krumbiegel@gmail.com>",
    assets=String[],
)

deploydocs(;
    repo="github.com/jkrumbiegel/LyonPassiveEar.jl",
)
