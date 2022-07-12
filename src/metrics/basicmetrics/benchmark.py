import os
import re

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns


def get_eval(path):
    files = os.listdir(path)
    # We keep only csv files
    files = [file for file in files if re.search(".*\.csv$", file) is not None]
    # We read the csv into a pandas.Dataframe
    dfs = [pd.read_csv(path + file) for file in files]
    # We get the names of the heuristics and the search strategies
    regexes = [re.search("([a-zA-Z0-9()]*)_([a-zA-Z0-9()]*)\.csv", file) for file in files]
    names = [regex.group(1) for regex in regexes]
    strategies = [regex.group(2) for regex in regexes]
    print(names)
    for i in range(len(names)):
        dfs[i]["Heuristic"] = names[i]
        dfs[i]["Strategy"] = strategies[i]

    # We concat every eval dataframe into one
    eval = pd.concat(dfs, axis=0, ignore_index=True)
    return eval

def node_total(eval, estimator=np.mean, ax=None, save_path=None, training=None):
    plot = sns.lineplot(
        data=eval[eval["Solution"] == 0].sort_values("Heuristic", key=lambda series: apply_key(series, training)),
        y="Nodes",
        x="Episode",
        hue="Heuristic",
        estimator=estimator,
        ax=ax,
    )
    plot.set(xlabel="Evaluation step", ylabel="Nodes visited", title="Node visited until optimality")
    save_fig(plot, save_path, "eval_node_visited_optimality")


def score_first(eval, estimator=np.mean, ax=None, save_path=None, training=None):
    first_solution = eval.loc[
        eval[eval["SolutionFound"] == 1].groupby(["Episode", "Instance", "Heuristic"])["Solution"].idxmin()
    ].sort_values("Heuristic", key=lambda series: apply_key(series, training))
    plot = sns.lineplot(data=first_solution, y="Score", x="Episode", hue="Heuristic", estimator=estimator, ax=ax)
    plot.set(xlabel="Evaluation step", ylabel="Score obtained", title="Score at first solution")
    save_fig(plot, save_path, "eval_score_first_solution")


def score_best(eval, estimator=np.mean, ax=None, save_path=None, training=None):
    first_solution = eval.loc[
        eval[eval["SolutionFound"] == 1].groupby(["Episode", "Instance", "Heuristic"])["Score"].idxmin()
    ].sort_values("Heuristic", key=lambda series: apply_key(series, training))
    plot = sns.lineplot(data=first_solution, y="Score", x="Episode", hue="Heuristic", estimator=estimator, ax=ax)
    plot.set(xlabel="Evaluation step", ylabel="Score obtained", title="Score at best solution")
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


def all(path):
    """
        Prints all performance indicators
    """
    eval = get_eval(path)

    score_first(eval)
    score_best(eval)
    node_optimality(eval)
    time_total(eval)