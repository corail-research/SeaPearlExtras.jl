"""
    function store_data(metrics::BasicMetrics{O, H}, title::String) where{O<:AbstractTakeObjective, H<:ValueSelection}

Store useful results from consecutive search in `.csv` file. 
"""
function storedata(metrics::BasicMetrics; filename::String="")
    df = DataFrame(
        Episode = Int[], 
        Solution = Int[], 
        Nodes = Int[], 
        Time = Float64[], 
        Score = Union{Missing, Float64}[], 
        Reward = Union{Missing, Float64}[], 
        Loss = Union{Missing, Float64}[]
    )
    for i = 1:metrics.nbEpisodes
        episodeData = Dict(
            :Episode => i,
            :Solution => 0,
            :Nodes => metrics.meanNodeVisitedUntilOptimality[i],
            :Time => metrics.timeneeded[i],
            :Score => isnothing(metrics.scores) ? missing : metrics.scores[i],
            :Reward => isnothing(metrics.totalReward) ? missing : metrics.totalReward[i],
            :Loss => isnothing(metrics.loss) ? missing : metrics.loss[i]
        )
        push!(df, episodeData)
        for j = 1:length(metrics.nodeVisited[i])
            solutionData = copy(episodeData)
            solutionData[:Solution] = j
            solutionData[:Nodes] = metrics.nodeVisited[i][j]
            push!(df, solutionData)
        end
    end
    CSV.write(filename*".csv", df)
    return df
end
