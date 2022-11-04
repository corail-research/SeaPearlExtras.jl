import os
import re
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.ticker as ticker

def key(name, heuristics):
    if any(heuristic.endswith(name) for heuristic in heuristics):
        return name
    else:
        return "zzz" + name


def apply_key(series, training):
    """
    We add "zzz" at the beginning of the name of each heuristic 
    that is not learned to put them at the end in the sort.

    The objective is to keep the order of the heuristics between 
    the plots related to the dataframe `training` and those related to the dataframe `eval`.
    """
    if training is None:
        return series
    heuristics = set(training["Heuristic"])
    return series.apply(lambda x: key(x, heuristics))


def get_eval(path):
    files = os.listdir(path)
    # We keep only csv files
    files = [file for file in files if re.search(".*\.csv$", file) is not None]
    # We read the csv into a pandas.Dataframe
    dfs = [pd.read_csv(path + file) for file in files]
    # We get the names of the heuristics and the search strategies
    regexes = [re.search("([a-zA-Z0-9()]*)_([a-zA-Z0-9()]*)\.csv", file) for file in files]
    names = [regex.group(2) for regex in regexes]
    strategies = [regex.group(1) for regex in regexes]
    for i in range(len(names)):
        dfs[i]["Heuristic"] = names[i]
        dfs[i]["Strategy"] = strategies[i]
    # We concat every eval dataframe into one
    eval = pd.concat(dfs, axis=0, ignore_index=True)
    return eval


def get_training(path):
    files = os.listdir(path)
    # We keep only csv file
    files = [file for file in files if re.search(".*\.csv$", file) is not None]
    # We keep only training file
    files = [file for file in files if re.search(".*training.*", file) is not None]
    # We read the csv into a pandas.Dataframe
    dfs = [pd.read_csv(path + file) for file in files]
    # We get the names of the heuristics.
    names = [re.search("(training[_A-Za-z0-9.()]*)\.csv$", file).group(1) for file in files]
    for i in range(len(names)):
        dfs[i]["Heuristic"] = names[i]

    # We concat every eval dataframe into one
    training = pd.concat(dfs, axis=0, ignore_index=True)
    return training


def save_fig(plot, save_path, name):
    """
    Save the plot at the location specified by `save_path` if `save_path` is not `None`.
    """
    if save_path is not None:
        fig = plot.get_figure()
        fig.savefig(save_path + name + ".png")


def node_total(eval, estimator=np.mean, ax=None, save_path=None, training=None):
    eval["Episode"] = eval["Episode"]/max(eval["Episode"])*max(training["Episode"])

    plot = sns.lineplot(
        data=eval[eval["Solution"] == 0].sort_values("Heuristic", key=lambda series: apply_key(series, training)),
        #data=eval.loc[eval["Episode"] <= 75][eval["Solution"] == 0].sort_values("Heuristic", key=lambda series: apply_key(series, training)),
        y="Nodes",
        x="Episode",
        hue="Heuristic",
        estimator=estimator,
        ax=ax,
    )
    ax.set_title("Node visited until optimality", fontsize=22, fontweight="medium")
    plot.legend(fontsize='x-large', title_fontsize='40')
    ax.set_xlabel("Training episode", fontsize=18) 
    ax.set_ylabel("Node Visited", fontsize=18) 
    plot.set_yticklabels(plot.get_yticks(), size = "x-large")
    plot.set_xticklabels(plot.get_xticks(), size = "x-large")
    ax.xaxis.set_major_formatter(ticker.FuncFormatter(lambda x, pos:'{:,.0f}'.format(x)))
    ax.yaxis.set_major_formatter(ticker.FuncFormatter(lambda x, pos:'{:,.0f}'.format(x)))
    save_fig(plot, save_path, "eval_node_visited_optimality")


