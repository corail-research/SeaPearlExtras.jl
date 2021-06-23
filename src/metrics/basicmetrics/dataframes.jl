"""
    function store_data(metrics::BasicMetrics{O, H}, title::String) where{O<:AbstractTakeObjective, H<:ValueSelection}

Store useful results from consecutive search in `.csv` file. 
"""
function store_data(metrics::BasicMetrics; filename::String="")
    df = DataFrame()
    for i in 1:metrics.nbEpisodes
        df[!, string(i)*"_node_visited"] = metrics.nodeVisited[i]
        df[!, string(i)*"_node_visited_until_first_solution_found"] = metrics.meanNodeVisitedUntilfirstSolFound[i]
        df[!, string(i)*"_node_visited_until_optimality"] = metrics.meanNodeVisitedUntilOptimality[i]
        df[!, string(i)*"_time_needed"] = metrics.timeneeded[i]
        if !isnothing(metrics.scores)           
            df[!, string(i)*"_score"] = metrics.scores[i]
        end
        if !isnothing(metrics.totalReward)   #if the heuristic is a learned heuristic
            df[!, string(i)*"_total_reward"] = metrics.totalReward[i]
            df[!, string(i)*"_loss"] = metrics.loss[i]
        end
    end
    CSV.write(title*".csv", df)
end
