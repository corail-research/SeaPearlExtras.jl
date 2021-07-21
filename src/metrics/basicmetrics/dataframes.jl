"""
    function store_data(metrics::BasicMetrics{O, H}, title::String) where{O<:AbstractTakeObjective, H<:ValueSelection}

Store useful results from consecutive search in `.csv` file. 
"""
function storedata(metrics::AbstractMetrics; filename::String="")
    df = DataFrame(
        Episode = Int[],
        Instance = Missing[], 
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
            :Instance => missing,
            :Solution => 0,
            :Nodes => metrics.meanNodeVisitedUntilEnd[i],
            :Time => metrics.timeneeded[i],
            :Score => missing,
            :Reward => isnothing(metrics.totalReward) ? missing : metrics.totalReward[i],
            :Loss => isnothing(metrics.loss) ? missing : metrics.loss[i]
        )
        push!(df, episodeData)
        for j = 1:length(metrics.nodeVisited[i])
            solutionData = copy(episodeData)
            solutionData[:Solution] = j
            solutionData[:Nodes] = metrics.nodeVisited[i][j]
            solutionData[:Score] = isnothing(metrics.scores) | isnothing(metrics.scores[i][j]) ? missing : metrics.scores[i][j]
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
            :Nodes => metrics[j].meanNodeVisitedUntilEnd[i],
            :Time => metrics[j].timeneeded[i],
            :Score => missing,
            :Reward => isnothing(metrics[j].totalReward) ? missing : metrics[j].totalReward[i],
            :Loss => isnothing(metrics[j].loss) ? missing : metrics[j].loss[i]
        )
        push!(df, episodeData)
        for k = 1:length(metrics[j].nodeVisited[i])
            solutionData = copy(episodeData)
            solutionData[:Solution] = k
            solutionData[:Nodes] = metrics[j].nodeVisited[i][k]
            solutionData[:Score] = isnothing(metrics[j].scores) | isnothing(metrics[j].scores[i][k]) ? missing : metrics[j].scores[i][k]
            push!(df, solutionData)
        end
    end
    CSV.write(filename*".csv", df)
    return df
end