def area_under_curve(eval, estimator=np.mean, ax=None, save_path=None, training=None):
    min_score_accross_files = eval["Score"].min()
    eval["Area"] = ""
    for i in range(len(eval)):
        if eval.loc[i, "Solution"] == 0:
            eval.loc[i, "Area"] = 0
            prev_nodes = 0
        elif eval.loc[i, "SolutionFound"] == 0:
            eval.loc[i, "Area"] = 0
        else:
            eval.loc[i, "Area"] = (eval.loc[i, "Score"] - min_score_accross_files)*(eval.loc[i, "Nodes"]-prev_nodes)
            prev_nodes = eval.loc[i, "Nodes"]
    data = eval[["Episode","Instance","Area","Heuristic"]].groupby(["Episode","Instance","Heuristic"])["Area"].sum().reset_index()

    plot = sns.lineplot(
        data=data.sort_values("Heuristic", key=lambda series: apply_key(series, training)),
        y="Area",
        x="Episode",
        hue="Heuristic",
        estimator=estimator,
        ax=ax,
    )
    plot.set(yscale="log")
    plot.set(xlabel="Evaluation step", ylabel="Area under the curve", title="Area under the curve")
    save_fig(plot, save_path, "area_under_curve")


def node_first(eval, estimator=np.mean, ax=None, save_path=None, training=None):
    first_solution = eval.loc[
        eval[eval["SolutionFound"] == 1].groupby(["Episode", "Instance", "Heuristic"])["Solution"].idxmin()
    ].sort_values("Heuristic", key=lambda series: apply_key(series, training))
    #first_solution = first_solution.loc[first_solution["Episode"] <= 75]
    plot = sns.lineplot(data=first_solution, y="Nodes", x="Episode", hue="Heuristic", estimator=estimator, ax=ax)
    plot.set(xlabel="Evaluation step", ylabel="Nodes visited", title="Node visited until first solution")
    save_fig(plot, save_path, "eval_node_visited_first_solution")


def node_best(eval, estimator=np.mean, ax=None, save_path=None, training=None):
    eval["Episode"] = (eval["Episode"]-1)/max(eval["Episode"])*max(training["Episode"])
    first_solution = eval.loc[
        eval[eval["SolutionFound"] == 1].groupby(["Episode", "Instance", "Heuristic"])["Score"].idxmin()
    ].sort_values("Heuristic", key=lambda series: apply_key(series, training))
    #first_solution = first_solution.loc[first_solution["Episode"] <= 75]
    plot = sns.lineplot(data=first_solution, y="Nodes", x="Episode", hue="Heuristic", estimator=estimator, ax=ax)
    ax.set_title("Node visited until best solution", fontsize=22, fontweight="medium")
    plot.legend(fontsize='x-large', title_fontsize='40')
    ax.set_xlabel("Training episode", fontsize=18) 
    ax.set_ylabel("Nodes visited", fontsize=18) 
    plot.set_yticklabels(plot.get_yticks(), size = "x-large")
    plot.set_xticklabels(plot.get_xticks(), size = "x-large")
    ax.xaxis.set_major_formatter(ticker.FuncFormatter(lambda x, pos:'{:,.0f}'.format(x)))
    ax.yaxis.set_major_formatter(ticker.FuncFormatter(lambda x, pos:'{:,.0f}'.format(x)))
    save_fig(plot, save_path, "eval_node_visited_best_solution")


