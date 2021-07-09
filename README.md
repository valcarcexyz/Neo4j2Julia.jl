# Neo4j2Julia


> A Julia package for transalting Neo4j graphs to [MetaGraph.jl](https://github.com/JuliaGraphs/MetaGraphs.jl)

# Installation 
```julia
pkg> add "https://github.com/valcarce01/Neo4j2Julia.jl"
```

# Usage
There are two methods implemented in this package: `create_graph` and `plot`. The first one is the one that translates the Neo4j Graph to the MetaGraph and the second one is a simple function to plot it using configuration not available in the Neo4j Bloom.

## create_graph

```julia

```

## plot
The `plot` method includes the following arguments:

+ `g`: the MetaGraph object to be plotted.
+ `nodeLabel`: the symbol (`:name`) that stores the information about the node label.
+ `nodeLabelColor`: the symbol that you want to color the labels from
+ `nodeLabelOffsetDist`: how far the labels should be from the node
+ `nodeLabelOffsetAngle`: angle the labels should be in the node
+ `nodeSize`: the symbol that stores the size of them
+ `nodeColor`: the symbol that should be used to apply color to the plot 
+ `edgeLabel`: the symbol that stores the edge labels 
+ `edgeLabelColor`: the symbol that you want to color the edge labels from
+ `edgeColor`: the symbol that should be used to apply color to the edges plot
+ `edgeWidth` : the width of the edges
+ `layout`: the layout that should be applied when placing the nodes. Options:
    + random_layout
    + circular_layout
    + spectral_layout
    + shell_layout
+ `filename`: the exporting path (include extension). Supported extensions: `.svg`, `.png` and `.pdf`. The file would be exported as a 16cm x 16cm

```julia
plot(
    g::MetaDiGraph;
    # Node configuration:
    nodeLabel::Union{Nothing, Symbol} = nothing,
        nodeLabelColor::Union{RGB, Symbol} = colorant"black",
        nodeLabelOffsetDist::Real = 0,
        nodeLabelOffsetAngle::Real = π / 4.0,
    nodeSize::Union{Real, Symbol} = 1,
    nodeColor::Union{RGB, Symbol} = colorant"turquoise",
    
    # Edge configuration:
    edgeLabel::Union{Vector, Symbol} = [],
        edgeLabelColor::Union{RGB, Symbol} = colorant"black",
    edgeColor::Union{RGB, Symbol} = colorant"lightgray",
    edgeWidth::Real = 1,
    
    # Color pallete 
    pallete::AbstractVector=distinguishable_colors(1),
    
    # Layout configuration
    layout=random_layout,

    #save config
    filename = nothing,
    )
```