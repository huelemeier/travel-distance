#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on 18.08.2022

@author: annahuelemeier
"""

# load packages
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import rcParams
rcParams['font.family'] = 'sans-serif'
rcParams['font.sans-serif'] = ['Helvetica']
# import scipy.optimize as opt# followed by opt.minimize
from scipy.optimize import curve_fit
import pandas as pd
from array import *
import math
import numpy.matlib 
import seaborn as sns

import statsmodels.api as sm
import statsmodels.formula.api as smf






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

#- Plotting:
a, k = popt
x_line = np.arange(min(x), max(x))
y_line = leaky(x_line, a, k) # calculate the output for the range

plt.style.use('ggplot')
plt.plot(x_line, y_line, color = '#D9345D')
plt.suptitle("raw data described by leaky fit")
 
plt.xlabel("traveled distance")
plt.ylabel("estimated distance")
ax.set_xticks(list(set(x)))
plt.rcParams['axes.facecolor'] = '#F9F9F9'





# leaky model for the walker combination (1 = static, 2 = approaching, 3 = leaving) und ground type (1 = gravel, 2 = stripes):
for j in list(set(data["combination"])): # combination
    for l in list(set(data["ground"])): # ground
   
          def leaky(x, aa, kk):
              return kk/aa * (1 - np.exp(-aa*x))
          temp = data.loc[(data["combination"] == j) & (data["ground"] == l)]
          y = temp["estimateddistance"]
          x = temp["traveldistance"]
            

          #- model fit:
          popt,_ = curve_fit(leaky, x, y, bounds = [0, np.inf])
          print(j,l,  "aa = {}, kk = {}".format(popt[0], popt[1]))

          #- plotting: 
          a, k = popt
    
  
          x_line = np.arange(min(x), max(x))
          y_line = leaky(x_line, a, k) # calculate the output for the range
 
          fig = plt.figure()
          ax = fig.gca()
        
          plt.style.use('ggplot')
          plt.scatter(x, y, 6, alpha = 0.5, color = '#2A64AE') # plot raw data
          plt.plot(x_line, y_line, color = '#D9345D') # plot leaky fit
         
          plt.suptitle("raw data described by leaky fit")
          ax.set_title('condition {} '.format(j) + 'ground {} '.format(l))      
          plt.xlabel("traveled distance")
          plt.ylabel("estimated distance")
          ax.set_xticks(list(set(x)))
          plt.rcParams['axes.facecolor'] = '#F9F9F9'
            
            
            
# leaky Model per participant and stimulus combination walker x ground
ar = [] # store individual leaky fit parameters in separate matrix
# loop to create fit and plots
for i in list(set(data["id"])) : #id
    for j in list(set(data["combination"])): # combination
      for l in list(set(data["ground"])): # ground
   
          def leaky(x, aa, kk):
              return kk/aa * (1 - np.exp(-aa*x))
          temp = data.loc[(data["id"] == i) & (data["combination"] == j) & (data["ground"] == l)]
          y = temp["estimateddistance"]
          x = temp["traveldistance"]

          #- model fit:
          popt, _ = curve_fit(leaky, x, y, bounds=[0, np.inf])
          print(i, j, l,  "aa = {}, kk = {}".format(popt[0], popt[1]))
          ar.append(i)
          ar.append(j)           
          ar.append(l)
          ar.append(popt[0])
          ar.append(popt[1])
            
          #- Plotting:
          a, k = popt
            
          x_line = np.arange(min(x), max(x))
          y_line = leaky(x_line, a, k) # calculate the output for the range

          fig = plt.figure()
          ax = fig.gca()

          plt.style.use('ggplot')
          plt.scatter(x, y, alpha = 0.8, color = '#2A64AE') # plot raw data

          plt.plot(x_line, y_line, color = '#D9345D')
          plt.suptitle("raw data described by leaky fit")

          ax.set_title('participant {} '.format(i) + 'condition {} '.format(j) + 'ground {} '.format(l))
            
          plt.xlabel("traveled distance")
          plt.ylabel("estimated distance")
          ax.set_xticks(list(set(x)))

          plt.rcParams['axes.facecolor'] = '#F9F9F9'
        
# format new data frame with calcualted fits per participant:                  
x = ar
mat = []
while x != []:
    mat.append(x[:5])
    x = x[5:]
print(mat)
mat = pd.DataFrame(mat)
mat.columns = ['id', 'combination', 'ground', 'alpha', 'k']

del x, y, i, j, l, ar, temp, popt   # remove unnecessary variables       
          
          
          