def score_first(eval, estimator=np.mean, ax=None, save_path=None, training=None):
    eval["Episode"] = (eval["Episode"]-1)/max(eval["Episode"])*max(training["Episode"])
    first_solution = eval.loc[
        eval[eval["SolutionFound"] == 1].groupby(["Episode", "Instance", "Heuristic"])["Solution"].idxmin()].sort_values("Heuristic", key=lambda series: apply_key(series, training))
    last_solution = eval.loc[
        eval[eval["SolutionFound"] == 1].groupby(["Episode", "Instance", "Heuristic"])["Solution"].idxmax()].sort_values("Heuristic", key=lambda series: apply_key(series, training))
    #first_solution = first_solution.loc[first_solution["Episode"] <= 75]
    #last_solution = last_solution.loc[last_solution["Episode"] <= 75]
    data_opti = last_solution.groupby(["Instance","Episode"])["Score"].min()
    data_opti = data_opti.to_frame().reset_index()
    data_opti= data_opti.assign(Heuristic = "Optimal Score")
    first_solution = pd.concat([first_solution,data_opti]).reset_index()
    plot = sns.lineplot(data=first_solution, y="Score", x="Episode", hue="Heuristic", estimator=estimator, ax=ax)
    ax.set_title("Score at first solution", fontsize=22, fontweight="medium")
    plot.legend(fontsize='x-large', title_fontsize='40')
    ax.set_xlabel("Training episode", fontsize=18) 
    ax.set_ylabel("Score obtained", fontsize=18) 
    plot.set_yticklabels(plot.get_yticks(), size = "x-large")
    plot.set_xticklabels(plot.get_xticks(), size = "x-large")
    ax.xaxis.set_major_formatter(ticker.FuncFormatter(lambda x, pos:'{:,.0f}'.format(x)))
    ax.yaxis.set_major_formatter(ticker.FuncFormatter(lambda x, pos:'{:,.0f}'.format(x)))
    save_fig(plot, save_path, "eval_score_first_solution")

def score_best(eval, estimator=np.mean, ax=None, save_path=None, training=None):
    eval["Episode"] = (eval["Episode"]-1)/max(eval["Episode"])*max(training["Episode"])
    first_solution = eval.loc[
        eval[eval["SolutionFound"] == 1].groupby(["Episode", "Instance", "Heuristic"])["Score"].idxmin()].sort_values("Heuristic", key=lambda series: apply_key(series, training))
    #first_solution = first_solution.loc[first_solution["Episode"] <= 75]
    plot = sns.lineplot(data=first_solution, y="Score", x="Episode", hue="Heuristic", estimator=estimator, ax=ax)
    ax.set_title("Score at best solution", fontsize=22, fontweight="medium")
    plot.legend(fontsize='x-large', title_fontsize='40')
    ax.set_xlabel("Training episode", fontsize=18) 
    ax.set_ylabel("Score obtained", fontsize=18) 
    plot.set_yticklabels(plot.get_yticks(), size = "x-large")
    plot.set_xticklabels(plot.get_xticks(), size = "x-large")
    ax.xaxis.set_major_formatter(ticker.FuncFormatter(lambda x, pos:'{:,.0f}'.format(x)))
    ax.yaxis.set_major_formatter(ticker.FuncFormatter(lambda x, pos:'{:,.0f}'.format(x)))
    save_fig(plot, save_path, "eval_score_best_solution")


def time_total(eval, estimator=np.mean, ax=None, save_path=None, training=None):
    plot = sns.lineplot(
        data=eval[eval["Solution"] == 0].sort_values("Heuristic", key=lambda series: apply_key(series, training)),
        y="Time",
        x="Episode",
        hue="Heuristic",
        estimator=estimator,
        ax=ax,
    )
    plot.set(xlabel="Evaluation step", ylabel="Time needed", title="Time needed to prove optimatility")
    save_fig(plot, save_path, "eval_time_optimality")


def node_rollmean(training, window=100, ax=None, save_path=None):
    df = (
        training[training["Solution"] == 0]
        .set_index("Episode")
        .sort_index()
        .groupby("Heuristic")
        .rolling(window, 1)["Nodes"]
        .mean()
        .reset_index()
    )
    plot = sns.lineplot(data=df, y="Nodes", x="Episode", hue="Heuristic", ax=ax)
    plot.set(
        xlabel="Training episode",
        ylabel="Nodes visited",
        title="Sliding average over the last {} episodes of the number of nodes visited \n during an episode.".format(
            window
        ),
    )
    save_fig(plot, save_path, "train_node_visited")


