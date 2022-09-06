import os
import re
from IPython.display import display
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
pd.options.display.float_format = '{:,.4f}'.format

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
        
def area_under_curve(eval):
    eval["Area"] = ""
    for i in range(len(eval)):
        if eval.loc[i, "Solution"] == 0:
            eval.loc[i, "Area"] = 0
            prev_nodes = 0
        elif eval.loc[i, "SolutionFound"] == 0:
            eval.loc[i, "Area"] = 0
        else:
            eval.loc[i, "Area"] = (eval.loc[i, "Score"])*(eval.loc[i, "Nodes"]-prev_nodes)
            prev_nodes = eval.loc[i, "Nodes"]
    Auc = eval[["Episode","Instance","Area","Heuristic","Strategy"]].groupby(["Episode","Instance","Heuristic","Strategy"])["Area"].sum().reset_index()
    means = Auc[["Area", "Heuristic","Strategy"]].groupby(["Heuristic","Strategy"]).mean()
    stds = Auc[["Area", "Heuristic","Strategy"]].groupby(["Heuristic","Strategy"]).std()
    print("Mean first AUC: ")
    display(means)
    print("Std first AUC: ")
    display(stds)

def score_best(eval):
    first_solution = eval.loc[eval[eval["SolutionFound"] == 1].groupby(["Episode", "Instance", "Heuristic", "Strategy"])["Score"].agg(lambda x: x.idxmin())]
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

def time_reduction(eval):

    score_0 = eval.loc[eval[(eval["Heuristic"]!="random")&(eval["Strategy"]=="ILDS0")].groupby(["Episode","Instance","Heuristic"])["Score"].idxmin()]
    score_rand = eval[(eval["Heuristic"]=="random")&(eval["SolutionFound"]==1)]
    keys = list(["Instance","Score"])  #
    i1 = score_rand.set_index(keys).index
    i2 = score_0.set_index(keys).index
    score_rand_0 = score_rand[i1.isin(i2)]
    score_merged = score_0.merge(score_rand_0, left_on=["Instance"], right_on =["Instance"])
    score_merged["Time_reduction"]=score_merged["Time_y"].divide(score_merged["Time_x"])
    score_merged["Node_reduction"]=score_merged["Nodes_y"].divide(score_merged["Nodes_x"])

    score_merged = score_merged[["Time_reduction","Node_reduction", "Instance", "Heuristic_x"]].groupby(["Instance", "Heuristic_x"]).mean().reset_index()
    means = score_merged[["Time_reduction","Heuristic_x"]].groupby("Heuristic_x").mean()
    stds = score_merged[["Time_reduction","Heuristic_x"]].groupby("Heuristic_x").std()
    print("Mean time reduction factor: ")
    display(means)
    print("Std time reduction factor: ")
    display(stds)
    print(score_merged[["Time_reduction","Heuristic_x"]])

    means = score_merged[["Node_reduction","Heuristic_x"]].groupby("Heuristic_x").mean()
    stds = score_merged[["Node_reduction","Heuristic_x"]].groupby("Heuristic_x").std()
    print("Mean Node reduction factor: ")
    display(means)
    print("Std Node reduction factor: ")
    display(stds)
def print_all(path):
    """
        Prints all performance indicators
    """
    import sys
    pd.options.display.float_format = '{:,.6f}'.format

    original_stdout = sys.stdout
    print("/home/martom/SeaPearl/SeaPearlZoo/learning_cp/comparison/"+path+'benchmark.txt')
    with open("/home/martom/SeaPearl/SeaPearlZoo/learning_cp/comparison/"+path+'benchmark.txt', 'w') as f:
        sys.stdout = f
        eval = get_eval("/home/martom/SeaPearl/SeaPearlZoo/learning_cp/benchmarks/"+path)
        score_first(eval)
        score_best(eval)
        node_optimality(eval)
        time_total(eval)
        area_under_curve(eval)
        time_reduction(eval)
        sys.stdout = original_stdout
