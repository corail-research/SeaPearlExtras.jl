import os
import re
from IPython.display import display
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
pd.options.display.float_format = '{:,.1f}'.format

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

def node_optimality(eval):
    data = eval[(eval["Solution"] == 0) & (eval["Strategy"] == "DFS")]
    means = data[["Nodes","Heuristic"]].groupby("Heuristic").mean()
    stds = data[["Nodes","Heuristic"]].groupby("Heuristic").std()
    print("Mean number of nodes visited before optimality: ")
    display(means)
    print("Stds number of nodes visited before optimality: ")
    display(stds)



def score_first(eval):
    first_solution = eval.loc[eval[(eval["SolutionFound"] == 1) & (eval["Strategy"] == "ILDS0")].groupby(["Episode", "Instance", "Heuristic"])["Solution"].idxmin()]
    means = first_solution[["Score", "Heuristic"]].groupby("Heuristic").mean()
    stds = first_solution[["Score", "Heuristic"]].groupby("Heuristic").std()
    print("Mean first score: ")
    display(means)
    print("Std first score: ")
    display(stds)
    


def score_best(eval):
    first_solution = eval.loc[eval[(eval["SolutionFound"] == 1) & (eval["Strategy"].str.startswith("ILDS"))].groupby(["Episode", "Instance", "Heuristic"])["Score"].idxmin()]
    means = first_solution[["Score", "Heuristic", "Strategy"]].groupby(["Heuristic", "Strategy"]).mean()
    stds = first_solution[["Score", "Heuristic", "Strategy"]].groupby(["Heuristic", "Strategy"]).std()
    print("Mean best score: ")
    display(means)
    print("Std best score: ")
    display(stds)


def time_total(eval):
    data = eval[eval["Solution"] == 0]
    means = data[["Time", "Heuristic", "Strategy"]].groupby(["Heuristic","Strategy"]).mean()
    stds = data[["Time", "Heuristic", "Strategy"]].groupby(["Heuristic", "Strategy"]).std()
    print("Mean time needed: ")
    display(means)
    print("Stds time needed: ")
    display(stds)


def all(path):
    """
        Prints all performance indicators
    """
    eval = get_eval(path)

    score_first(eval)
    score_best(eval)
    node_optimality(eval)
    time_total(eval)