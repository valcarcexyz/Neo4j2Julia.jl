using HTTP

"""
Checks if the Neo4j database is accesible
"""
function check_accessibility(URI::String, port::String)
    r = HTTP.request("GET", "http://$(URI):$(port)")
    @assert r.status == 200 "Couldn't connect to the database"
end

"""
Returns the response to the query as a list of jolts
"""
function get_data(usr::String, passw::String, URI::String, port::String, query::String)
    transaction = HTTP.request(
        "POST",
        "http://$(usr):$(passw)@$(URI):$(port)/db/neo4j/tx",
        ["Content-Type" => "application/json", "Accept" => "application/vnd.neo4j.jolt"],
        "{\"statements\" : [ {
                \"statement\" : \"$(query)\"
            }
        ]}"
    )
    return split(String(transaction.body), "\n")
end