def reward_rollmean(training, window=100, ax=None, save_path=None):
    df = (
        training[training["Solution"] == 0]
        .set_index("Episode")
        .sort_index()
        .groupby("Heuristic")
        .rolling(window, 1)["Reward"]
        .mean()
        .reset_index()
    )
    plot = sns.lineplot(data=df, y="Reward", x="Episode", hue="Heuristic", ax=ax)
    plot.set(
        xlabel="Training episode",
        ylabel="Reward obtained",
        title="Sliding average over the last {} episodes of the reward obtained.".format(window),
    )
    save_fig(plot, save_path, "train_reward")


def loss_rollmean(training, window=100, ax=None, save_path=None):
    df = (
        training[training["Solution"] == 0]
        .set_index("Episode")
        .sort_index()
        .groupby("Heuristic")
        .rolling(window, 1)["Loss"]
        .mean()
        .reset_index()
    )
    plot = sns.lineplot(data=df, y="Loss", x="Episode", hue="Heuristic", ax=ax)
    plot.set(yscale="log")
    plot.set(
        xlabel="Training episode",
        ylabel="Loss",
        title="Sliding average over the last {} episodes of the loss.".format(window),
    )
    save_fig(plot, save_path, "train_loss")


def performance_plot_nodes_optimality(performance, ax=None, save_path=None):
    df = performance[performance["Solution"] == 0][["Instance", "Nodes", "Heuristic","Strategy"]]
    df["Heuristic"] =df['Heuristic'] +"-"+ df["Strategy"]
    df = df.drop(['Strategy'],axis=1)
    best = df[["Instance", "Nodes"]].groupby("Instance").min("Nodes").to_dict()["Nodes"]
    df["Ratio"] = df.apply(lambda x: x["Nodes"] / best[x["Instance"]], axis=1)
    df = df.sort_values("Ratio")
    count = {heuristic: 0 for heuristic in set(df["Heuristic"])}
    max_instance = df["Instance"].max()
    def process(heuristic):
        count[heuristic] += 1
        return count[heuristic] / max_instance
    df["Proportion"] = df["Heuristic"].apply(process)
    for heuristic in set(df["Heuristic"]):
        df.loc[len(df)] = [-1, -1, heuristic, 1, 0]
        df.loc[len(df)] = [-1, -1, heuristic, df["Ratio"].max(), 1]
    df = df.sort_values("Ratio")
    plot = sns.lineplot(data=df, y="Proportion", x="Ratio", hue="Heuristic", drawstyle='steps-post', ax=ax, ci=None)
    plot.set(
        xlabel="Within this factor of the best number of nodes",
        ylabel="Proportion of the {} instances".format(max_instance),
        title="Performance profile for number of nodes until optimality.",
    )
    save_fig(plot, save_path, "performance_nodes_optimality")


def performance_plot_time_optimality(performance, ax=None, save_path=None):
    df = performance[performance["Solution"] == 0][["Instance", "Time", "Heuristic","Strategy"]]
    df["Heuristic"] =df['Heuristic'] +"-"+ df["Strategy"]
    df = df.drop(['Strategy'],axis=1)  
    best = df[["Instance", "Time"]].groupby("Instance").min("Time").to_dict()["Time"]
    df["Ratio"] = df.apply(lambda x: x["Time"] / best[x["Instance"]], axis=1)
    df = df.sort_values("Ratio")
    count = {heuristic: 0 for heuristic in set(df["Heuristic"])}
    max_instance = df["Instance"].max()
    def process(heuristic):
        count[heuristic] += 1
        return count[heuristic] / max_instance
    df["Proportion"] = df["Heuristic"].apply(process)
    for heuristic in set(df["Heuristic"]):
        df.loc[len(df)] = [-1, -1, heuristic, 1, 0]
        df.loc[len(df)] = [-1, -1, heuristic, df["Ratio"].max(), 1]
    df = df.sort_values("Ratio")   
    plot = sns.lineplot(data=df, y="Proportion", x="Ratio", hue="Heuristic", drawstyle='steps-post', ax=ax, ci=None)
    plot.set(
        xlabel="Within this factor of the best time",
        ylabel="Proportion of the {} instances".format(max_instance),
        title="Performance profile for time until optimality.",
    )
    save_fig(plot, save_path, "performance_time_optimality")

