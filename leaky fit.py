#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on 18.08.2022

@author: annahuelemeier
"""

# load packages
import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit
import pandas as pd






#--- Data loading and preparation
dforiginal = pd.read_csv("~/Desktop/distance.txt", sep ="\t", header=None) # load in your data. My file is called "distance.txt"
dforiginal.columns=["id", "session", "trial", "grav", "translating", "articulating", "facing", "my", "mx", "move_line", "traveldistance", "travelduration", "travelvelocity", "tspeed", "nframes", "estimateddistance", "estimatederror", "timestemp", "numsecs", "ground", "block"]

dforiginal["condition"] = 2 # natural locomotion
dforiginal.loc[dforiginal["articulating"] == 0, "condition"] = 1  #static

# code the combination of condition and walker facing
dforiginal["combination"] = 1 # static
dforiginal.loc[(dforiginal["condition"] == 2) & (dforiginal["facing"] == 0), "combination"] =  2 # approaching
dforiginal.loc[(dforiginal["condition"] == 2) & ( dforiginal["facing"] == 180), "combination"] = 3 # leaving

# remove trials with estimates below reference line
data = dforiginal[dforiginal["estimateddistance"] > 0.9] 



#--- leaky Model

def leaky(x, aa, kk):
    return kk/aa * (1 - np.exp(-aa*x))
y = data["estimateddistance"]
x = data["traveldistance"]

popt,_ = curve_fit(leaky, x, y, bounds = [0, np.inf]) # calculate fit

print("aa = {}, kk = {}".format(popt[0], popt[1])) # report parameters alpha and k

plt.plot(x, leaky(x,*popt)) # plot fit
plt.show()





# leaky model for the walker combination (1 = static, 2 = approaching, 3 = leaving) und ground type (1 = gravel, 2 = stripes):
for j in list(set(data["combination"])): # combination
    for l in list(set(data["ground"])): # ground
   
          def leaky(x, aa, kk):
              return kk/aa * (1 - np.exp(-aa*x))
          temp = data.loc[(data["combination"] == j) & (data["ground"] == l)]
          y = temp["estimateddistance"]
          x = temp["traveldistance"]

          popt,_ = curve_fit(leaky, x, y, bounds = [0, np.inf])
          print(j,l,  "aa = {}, kk = {}".format(popt[0], popt[1]))


# leaky Model per participant and stimulus combination walker x ground
for i in list(set(data["id"])) : #id
    for j in list(set(data["combination"])): # combination
      for l in list(set(data["ground"])): # ground
   
          def leaky(x, aa, kk):
              return kk/aa * (1 - np.exp(-aa*x))
          temp = data.loc[(data["id"] == i) & (data["combination"] == j) & (data["ground"] == l)]
          yy= temp["estimateddistance"]
          x = temp["traveldistance"]

          popt,_ = curve_fit(leaky, x, y, bounds = [0, np.inf])
          print(j,l,  "aa = {}, kk = {}".format(popt[0], popt[1]))
          
          
          
          
          
          
