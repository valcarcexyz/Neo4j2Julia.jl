module Neo4j2Julia
    include("jolt/Neo4jconnection.jl")
    include("jolt/jolt_parsing.jl")
    include("plotting/plot.jl")

    using MetaGraphs
    using LightGraphs

    export create_graph
    export plot

    """
        create_graph(...)

    Creates a MetaGraph connecting given a Neo4j query and authentication

    # Arguments
    - `usr::String`: the username for the Neo4j database (defualt: neo4j)
    - `passw::String`: the password for the Neo4j database (defualt: neo4j)
    - `URI::String`: the URI for connecting the Neo4j database (defualt: localhost)
    - `port::String`: the port where the database is accesible (given URI) (defualt: 7474)
    - `query::String`: the query to create the graph from (defualt: all database)

    # Returns
    - `MetaGraph`: the graph

    # Throws
    - `IOError[...](ECONNREFUSED)[...]`: If there was no possible conection to the database
    """
    function create_graph(
        usr::String = "neo4j", 
        passw::String = "neo4j", 
        URI::String = "localhost", 
        port::String = "7474",
        query::String = "MATCH (n) OPTIONAL MATCH (n)-[r]-() RETURN n, r;")

    # Check whether the database is accesible or not
    check_accessibility(URI, port)

    # Now access the data the query asks for
    splitted_response = get_data(usr, passw, URI, port, query)

    g = MetaDiGraph()
    set_indexing_prop!(g, :id) # the "database" indexes by the id property

    jolt_parse(g, splitted_response)
    end
end
