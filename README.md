# Neo4j2Julia


> A Julia package for transalting Neo4j graphs to [MetaGraph.jl](https://github.com/JuliaGraphs/MetaGraphs.jl). Also adds an intuitive `plot` method via [GraphPlot.jl](https://github.com/JuliaGraphs/GraphPlot.jl) to plot graphs with more configuration that Neo4j Bloom allows to.

# Contents
1. [Installations](#installation)
2. [Usage](#usage)
    1. [create_graph](#creategraph)
    2. [plot](#plot)
3. [Usage example](#usage-example)
4. [Disclaimer](#disclaimer)

## Installation 
```julia
pkg> add "https://github.com/valcarce01/Neo4j2Julia.jl"
```

## Usage
There are two methods implemented in this package: `create_graph` and `plot`. The first one is the one that translates the Neo4j Graph to the MetaGraph and the second one is a simple function to plot it using configuration not available in the Neo4j Bloom.

### create_graph
The `create_graph` includes the following arguments:

+ `usr`: the user to be used to log-in the database
+ `passw`: the password of the given user
+ `URI`: to access the database (it is not really the URI, but the domain). Exmple: "http://localhost:7474" should be `URI=localhost` (default).
+ `port`: in which the database is accessible.
+ `query`: the query (cypher) to return the data you want to work with (defualt is all the database)

> ```julia
> create_graph(
>        usr::String = "neo4j", 
>        passw::String = "neo4j", 
>        URI::String = "localhost", 
>        port::String = "7474",
>        query::String = "MATCH (n) OPTIONAL MATCH (n)-[r]-() RETURN n, r;")
>```

### plot
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
+ `pallete`: a vector of RGB. This can be done via: `[colorant"green", ...]`
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

## Usage example
```julia
# firstly we create the graph
G = create_graph("neo4j", "neo4j", "localhost", "7474")
# and then we plot it
plot(G)

# if we want to colorize it by a given property of the Neo4j Database:
plot(G; nodeColor = :type)
```



## Disclaimer
This package has been built for a personal project and only tested in one database, so I am not sure this is generalizable.

Feel free to report any issue or add new functionalities/correct them through a pull request.