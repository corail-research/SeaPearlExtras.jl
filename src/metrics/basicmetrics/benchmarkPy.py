import os
import re
from IPython.display import display
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
pd.options.display.float_format = '{:,.4f}'.format

def split_val(input):
    if "random" in input and len(re.findall(r'\d+',input)) != 0:
        print(input)
        return re.findall(r'\d+',input)[0]
    else :
        return 0

def remove_id(input):
    if "random" in input and len(re.findall(r'\d+',input)) != 0:
        return input.replace(re.findall(r'\d+',input)[0], '')
    else :
        return input
    
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
    display(means.to_string())
    print("Stds number of nodes visited before optimality: ")
    display(stds.to_string())



def score_first(eval):
    first_solution = eval.loc[eval[(eval["SolutionFound"] == 1) & (eval["Strategy"] == "ILDS0")].groupby(["Episode","Instance","Heuristic"])["Solution"].idxmin()]
    means = first_solution[["Score","Nodes","Heuristic"]].groupby("Heuristic").mean()
    stds = first_solution[["Score","Nodes", "Heuristic"]].groupby("Heuristic").std()
    print("Mean first score: ")
    display(means.to_string())
    print("Std first score: ")
    display(stds.to_string())
        
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
    display(means.to_string())
    print("Std first AUC: ")
    display(stds.to_string())

    
def score_best(eval):
    eval["num"] = eval["Heuristic"].apply(split_val)
    eval["Heuristic"] = eval["Heuristic"].apply(remove_id)
    best_solution = eval.loc[eval[eval["SolutionFound"] == 1].groupby(["Episode", "Heuristic","num", "Strategy","Instance"])["Score"].agg(lambda x: x.idxmin())]
    best_solution.loc[(best_solution["Heuristic"]=="3layer")&(best_solution["Strategy"]=="ILDSearch100000") ]
    means = best_solution[["Score","num","Nodes","Time","Heuristic","Strategy"]].groupby(["Heuristic", "Strategy"]).mean()
    stds = best_solution[["Score","num","Nodes","Time","Heuristic", "Strategy"]].groupby(["Heuristic", "Strategy"]).std()
    print("Mean best score: ")
    display(means.to_string())
    print("Std best score: ")
    display(stds.to_string())

def time_total(eval):
    data = eval[eval["Solution"] == 0]
    means = data[["Time", "Heuristic", "Strategy"]].groupby(["Heuristic","Strategy"]).mean()
    stds = data[["Time", "Heuristic", "Strategy"]].groupby(["Heuristic", "Strategy"]).std()
    print("Mean time needed: ")
    display(means.to_string())
    print("Stds time needed: ")
    display(stds.to_string())

def time_reduction(eval):
    score_0 = eval.loc[eval[(eval["Heuristic"]=="3layer")&(eval["Strategy"]=="ILDS0")].groupby(["Episode","Instance","Heuristic"])["Score"].idxmin()]
    if len(eval[(eval["Heuristic"]=="random1")&(eval["SolutionFound"]==1)&(eval["Strategy"] == "DFS")]) !=0 :
        score_rand = eval[(eval["Heuristic"]=="random1")&(eval["SolutionFound"]==1)&(eval["Strategy"] == "DFS")]
    else :
        score_rand = eval[(eval["Heuristic"]=="random1")&(eval["SolutionFound"]==1)&(eval["Strategy"] == "DFSearch100000")]
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
    display(means.to_string())
    print("Std time reduction factor: ")
    display(stds.to_string())
    #print(score_merged[["Time_reduction","Heuristic_x"]])
    means = score_merged[["Node_reduction","Heuristic_x"]].groupby("Heuristic_x").mean()
    stds = score_merged[["Node_reduction","Heuristic_x"]].groupby("Heuristic_x").std()
    print("Mean Node reduction factor: ")
    display(means.to_string())
    print("Std Node reduction factor: ")
    display(stds.to_string())
def print_all(path):
    """
        Prints all performance indicators
    """
    import sys
    pd.options.display.float_format = '{:,.6f}'.format
    print(path)
    original_stdout = sys.stdout
    try :
        with open("/home/martom/SeaPearl/SeaPearlZoo/learning_cp/comparison/"+ path +'benchmark_V2.txt', 'w') as f:
            sys.stdout = f
            eval = get_eval("/home/martom/SeaPearl/SeaPearlZoo/learning_cp/comparison/"+ path +"benchmarks/")
            score_first(eval)
            score_best(eval)
            node_optimality(eval)
            time_total(eval)
            area_under_curve(eval)
            time_reduction(eval)
    except:
        print("Benchmark FAILED")
        sys.stdout = original_stdout
    sys.stdout = original_stdout