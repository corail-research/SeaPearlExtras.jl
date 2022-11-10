"""
    function store_data(metrics::BasicMetrics{O, H}, title::String) where{O<:AbstractTakeObjective, H<:ValueSelection}

Store useful results from consecutive search in `.csv` file. 
For each episode :  
    store n+1 lines where n is the number of Solution + Infeasible case reached during the search.
    The first line corresponds to general statistics for the search.
    The following line correspond to specific statistics fo each solution found / infeasible state reached.
"""
function storedata(metrics::AbstractMetrics; filename::String="")
    df = DataFrame(
        Episode = Int[],
        Instance = Missing[], 
        Solution = Int[],
        SolutionFound = Union{Missing, Int}[],
        Nodes = Int[], 
        Time = Float64[], 
        Score = Union{Missing, Float64}[], 
        Reward = Union{Missing, Float64}[], 
        Loss = Union{Missing, Float64}[]
    )
    for i = 1:metrics.nbEpisodes
        episodeData = Dict(
            :Episode => i,
            :Instance => missing,
            :Solution => 0,
            :SolutionFound => missing,
            :Nodes => metrics.meanNodeVisitedUntilEnd[i],
            :Time => metrics.TotalTimeNeeded[i],
            :Score => missing,
            :Reward => isnothing(metrics.totalReward) || isnothing(metrics.totalReward[i]) ? missing : metrics.totalReward[i],
            :Loss => isnothing(metrics.loss) || isnothing(metrics.loss[i]) ? missing : metrics.loss[i]
        )
        push!(df, episodeData)
        for j = 1:length(metrics.nodeVisited[i])
            solutionData = copy(episodeData)
            solutionData[:Solution] = j
            solutionData[:SolutionFound] = metrics.solutionFound[i][j]
            solutionData[:Nodes] = metrics.nodeVisited[i][j]
            solutionData[:Time] = metrics.timeNeeded[i][j]
            solutionData[:Score] = isnothing(metrics.scores) || isnothing(metrics.scores[i]) || isnothing(metrics.scores[i][j]) ? missing : metrics.scores[i][j]
            push!(df, solutionData)
        end
    end
    CSV.write(filename*".csv", df)
    return df
end

function storedata(metrics::Vector{<:AbstractMetrics}; filename::String="")
    df = DataFrame(
        Episode = Int[],
        Instance = Int[], 
        Solution = Int[],
        SolutionFound =Union{Missing, Int}[], 
        Nodes = Int[], 
        Time = Float64[], 
        Score = Union{Missing, Float64}[], 
        Reward = Union{Missing, Float64}[], 
        Loss = Union{Missing, Float64}[]
    )
    nbInstances = length(metrics)
    for j in 1:nbInstances, i = 1:metrics[j].nbEpisodes 
        episodeData = Dict(
            :Episode => i,
            :Instance => j,
            :Solution => 0,
            :SolutionFound => missing,
            :Nodes => metrics[j].meanNodeVisitedUntilEnd[i],
            :Time => metrics[j].TotalTimeNeeded[i],
            :Score => missing,
            :Reward => isnothing(metrics[j].totalReward) || isnothing(metrics[j].totalReward[i]) ? missing : metrics[j].totalReward[i],
            :Loss => isnothing(metrics[j].loss) || isnothing(metrics[j].loss[i]) ? missing : metrics[j].loss[i]
        )
        push!(df, episodeData)
        for k = 1:length(metrics[j].nodeVisited[i])
            solutionData = copy(episodeData)
            solutionData[:Solution] = k
            solutionData[:SolutionFound] = metrics[j].solutionFound[i][k]
            solutionData[:Nodes] = metrics[j].nodeVisited[i][k]
            solutionData[:Time] = metrics[j].timeNeeded[i][k]
            solutionData[:Score] = isnothing(metrics[j].scores) || isnothing(metrics[j].scores[i]) || isnothing(metrics[j].scores[i][k]) ? missing : metrics[j].scores[i][k]
            push!(df, solutionData)
        end
    end
    CSV.write(filename*".csv", df)
    return df
end
