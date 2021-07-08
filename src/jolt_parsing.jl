using MetaGraphs
using LightGraphs
using JSON

"""
Creates a node in the graph, given its properties.

# Arguments 
- `id` :  stands for the key name of the index of the graph
"""
function createNode!(g::MetaDiGraph, properties::Dict=Dict(), 
    id=nothing)
    # First, we add the vertex to the graph
    if add_vertex!(g) & !isempty(properties)
        # The added index vertex must be the last one, i.e. 
        # the number of vertices in the graph
        vertexIdx = nv(g)

        # Add the key if exists
        if (id ∈ keys(properties))
            set_prop!(g, vertexIdx, id, string(properties[id]))
            delete!(properties, id)
        end
        # all the other properties
        set_props!(g, vertexIdx, properties)
    end
end


"""
Updates a Node properties accessing via:
+ idxNode 
+ idKey + idValue
"""
function updateNode!(g::MetaDiGraph, newProperties;
    idxNode=nothing, idKey=nothing, idValue=nothing, idProperty::Symbol=:id)
    if (idKey !== nothing) & (idValue !== nothing)
        idxNode = g[idValue, idKey]
    end
    if idxNode !== nothing
        currentProperties = props(g, idxNode)
        newProperties = merge(newProperties,
            currentProperties)
        delete!(newProperties, idProperty)
        set_props!(g, idxNode, newProperties)
    end
end



"""
Creates a edge given a graph g and the nodes u and v, 
both expressed by one of the following ways:
+ idxNode 
+ idKey + idValue
"""
function createEdge!(g::MetaDiGraph; properties::Dict = Dict(),
    idxNodeU=nothing, idKeyU=nothing, idValueU=nothing,
    idxNodeV=nothing, idKeyV=nothing, idValueV=nothing,
    undirected::Bool=false)
    # get the indices on the graph
    if (idKeyU !== nothing) & (idValueU !== nothing)
        idxNodeU = g[idValueU, idKeyU]
    end 
    if (idKeyV !== nothing) & (idValueV !== nothing)
        idxNodeV = g[idValueV, idKeyV]
    end 
    # check if they exist, and if they don't, create them # TO-DO
    if (idxNodeU !== nothing) & (idxNodeV !== nothing)
        add_edge!(g, idxNodeU, idxNodeV)
        set_props!(g, idxNodeU, idxNodeV, properties)
    end

    if undirected
        createEdge!(g; properties = properties, 
            idxNodeU = idxNodeV, idKeyU = idKeyV, idValueU = idValueV,
            idxNodeV = idxNodeU, idKeyV = idKeyU, idValueV = idValueU)
    end
end


function jolt_parse(g::MetaDiGraph, splitted::Vector)
    for line in splitted
        try
            parsed = JSON.parse(line)
            if "data" in keys(parsed) # other will be headers and commits
                response = parsed["data"]
                # the response will be a bunch of entities 
                for entityDict in response
                    # each entity can be "()", "->" or "<-"
                    entityType = collect(keys(entityDict))[1]
                    entity = entityDict[entityType]

                    if entityType == "()"
                        # {
                        #   "()": 
                        #       [ node_id, [ node_labels], 
                        #       {"prop1": "value1", "prop2": "value2"}]
                        # }
                        
                        # exists?
                        try 
                            idxNode = g[string(entity[1]), :id]
                            properties = Dict([(Symbol(x), y) for (x, y) ∈ entity[3]])
                            updateNode!(g, properties; idxNode = idxNode)
                        catch err
                            # does not exist yet 
                            delete!(entity[3], "id") # just to make sure there won't be problems
                            properties = merge(Dict(:type => string(entity[2][1])),
                                entity[3], Dict(:id => string(entity[1])))
                            properties = Dict([(Symbol(x), y) for (x, y) ∈ properties])
                            createNode!(g, properties, :id)
                        end

                        
                    elseif entityType == "->"
                        #  {"->": 
                            # [ 
                                    # rel_id, start_node_id, 
                                    # rel_type, end_node_id, 
                                    # {properties}
                            # ]}           
                        delete!(entity[5], "id") # just to make sure there won't be problems

                        idx1 = g[string(entity[2]), :id]
                        idx2 = g[string(entity[4]), :id]

                        if isa(idx1, Integer) & isa(idx1, Integer)
                            add_edge!(g, idx1, idx2)
                            delete!(auxEntity[5], "id")
                            set_props!(g, Edge(idx1, idx2), Dict(
                                :type => string(auxEntity[3]),
                                :id => string(auxEntity[1]),
                                [Symbol(k) =>  v for (k, v) in auxEntity[5]]...
                            ))
                        end

                    elseif entityType == "<-"
                        #  {"->": 
                            # [ 
                                    # rel_id, end_node_id, 
                                    # rel_type, start_node_id, 
                                    # {properties}
                            # ]}        
                        delete!(entity[5], "id") # just to make sure there won't be problems   

                        idx2 = g[string(entity[2]), :id]
                        idx1 = g[string(entity[4]), :id]

                        if isa(idx1, Integer) & isa(idx1, Integer)
                            add_edge!(g, idx1, idx2)
                            delete!(auxEntity[5], "id")
                            set_props!(g, Edge(idx1, idx2), Dict(
                                :type => string(auxEntity[3]),
                                :id => string(auxEntity[1]),
                                [Symbol(k) =>  v for (k, v) in auxEntity[5]]...
                            ))
                        end
                    end
                end
            end
        catch err
        end
    end
    return g
end