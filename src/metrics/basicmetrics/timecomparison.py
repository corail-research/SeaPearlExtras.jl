import sys
import os
import re
import copy
from IPython.display import display
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
pd.options.display.float_format = '{:,.4f}'.format
sys.path.insert(0, "/home/martom/SeaPearl/SeaPearlExtras.jl/src/metrics/basicmetrics/")
from benchmarkPy import *

path ="/home/martom/SeaPearl/SeaPearlZoo/learning_cp/benchmarks/2022-09-01/exp_004_final_benchmark_GC_L_target_500_80_80_6000_161_15-57-06/"
eval = get_eval(path)

time_reduction(eval)

score_0 = eval.loc[eval[(eval["Heuristic"]!="random")&(eval["Strategy"]=="ILDS0")&(eval["SolutionFound"]==1)].groupby(["Episode","Instance","Heuristic"])["Score"].idxmin()]
score_rand = eval[(eval["Heuristic"] == "random")&(eval["SolutionFound"]==1)]
keys = list(["Instance","Score"])  #
i1 = score_rand.set_index(keys).index
i2 = score_0.set_index(keys).index
score_rand_0 = score_rand[i1.isin(i2)]nZLRe3US+NGf


score_merged = score_0.merge(score_rand_0, left_on=["Instance"], right_on =["Instance"])
score_merged["Time_reduction"]=score_merged["Time_y"].divide(score_merged["Time_x"])
score_merged = score_merged[["Time_reduction", "Instance", "Heuristic_x"]].groupby(["Instance", "Heuristic_x"]).mean().reset_index()
means = score_merged[["Time_reduction","Heuristic_x"]].groupby("Heuristic_x").mean()
stds = score_merged[["Time_reduction","Heuristic_x"]].groupby("Heuristic_x").std()
print("Mean time reduction factor: ")
display(means)
