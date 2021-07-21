"""
function plotNodeVisited(metrics::BasicMetrics{O, H}; filename::String="") where{O<:AbstractTakeObjective, H<:ValueSelection}

plot 2 graphs : 
1) number of node visited by the heuristic to find a first solution for every learning episode. 
2) number of node visited by the heuristic to prove to optimality for every learning episode. 

The learning process should show a decrease in the number of nodes required to find a first solution along the search 
(depending on the reward engineering).
"""
function plotNodeVisited(metricsArray::Union{BasicMetrics, Vector{AbstractMetrics}}; filename::String="")
    L = length(metricsArray[1].meanNodeVisitedUntilEnd)
    Label = Matrix{String}(undef, 1, length(metricsArray))
    learnedIdx = 1
    basicIdx = 1
    for j in 1:length(metricsArray) #nb of heuristics
        if isa(metricsArray[j].heuristic, LearnedHeuristic)
            Label[1,j]="Learned heuristic n°$learnedIdx"
            learnedIdx += 1
        else
            Label[1,j]="Classic heuristic n°$basicIdx"
            basicIdx += 1
        end
    end 
    p1 = plot(
        1:L, 
        [metricsArray[i].meanNodeVisitedUntilEnd[1:L] for i in 1:length(metricsArray)], 
        title = "Node visited until optimality",
        label=Label,
        xlabel="Episode",
        ylabel="Nodes visited",
    )
    p2 = plot(
        1:L, 
        [metricsArray[i].meanNodeVisitedUntilfirstSolFound[1:L] for i in 1:length(metricsArray)], 
        title ="Node visited until first solution found",
        label=Label,
        xlabel="Episode", 
        ylabel="Nodes visited",
    )
    plot(p1,p2, layout=(2,1))
end


function plotNodeVisited(metrics::BasicMetrics; filename::String="")
    L = length(metrics.meanNodeVisitedUntilEnd)
    p = plot(
        1:L, 
        [metrics.meanNodeVisitedUntilEnd[1:L] metrics.meanNodeVisitedUntilfirstSolFound[1:L]], 
        xlabel="Episode", 
        ylabel="Nodes visited",
        title = ["Node visited until Optimality" "Node visited until first solution found"],
        layout = (2, 1)
    )
    display(p)
    savefig(p,filename*"_node_visited_"*"$(typeof(metrics.heuristic))"*".png")
end

"""
function plotScoreVariation(metrics::BasicMetrics{O, H}; filename::String="") where{O<:AbstractTakeObjective, H<:ValueSelection}

plot the relative scores ( compared to the optimal ) of the heuristic during the search for fixed instances along the training. This plot is 
meaningful only if the metrics is one from the evaluator (ie. the instance remains the same one).
"""
function plotScoreVariation(metrics::BasicMetrics{TakeObjective, H}; filename::String="") where H
    Data=[]
    for i in length(metrics.nodeVisited):-1:1
        push!(Data,hcat(metrics.nodeVisited[i],metrics.scores[i]))
    end

    p = plot(
        [scatter[:,1] for scatter in Data], 
        [scatter[:,2] for scatter in Data], 
        #fillrange =[[ones(length(scatter[:,2])),scatter[:,2]] for scatter in Data],
        #fillalpha=1,
        xlabel="number of nodes visited", 
        ylabel="relative score",
        xaxis=:log, 
    )
    display(p)
    savefig(p,filename*"_score_variation.png")
end


"""
function plotScoreVariation(metrics::BasicMetrics{O, H}; filename::String="") where{O<:AbstractTakeObjective, H<:ValueSelection}

plot the relative scores ( compared to the optimal ) of the heuristic during the search for fixed instances along the training. This plot is 
meaningful only if the metrics is one from the evaluator (ie. the instance remains the same one).
"""
function plotRewardVariation(metrics::BasicMetrics{<:AbstractTakeObjective, <:LearnedHeuristic}; filename::String="")
    L = length(metrics.totalReward)

    p = plot(1:L, 
        metrics.totalReward[1:L],
        xlabel="Episode", 
        ylabel="Total reward",
        title ="Total reward per episode",
    )
    display(p)
    savefig(p,filename*"_reward_variation.png")
end
