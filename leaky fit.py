#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on 18.08.2022

@author: annahuelemeier
"""

# load packages
import numpy as np
import matplotlib.pyplot as plt
#import scipy.optimize as opt# followed by opt.minimize
from scipy.optimize import curve_fit
import pandas as pd






#--- Data loading and preparation
dforiginal = pd.read_csv("~/Desktop/distance.txt", sep ="\t", header=None)
dforiginal.columns=["id", "session", "trial", "grav", "translating", "articulating", "facing", "my", "mx", "move_line", "traveldistance", "travelduration", "travelvelocity", "tspeed", "nframes", "estimateddistance", "estimatederror", "timestemp", "numsecs", "ground", "block"]

dforiginal["condition"] = 2 # natural locomotion
dforiginal.loc[dforiginal["articulating"] == 0, "condition"] = 1  #static

# code the combination of condition and walker facing
dforiginal["combination"] = 1 # static
dforiginal.loc[(dforiginal["condition"] == 2) & (dforiginal["facing"] == 0), "combination"] =  2 # approaching
dforiginal.loc[(dforiginal["condition"] == 2) & ( dforiginal["facing"] == 180), "combination"] = 3 # leaving

data = dforiginal[dforiginal["estimateddistance"] > 0.9] 



#--- leaky Model

def leaky(x, aa, kk):
    return kk/aa * (1 - np.exp(-aa*x))
y = data["estimateddistance"]
x = data["traveldistance"]

popt,_ = curve_fit(leaky, x, y, bounds = [0, np.inf])#, p0=np.array([0.15, 1.287]))

print("aa = {}, kk = {}".format(popt[0], popt[1]))

plt.plot(x, leaky(x,*popt))
plt.show()


# Test mit den Daten aus Mathematica

def leaky(x, aa, kk):
    return kk/aa * (1 - np.exp(-aa*x))
y = [4.8, 5.3, 5.3, 6.3, 7.4, 9]
y = pd.Series(y)
x = [4, 5.66, 8, 11.31, 16, 22.63]
x = pd.Series(x)

popt,_ = curve_fit(leaky, x, y, bounds=(0, np.inf))#, p0=np.array([0.15, 1.287]))

print("aa = {}, kk = {}".format(popt[0], popt[1]))

plt.plot(x, leaky(x,*popt))
plt.show()

# Aus Mathematica
# aa = 0.150749
# kk = 1.28679











# leaky Model für die Variablenkombinationen walker combination und ground type:
for j in list(set(data["combination"])): # combination
    for l in list(set(data["ground"])): # ground
   
          def leaky(x, aa, kk):
              return kk/aa * (1 - np.exp(-aa*x))
          temp = data.loc[(data["combination"] == j) & (data["ground"] == l)]
          y = temp["estimateddistance"]
          x = temp["traveldistance"]

          popt,_ = curve_fit(leaky, x, y, bounds = [0, np.inf])
          print(j,l,  "aa = {}, kk = {}".format(popt[0], popt[1]))


# leaky Model pro VP und pro Variablenkombination (combination x ground)
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
          
          
          
          
          
          
