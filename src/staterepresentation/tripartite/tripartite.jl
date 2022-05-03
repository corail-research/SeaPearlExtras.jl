using SeaPearl: DefaultStateRepresentation, VariableVertex, ValueVertex, adjacency_matrix
using Graphs
using Cairo, Compose

function plottripartite(sr::DefaultStateRepresentation)
    cpmodel = sr.cplayergraph
    am = Matrix(adjacency_matrix(cpmodel))
    n = cpmodel.totalLength
    nodefillc = []
    label = []
    for id in 1:n
        v = cpmodel.idToNode[id]
        if isa(v, VariableVertex) 
            push!(nodefillc,"red")
            push!(label,v.variable.id)
        elseif isa(v, ValueVertex)
            push!(nodefillc,"blue")
            push!(label,v.value)
        else  
            push!(nodefillc,"black") 
            push!(label,typeof(v.constraint))
        end
        
    end
    draw(PDF("test.pdf", 16cm, 16cm), gplot(Graphs.Graph(am); nodefillc=nodefillc, nodelabel=label))
    error("Your plot is ready")
end

export plottripartite, plottripartite2