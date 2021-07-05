using SeaPearl: DefaultStateRepresentation, VariableVertex, ValueVertex

function plottripartite(sr::DefaultStateRepresentation)
    cpmodel = sr.cplayergraph
    n = cpmodel.totalLength
    nodefillc = []
    for id in 1:n
        v = cpmodel.idToNode[id]
        if isa(v, VariableVertex) push!(nodefillc,"red")
        elseif isa(v, ValueVertex) push!(nodefillc,"blue")
        else  push!(nodefillc,"black") end
    end
    gplot(cpmodel;nodefillc=nodefillc)
end

export plottripartite
