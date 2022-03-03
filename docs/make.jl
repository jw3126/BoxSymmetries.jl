using BoxSymmetries
using Documenter

DocMeta.setdocmeta!(BoxSymmetries, :DocTestSetup, :(using BoxSymmetries); recursive=true)

makedocs(;
    modules=[BoxSymmetries],
    authors="Jan Weidner <jw3126@gmail.com> and contributors",
    repo="https://github.com/jw3126/BoxSymmetries.jl/blob/{commit}{path}#{line}",
    sitename="BoxSymmetries.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://jw3126.github.io/BoxSymmetries.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/jw3126/BoxSymmetries.jl",
    devbranch="main",
)