def performance_plot_score_first(performance, ax=None, save_path=None):
    df = performance.loc[
        performance[performance["SolutionFound"] == 1].groupby(["Episode", "Instance", "Heuristic","Strategy"])["Solution"].idxmin()
    ][["Instance", "Score", "Heuristic"]]
    df["Heuristic"] = df['Heuristic'] +"-"+ df["Strategy"]
    df = df.drop(['Strategy'],axis=1)
    best = df[["Instance", "Score"]].groupby("Instance").min("Score").to_dict()["Score"]
    df["Ratio"] = df.apply(lambda x: x["Score"] / best[x["Instance"]] if best[x["Instance"]] > 0 
                                else best[x["Instance"]] / x["Score"] if x["Score"] != 0 
                                else 1 if best[x["Instance"]] == 0 else None, axis=1) # TODO: Better Handle Division by Zero
    df = df.sort_values("Ratio")
    count = {heuristic: 0 for heuristic in set(df["Heuristic"])}
    max_instance = df["Instance"].max()
    def process(heuristic):
        count[heuristic] += 1
        return count[heuristic] / max_instance
    df["Proportion"] = df["Heuristic"].apply(process)
    for heuristic in set(df["Heuristic"]):
        df.loc[len(df)] = [-1, -1, heuristic, 1, 0]
        df.loc[len(df)] = [-1, -1, heuristic, df["Ratio"].max(), 1]
    df = df.sort_values("Ratio")
    plot = sns.lineplot(data=df, y="Proportion", x="Ratio", hue="Heuristic", drawstyle='steps-post', ax=ax, ci=None)
    plot.set(
        xlabel="Within this factor of the best first score",
        ylabel="Proportion of the {} instances".format(max_instance),
        title="Performance profile for first score.",
    )
    save_fig(plot, save_path, "performance_score_first")


