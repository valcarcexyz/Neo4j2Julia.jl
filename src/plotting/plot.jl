using GraphPlot
using MetaGraphs
using Plots
using Compose
using Colors
using LightGraphs
using Cairo
using Fontconfig

"""
Splits the graph given symbol. 
Return a list with the group each vertex is in. Example: you split 
the graph by the :type property, so if it has 3 types ["a", "b", "c"]
it will return a list of being inside them like: [1, 1, 2, 3, 1, 2...]
"""
function divide(g::MetaDiGraph, s::Symbol, filterDivide::Bool=false)
    class = []
    for i ∈ 1:nv(g)
        p = props(g, i)
        if s in collect(keys(p))
            append!(class, [string(p[s])])
        else 
            append!(class, ["other"])
        end
    end
    if filterDivide
        uniques = unique(class)
        for (origen, desti) in zip(uniques, 1:length(uniques))
            class = replace(class, origen => desti)
        end
    end
    return class
end

function divide_edges(g::MetaDiGraph, s::Symbol, filterDivide::Bool=false)
    class = []
    for ed in edges(g)
        p = props(g, Edge(ed.src, ed.dst))
        if s in collect(keys(p))
            append!(class, [string(p[s])])
        else 
            append!(class, ["other"])
        end
    end
    if filterDivide
        uniques = unique(class)
        for (origen, desti) in zip(uniques, 1:length(uniques))
            class = replace(class, origen => desti)
        end
    end
    return class
end

""""""
function create_colors(g::MetaDiGraph, s::Symbol, pallete::AbstractVector)
    auxClass = divide(g, s, true)
    colors = distinguishable_colors(length(unique(auxClass)), pallete)
    return colors[auxClass]
end

function create_colors_edges(g::MetaDiGraph, s::Symbol, pallete::AbstractVector)
    auxClass = divide_edges(g, s, true)
    colors = distinguishable_colors(length(unique(auxClass)), pallete)
    return colors[auxClass]
end


"""
    plot(...)
A plot method for plotting Neo4j graphs

# Arguments
- `g::MetaDiGraph` : 
- `layout` : random_layout, circular_layout, spectral_layout, shell_layout 
"""
function plot(
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
    
    # Paleta de colores 
    pallete::AbstractVector=distinguishable_colors(1),
    
    # Layout configuration
    layout=random_layout,

    #save config
    filename = nothing,
    )

    # Apply the configs
    if nodeLabel isa Symbol
        nodeLabel = divide(g, nodeLabel)

        # only color if label selected (for eficency)
        if nodeLabelColor isa Symbol
            nodeLabelColor = create_colors(g, nodeLabelColor, pallete)
        end
    end

    if nodeColor isa Symbol
        nodeColor = create_colors(g, nodeColor, pallete)
    end

    if nodeSize isa Symbol 
        nodeSize = divide(g, nodeSize)
    end

    if edgeLabel isa Symbol
        edgeLabel = divide_edges(g, edgeLabel)

        if edgeLabelColor isa Symbol 
            edgeLabelColor = create_colors_edges(g, edgeLabelColor, pallete)
        end
    end

    if edgeColor isa Symbol 
        edgeColor = create_colors_edges(g, edgeColor, pallete)
    end
    
    
    p = gplot(
        g; 
        nodelabel = nodeLabel,
        nodelabelc = nodeLabelColor,
        nodefillc = nodeColor,
        nodesize = nodeSize,
        nodelabeldist = nodeLabelOffsetDist,
        nodelabelangleoffset = nodeLabelOffsetAngle,
        nodelabelsize = nodeSize * 4,

        edgelabel = [],
        edgelabelc = edgeLabelColor,
        edgelabelsize = nodeSize * 4,
        edgelinewidth = edgeWidth,
        edgestrokec = edgeColor,

        layout = layout,
    )

    display(p)
    
    if filename !== nothing 
        extension = filename[end-2:end]
        draw(eval(Meta.parse("$(uppercase(extension))(\"$(filename)\", 16cm, 16cm)")), p)
    end
end
