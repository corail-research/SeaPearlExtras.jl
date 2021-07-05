"""
    function store_data(metrics::BasicMetrics{O, H}, title::String) where{O<:AbstractTakeObjective, H<:ValueSelection}

Store useful results from consecutive search in `.csv` file. 
"""
function storedata(metrics::BasicMetrics; filename::String="")
    df = DataFrame()
    df[!, "node_visited"] = metrics.nodeVisited
    df[!, "node_visited_until_first_solution_found"] = metrics.meanNodeVisitedUntilfirstSolFound
    df[!, "node_visited_until_optimality"] = metrics.meanNodeVisitedUntilOptimality
    df[!, "time_needed"] = metrics.timeneeded
    if !isnothing(metrics.scores)           
        df[!, "score"] = metrics.scores
    end
    if !isnothing(metrics.totalReward)   #if the heuristic is a learned heuristic
        df[!, "total_reward"] = metrics.totalReward
        df[!, "loss"] = metrics.loss
    end
    CSV.write(filename*".csv", df)
end