def performance_plot_score_best(performance, ax=None, save_path=None):
    df = performance.loc[
    performance[(performance["SolutionFound"] == 1)].groupby(["Episode", "Instance", "Heuristic","Strategy"])["Score"].idxmin()][["Instance", "Score", "Heuristic","Strategy"]]

    def split_val(input):
        if "random" in input :
            return re.findall(r'\d+',input)[0]
        else :
            return 0

    def remove_id(input):
        if "random" in input :
            return input.replace(re.findall(r'\d+',input)[0], '')
        else :
            return input

    df["id"] = df["Heuristic"].apply(split_val)
    df["Heuristic"] = df["Heuristic"].apply(remove_id)

    df["Score_max"] = df.groupby(["Strategy","Heuristic","Instance"])["Score"].transform(max)
    df["Score_min"] = df.groupby(["Strategy","Heuristic","Instance"])["Score"].transform(min)
    df["Score_mean"] = df.groupby(["Strategy","Heuristic","Instance"])["Score"].transform('mean')

    best = df[["Instance", "Score"]].groupby("Instance").min("Score").to_dict()["Score"]

    df["Ratio_mean"] = df.apply(lambda x: x["Score_mean"] / best[x["Instance"]] if best[x["Instance"]] > 0 else best[x["Instance"]] / x["Score_mean"], axis=1)
    df["Ratio_min"] = df.apply(lambda x: x["Score_min"] / best[x["Instance"]] if best[x["Instance"]] > 0 else best[x["Instance"]] / x["Score_min"], axis=1)
    df["Ratio_max"] = df.apply(lambda x: x["Score_max"] / best[x["Instance"]] if best[x["Instance"]] > 0 else best[x["Instance"]] / x["Score_max"], axis=1)

    max_instance = df["Instance"].max()
    def process(x):
        count[(x.Heuristic,x.Strategy)] += 1
        if x.Heuristic =="random":
            return count[(x.Heuristic,x.Strategy)] / (max_instance*10)
        else :
            return count[(x.Heuristic,x.Strategy)] / (max_instance)
        
        
    df = df.sort_values("Ratio_mean")
    count = {(heuristic,strategy) : 0 for heuristic,strategy in set(zip(df["Heuristic"],df["Strategy"]))}
    df["Proportion_mean"] = df.apply(process, axis =1)

    df = df.sort_values("Ratio_min")
    count = {(heuristic,strategy) : 0 for heuristic,strategy in set(zip(df["Heuristic"],df["Strategy"]))}
    df["Proportion_min"] = df.apply(process, axis =1)

    df = df.sort_values("Ratio_max")
    count = {(heuristic,strategy) : 0 for heuristic,strategy in set(zip(df["Heuristic"],df["Strategy"]))}
    df["Proportion_max"] = df.apply(process, axis =1)

        #df = df.loc[df['Heuristic'].isin(["3layer-DFS","random-DFSearch1000", "3layer-ILDSearch1000", "random-ILDS0", "3layer-ILDS0", "3layer-ILDS1", "3layer-ILDS2"])]
    maxRa = max(df["Ratio_mean"].max(),df["Ratio_min"].max(),df["Ratio_max"].max())
    for heuristic,strategy in set(zip(df["Heuristic"],df["Strategy"])): #set the correct scale, we basically add two points
        df.loc[len(df)] = [-1, -1, heuristic,strategy,-1,-1,-1,-1, 1, 1, 1, 0, 0, 0]
        df.loc[len(df)] = [-1, -1, heuristic,strategy,-1,-1,-1,-1, maxRa,maxRa,maxRa,1,1, 1]

    df  = df.loc[(df["Heuristic"]=="random")&(df["Strategy"]=="ILDS0")]

        #df = df[df.Heuristic.str.contains('ILDS0',case=False)]

        #df = df.loc[df['Heuristic'].isin(["random-ILDS0"])]    
        #df = df.groupby(["Ratio","Heuristic"]).min().reset_index()
    _, ax = plt.subplots()
    idx = df.groupby(['Ratio_max'])['Proportion_max'].transform(max) == df['Proportion_max'] 
    plot = sns.lineplot(data=df[idx].sort_values(["Ratio_max","Proportion_max"]), x="Ratio_max",  y="Proportion_max", hue="Heuristic", drawstyle='steps-pre', ax=ax, errorbar=None)
    idx = df.groupby(['Ratio_mean'])['Proportion_mean'].transform(max) == df['Proportion_mean']
    plot = sns.lineplot(data=df[idx].sort_values(["Ratio_mean","Proportion_mean"]), x="Ratio_mean",  y="Proportion_mean", hue="Heuristic", drawstyle='steps-pre', ax=ax, errorbar=None)
    idx = df.groupby(['Ratio_min'])['Proportion_min'].transform(max) == df['Proportion_min']
    plot = sns.lineplot(data=df[idx].sort_values(["Ratio_min","Proportion_min"]), x="Ratio_min",  y="Proportion_min", hue="Heuristic", drawstyle='steps-pre', ax=ax, errorbar=None)
    idx = df.groupby(['Ratio_max'])['Proportion_max'].transform(max) == df['Proportion_max'] 

    #plot = sns.scatterplot(data=df[idx].sort_values(["Ratio_max","Proportion_max"]), x="Ratio_max",  y="Proportion_max", hue="Heuristic", ax=ax)
    #plot = sns.scatterplot(data=df[idx].sort_values(["Ratio_min","Proportion_min"]), x="Ratio_min",  y="Proportion_min", hue="Heuristic", ax=ax)


    #df1 = df[["Proportion_max","Ratio_max" ]].sort_values(["Proportion_max"])
    #df2 = df[["Proportion_min","Ratio_min" ]].sort_values(["Proportion_min"])
    #ax.fill_betweenx(list(df2["Proportion_min"]), list(df2["Ratio_min"]), list(df1["Ratio_max"]), alpha=0.2)
    plot.set(
        xlabel="Within this factor of the best score",
        ylabel="Proportion of the {} instances".format(max_instance),
        title="Performance profile for best score.",
    )
    save_fig(plot, save_path, "performance_score_best")
    return df


