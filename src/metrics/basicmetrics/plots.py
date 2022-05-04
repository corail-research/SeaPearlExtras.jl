import os
import re

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns


def get_eval(path):
    files = os.listdir(path)
    # We keep only csv file
    files = [file for file in files if re.search(".*\.csv$", file) is not None]
    # We keep only non-training file i.e. evaluation file
    files = [file for file in files if re.search(".*training.*", file) is None]
    # We read the csv into a pandas.Dataframe
    dfs = [pd.read_csv(path + file) for file in files]
    # We get the names of the heuristics.
    names = [re.search("([A-Za-z0-9]*)\.csv$", file).group(1) for file in files]
    for i in range(len(names)):
        dfs[i]["Heuristic"] = names[i]

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
    names = [re.search("(training[A-Za-z0-9]*)\.csv$", file).group(1) for file in files]
    for i in range(len(names)):
        dfs[i]["Heuristic"] = names[i]

    # We concat every eval dataframe into one
    training = pd.concat(dfs, axis=0, ignore_index=True)
    return training


def node_total(eval, estimator=np.mean, ax=None):
    plot = sns.lineplot(
        data=eval[eval["Solution"] == 0], y="Nodes", x="Episode", hue="Heuristic", estimator=estimator, ax=ax
    )
    plot.set(xlabel="Evaluation step", ylabel="Nodes visited", title="Node visited until optimality")


def node_first(eval, estimator=np.mean, ax=None):
    first_solution = eval.loc[
        eval[eval["SolutionFound"] == 1].groupby(["Episode", "Instance", "Heuristic"])["Solution"].idxmin()
    ]
    plot = sns.lineplot(data=first_solution, y="Nodes", x="Episode", hue="Heuristic", estimator=estimator, ax=ax)
    plot.set(xlabel="Evaluation step", ylabel="Nodes visited", title="Node visited until first solution")


def score_first(eval, estimator=np.mean, ax=None):
    first_solution = eval.loc[
        eval[eval["SolutionFound"] == 1].groupby(["Episode", "Instance", "Heuristic"])["Solution"].idxmin()
    ]
    plot = sns.lineplot(data=first_solution, y="Score", x="Episode", hue="Heuristic", estimator=estimator, ax=ax)
    plot.set(xlabel="Evaluation step", ylabel="Score obtained", title="Score at first solution")


def time_total(eval, estimator=np.mean, ax=None):
    plot = sns.lineplot(
        data=eval[eval["Solution"] == 0], y="Time", x="Episode", hue="Heuristic", estimator=estimator, ax=ax
    )
    plot.set(xlabel="Evaluation step", ylabel="Time needed", title="Time needed to prove optimatility")


def node_rollmean(training, window=100, ax=None):
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
        title="Sliding average over the last {} episodes of the number of nodes visited during an episode.".format(
            window
        ),
    )


def reward_rollmean(training, window=100, ax=None):
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


def loss_rollmean(training, window=100, ax=None):
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
    plot.set(
        xlabel="Training episode",
        ylabel="Loss",
        title="Sliding average over the last {} episodes of the loss.".format(window),
    )


def summary(eval, training, estimator=np.mean, window=100):
    sns.set(rc={"figure.figsize": (24, 16)})
    _, axs = plt.subplots(nrows=2, ncols=3)

    node_total(eval, estimator=estimator, ax=axs[0][0])
    node_first(eval, estimator=estimator, ax=axs[0][1])
    if not eval["Score"].isnull().values.all():
        score_first(eval, estimator=estimator, ax=axs[0][2])
    node_rollmean(training, window=window, ax=axs[1][0])
    reward_rollmean(training, window=window, ax=axs[1][1])
    loss_rollmean(training, window=window, ax=axs[1][2])