def summary(eval, training, estimator=np.mean, window=100, save_path=None, ilds=False):
    fig, axs = plt.subplots(nrows=2, ncols=4, figsize=(40, 16), facecolor="white")

    if not ilds:
        node_total(eval, estimator=estimator, ax=axs[0][0], training=training)
    else:
        pass

    #area_under_curve(eval, estimator=estimator, ax=axs[0][3], training=training)

    if not eval["Score"].isnull().values.all():
        if not ilds:
            node_best(eval, estimator=estimator, save_path=save_path, ax=axs[0][1], training=training)
        else:
            score_best(eval, estimator=estimator, save_path=save_path, ax=axs[0][1], training=training)
        score_first(eval, estimator=estimator, ax=axs[0][2], training=training)
    node_rollmean(training, window=window, ax=axs[1][0])
    reward_rollmean(training, window=window, ax=axs[1][1])
    loss_rollmean(training, window=window, ax=axs[1][2])
    fig.savefig(save_path + "summary.png")


def all(path, estimator=np.mean, window=100, save_path=None, ilds=False):
    """
    Saves all plots and displays them if run in a notebook.

    The files are saved in the same location as the data files, unless the `save_path` parameter is specified.
    """
    eval = get_eval(path)
    training = get_training(path)

    if save_path is None:
        save_path = path

    summary(eval, training, estimator=estimator, window=window, save_path=save_path, ilds=ilds)

    sns.set(rc={"figure.figsize": (11, 8)})
    sns.set_theme(style="whitegrid")

    _, ax = plt.subplots()

    node_total(eval, estimator=estimator, save_path=save_path, ax=ax, training=training)
    _, ax = plt.subplots()
    node_first(eval, estimator=estimator, save_path=save_path, ax=ax, training=training)
    if not eval["Score"].isnull().values.all():
        _, ax = plt.subplots()
        score_first(eval, estimator=estimator, save_path=save_path, ax=ax, training=training)
        _, ax = plt.subplots()
        score_best(eval, estimator=estimator, save_path=save_path, ax=ax, training=training)
        _, ax = plt.subplots()
        node_best(eval, estimator=estimator, save_path=save_path, ax=ax, training=training)

    _, ax = plt.subplots()
    node_rollmean(training, window=window, save_path=save_path)
    _, ax = plt.subplots()
    reward_rollmean(training, window=window, save_path=save_path)
    _, ax = plt.subplots()
    loss_rollmean(training, window=window, save_path=save_path)
    _, ax = plt.subplots()
    #area_under_curve(eval, estimator=estimator, save_path=save_path, ax=ax, training=training)

def performance(path, save_path=None, ilds=False):
    """
    Saves all plots and displays them if run in a notebook.

    The files are saved in the same location as the data files, unless the `save_path` parameter is specified.
    """
    print("/home/martom/SeaPearl/SeaPearlZoo/learning_cp/comparison/" + path + "benchmarks/")
    eval = get_eval("/home/martom/SeaPearl/SeaPearlZoo/learning_cp/comparison/" + path + "benchmarks/")
    if save_path is None:
        save_path = path

    sns.set(rc={"figure.figsize": (12, 8)})
    sns.set_theme(style="whitegrid")
    _, ax = plt.subplots()
    performance_plot_score_best(eval, save_path=save_path, ax=ax)
    '''
    _, ax = plt.subplots()
    performance_plot_score_first(eval, save_path=save_path, ax=ax)
    _, ax = plt.subplots()
    performance_plot_nodes_optimality(eval, save_path=save_path, ax=ax)
    _, ax = plt.subplots()
    performance_plot_time_optimality(eval, save_path=save_path, ax=ax)
    '''