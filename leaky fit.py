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
import matplotlib.backends.backend_pdf

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
import itertools

import sys; sys.executable





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



#--- leaky Model with standard deviation
# model defintion
def leaky(x, aa, kk, b):
    return kk/aa * (1 - np.exp(-aa*x+b))
# propagation of uncertainty:
def uncertainty(x, aa, kk, s_a, s_k): # Formel Simplification aus: https://en.wikipedia.org/wiki/Propagation_of_uncertainty 
    u_k =  1/aa * (1 - np.exp(-aa*x)) # Ableitung nach k
    u_a = kk/aa**2 * (np.exp(-aa*x)-1) + kk*x/aa * np.exp(-aa*x) # Ableitung nach alpha
    s_total = np.sqrt((u_k*s_k)**2 + (u_a*s_a)**2)
    return s_total

# calculate a, k and standard deviation across participants and conditons:
y = data["estimateddistance"]
x = data["traveldistance"]

popt, pcov = curve_fit(leaky, x, y, bounds=[0, np.inf])
print("aa = {}, kk = {}".format(popt[0], popt[1]))
perr = np.sqrt(np.diag(pcov)) # compute one standard deviation errors on the parameters perr[0] ist von alpha, perr[1] von k




#--- calculate descriptves and model fit per participant
# a and k per participant, ground type and walker combination (leaky.txt file)
ar = [] # create data frame to store a and k per participant
for i in list(set(data["id"])):  # id
    for j in list(set(data["combination"])):  # combination
        for l in list(set(data["ground"])):  # ground

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
        
x = ar
mat = []
while x != []:
    mat.append(x[:5])
    x = x[5:]
print(mat)
mat = pd.DataFrame(mat)
mat.columns = ['id', 'combination', 'ground', 'alpha', 'k']
#joblib.dump(mat, 'mat.txt')
#mat.to_csv(r'leaky.txt', header=None, index=None, sep='\t', mode='a')
del i, j, l, x, y, temp, popt





# descriptives estimated distance
ar = []
for i in list(set(data["traveldistance"])):
    for  j in list(set(data["combination"])):  # combination
        for l in list(set(data["ground"])):
    
            temp = data.loc[(data["traveldistance"] == i) & (data["combination"] == j) & (data["ground"] == l)]
            sdy = np.std(temp["estimateddistance"])
            meany = np.mean(temp["estimateddistance"])
            
            ar.append(sdy)
            ar.append(meany)
            ar.append(i)
            ar.append(j)
            ar.append(l)

x = ar
desc = []
while x != []:
    desc.append(x[:5])
    x = x[5:]
print(desc)
desc = pd.DataFrame(desc)
desc.columns = ['sdy', 'meany', 'traveldistance', 'combination', 'ground']
del x, i, j, l, ar, temp, sdy, meany










#--- Plotting:
a, k = popt
x_line = np.arange(min(x), max(x))
y_line = leaky(x_line, a, k) # calculate the output for the range
s_line = uncertainty(x_line, a, k, perr[0], perr[1]) # Für alpha und k die Werte aus der pcov einsetzen

fig = plt.figure()
ax = fig.gca()
plt.style.use('ggplot')

#plt.scatter(x, y, 6, alpha = 0.5, color = '#2A64AE') # raw data
plt.plot(x_line, y_line-s_line, color = '#E38B90')
plt.plot(x_line, y_line+s_line, color = '#E38B90')
plt.plot(x_line, y_line, color = '#D9345D')
plt.suptitle("raw data described by leaky fit")
plt.xlabel("traveled distance")
plt.ylabel("estimated distance")
ax.set_xticks(list(set(x)))
plt.rcParams['axes.facecolor'] = '#F9F9F9'
plt.show()

#- parameter errors // sd of k and alpha
sigma_ab = np.sqrt(np.diagonal(pcov))
from uncertainties import ufloat
aa_sd = ufloat(popt[0], sigma_ab[0])
k_sd = ufloat(popt[1], sigma_ab[1])
text_res = "Best fit parameters:\nalpha = {}\nk = {}".format(aa_sd, k_sd)
print(text_res)



#--- Plots per participant (per condition):

i_j = 0
i_l = 0
plt.clf()
#pdf = matplotlib.backends.backend_pdf.PdfPages("per participant leaky fit and raw data.pdf")

for i in list(set(data["id"])):  # id
    fig, ax = plt.subplots(2, 3, figsize = (10,5), sharex = True, sharey=True)

    for j in list(set(data["combination"])):  # combination
        for l in list(set(data["ground"])):  # ground
                temp = data.loc[(data["id"] == i) & (data["combination"] == j) & (data["ground"] == l)]
           
                y = temp["estimateddistance"]
                x = temp["traveldistance"]
            
                #- model fit:
                popt, _ = curve_fit(leaky, x, y, bounds=[0, np.inf])
                print(i, j, l,  "aa = {}, kk = {}".format(popt[0], popt[1]))
        
                perr = np.sqrt(np.diag(pcov)) # compute one standard deviation errors on the parameters perr[0] ist von alpha, perr[1] von k

                #- Plotting:
                a, k = popt

                x_line = np.arange(min(x), max(x))
                y_line = leaky(x_line, a, k) # calculate the output for the range
                s_line = uncertainty(x_line, a, k, perr[0], perr[1]) # standard error

                ax[i_l, i_j].scatter(x, y, 6, alpha = 0.5, color = '#2A64AE') # raw data
                #ax[i_l, i_j].plot(x_line, y_line-s_line, color = '#E38B90')
                #ax[i_l, i_j].plot(x_line, y_line+s_line, color = '#E38B90')
                ax[i_l, i_j].plot(x_line, y_line, color = '#D9345D')

                plt.style.use('ggplot')

                plt.suptitle("raw data described by leaky fit")
                ax[i_l, i_j].set_title('id {} '.format(i) + 'condition {} '.format(j) + 'ground {} '.format(l))
        
                ax[1,0].set_xlabel("traveled distance")
                ax[0,0].set_ylabel("estimated distance")
                ax[i_l, i_j].set_xticks(list(set(x)))
 
                i_l += 1
        i_j += 1
        i_l=0
 
    plt.tight_layout()   
    figs = list(map(plt.figure, plt.get_fignums()))
    i_j = 0
    i_l = 0 
   # pdf.savefig()
    plt.show()
    plt.clf()

#pdf.close()     


#--- Plots per condition
# leaky model for the walker combination (1 = static, 2 = approaching, 3 = leaving) und ground type (1 = gravel, 2 = stripes):
for j in list(set(data["combination"])): # combination
    for l in list(set(data["ground"])): # ground
   
          def leaky(x, aa, kk, b):
              return kk/aa * (1 - np.exp(-aa*x + b))
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
            
            
            
#--- Paper plots data modelled according to leaky model

colourscheme = itertools.cycle(['#DF6456', "#72C4BB","#F2B64E"]) # Farbwahl umdrehen, um nicht im Datensatz neue Variable einzufügen (wie in R)

i_j = 0
i_l = 0
plt.clf()
fig, ax = plt.subplots(2,1, figsize = (8,13), sharex = True, sharey=True)
plt.subplots_adjust(left=0.1, bottom=0.1, right=0.9, top=0.9, wspace=4, hspace=4)
plt.style.use('ggplot')
#pdf = matplotlib.backends.backend_pdf.PdfPages("leaky fit solely v2.pdf")

for  l in list(set(data["ground"])):  # combination
    for j in list(set(data["combination"])):  # ground

        temp = data.loc[(data["combination"] == j) & (data["ground"] == l)]
        y = temp["estimateddistance"]
        x = temp["traveldistance"]
        
        # mean descriptives:
        tempdesc = desc.loc[(desc["combination"] == j) & (desc["ground"] == l)]
        sdy = tempdesc["sdy"]
        meany = tempdesc["meany"]
        x_x = tempdesc["traveldistance"]
        
        #- model fit
        popt, pcov = curve_fit(leaky, x, y, bounds=[0, np.inf])
        #print(j, l,  "aa = {}, kk = {}".format(popt[0], popt[1]))
        perr = np.sqrt(np.diag(pcov)) # compute one standard deviation errors on the parameters perr[0] ist von alpha, perr[1] von k
        #print(j, l,  "au = {}, ku = {}".format(np.sqrt(perr[0]), np.sqrt(perr[1])))

        #- Plotting:
        a, k = popt
    
        x_line = np.arange(0, max(x)+1)
        y_line = leaky(x_line, a, k) # calculate the output for the range
        print(max(y_line), j, l)
        #s_line = uncertainty(x_line, a, k, perr[0], perr[1])

        plt.suptitle("leaky fit")

       # ax[i_l, i_j].errorbar(x_x, meany, yerr=sdy, fmt='o', color='#2A64AE', ecolor='#869ED0')#, elinewidth=3, capsize=0);
        ax[i_l].plot(x_line, y_line, color = next(colourscheme))
        #ax[i_l].text(max(x_line)+1, max(y_line), 'c = %.0f'%(j))
        if i_l == 0:
            ax[0].text(24, 10.65, 'static', color = "#161412")
            ax[0].text(24, 10.25, 'approaching', color = "#161412")
            ax[0].text(24, 9.59, 'leaving', color = "#161412")
            
            # vertical lines
            ax[0].vlines(x=[4, 4], ymin=3.818, ymax=4.087, colors=['#161412', '#161412'], ls=':', lw=1)
            ax[0].vlines(x=[5.66, 5.66], ymin=5.013, ymax=5.66, colors=['#161412', '#161412'], ls=':', lw=1)
            ax[0].vlines(x=[8, 8], ymin=6.399, ymax=8, colors=['#161412', '#161412'], ls=':', lw=1)
            ax[0].vlines(x=[11.31, 11.31], ymin=7.782, ymax=11.31, colors=['#161412', '#161412'], ls=':', lw=1)
            ax[0].vlines(x=[16, 16], ymin=8.852, ymax=16, colors=['#161412', '#161412'], ls=':', lw=1)
            ax[0].vlines(x=[22.63, 22.63], ymin=9.592, ymax=22.63, colors=['#161412', '#161412'], ls=':', lw=1)
            
        elif i_l == 1:
            ax[1].text(24, 9.8, 'static', color = "#161412")
            ax[1].text(24, 8.4, 'approaching', color = "#161412")
            ax[1].text(24, 7.9, 'leaving', color = "#161412")
            
            ax[1].vlines(x=[4, 4], ymin=3.477, ymax=4, colors=['#161412', '#161412'], ls=':', lw=1)
            ax[1].vlines(x=[5.66, 5.66], ymin=4.452, ymax=5.66, colors=['#161412', '#161412'], ls=':', lw=1)
            ax[1].vlines(x=[8, 8], ymin=5.503, ymax=8, colors=['#161412', '#161412'], ls=':', lw=1)
            ax[1].vlines(x=[11.31, 11.31], ymin=6.523, ymax=11.31, colors=['#161412', '#161412'], ls=':', lw=1)
            ax[1].vlines(x=[16, 16], ymin=7.362, ymax=16, colors=['#161412', '#161412'], ls=':', lw=1)
            ax[1].vlines(x=[22.63, 22.63], ymin=7.940, ymax=22.63, colors=['#161412', '#161412'], ls=':', lw=1)

       # ax[1].text(24, max(y_line), 'c = %.0f'%(j))

#ax[i_l].annotate(, (max(x)+2, y_line))
        ax[1].set_xlabel("traveled distance", loc="left", size = 12)
        ax[i_l].set_ylabel("estimated distance", size = 12)
        ax[i_l].set_xticks(list(set(x)), size = 10)
        ax[i_l].set_yticks(list(set(x)), size = 10)
        #ax[i_l].set_title('ground {} '.format(l), loc="left")
        ax[0].set_title('gravel', loc="left")
        ax[1].set_title('stripes', loc="left")
        
        
        ax[i_l].hlines(y=4, xmin=0, xmax=4, colors=['#161412', '#161412'], ls=':', lw=1)
        ax[i_l].hlines(y=5.66, xmin=0, xmax=5.66, colors=['#161412', '#161412'], ls=':', lw=1)
        ax[i_l].hlines(y=8, xmin=0, xmax=8, colors=['#161412', '#161412'], ls=':', lw=1)
        ax[i_l].hlines(y=11.31, xmin=0, xmax=11.31, colors=['#161412', '#161412'], ls=':', lw=1)
        ax[i_l].hlines(y=16, xmin=0, xmax=16, colors=['#161412', '#161412'], ls=':', lw=1)
        ax[i_l].hlines(y=22.63, xmin=0, xmax=22.63, colors=['#161412', '#161412'], ls=':', lw=1)
        
        
        i_j += 1

   # ax[i_l].plot(x_line, y_line, color = '#D9345D')
   # ax[i_l].plot(x_line, y_line, color = '#D9345D')
   # ax[i_l].plot(x_line, y_line, color = '#D9345D')

    #
    
        
    #ax[1,1].set_xlabel("traveled distance", loc="left")
    #ax[1,1].set_ylabel("estimated distance")
    plt.rcParams['axes.facecolor'] = 'white'

    i_l += 1
    i_j=0


    plt.tight_layout()
#pdf.savefig(fig)

plt.show()

#pdf.close()       

del i_j, i_l, temp, tempdesc, x_x

          
    
    

##-- Model per stimulus combination
# leaky Model für die Variablenkombinationen walker combination und ground type:

i_j = 0
i_l = 0
plt.clf()

fig, ax = plt.subplots(2, 3, figsize = (14,6), sharex = True, sharey=True)
plt.subplots_adjust(left=0.1, bottom=0.1, right=0.9, top=0.9, wspace=0.4, hspace=0.4)
plt.style.use('ggplot')
#pdf = matplotlib.backends.backend_pdf.PdfPages("leaky fit through mean data2.pdf")

for  j in list(set(data["combination"])):  # combination
    for l in list(set(data["ground"])):  # ground

        temp = data.loc[(data["combination"] == j) & (data["ground"] == l)]
        y = temp["estimateddistance"]
        x = temp["traveldistance"]
        
        # mean descriptives:
        tempdesc = desc.loc[(desc["combination"] == j) & (desc["ground"] == l)]
        sdy = tempdesc["sdy"]
        meany = tempdesc["meany"]
        x_x = tempdesc["traveldistance"]
         
        
        #- model fit
        popt, pcov = curve_fit(leaky, x, y, bounds=[0, np.inf])
       # print(j, l,  "aa = {}, kk = {}".format(popt[0], popt[1]))
        perr = np.sqrt(np.diag(pcov)) # compute one standard deviation errors on the parameters perr[0] ist von alpha, perr[1] von k
        print(j, l,  "au = {}, ku = {}".format(np.sqrt(perr[0]), np.sqrt(perr[1])))

        #- Plotting:
        a, k = popt
    
        x_line = np.arange(0, max(x)+1)
        y_line = leaky(x_line, a, k) # calculate the output for the range
        s_line = uncertainty(x_line, a, k, perr[0], perr[1])


        #ax[i_l, i_j].scatter(x, y, 6, alpha = 0.5, color = '#2A64AE') # raw data
        ax[i_l, i_j].errorbar(x_x, meany, yerr=sdy, fmt='o', color='#2A64AE', ecolor='#869ED0')#, elinewidth=3, capsize=0);
        
        #ax[i_l, i_j].plot(x_line, y_line-s_line, color = '#E38B90')
        #ax[i_l, i_j].plot(x_line, y_line+s_line, color = '#E38B90')
        ax[i_l, i_j].plot(x_line, y_line, color = '#D9345D')

        
        
        plt.suptitle("average data described by leaky fit")
        ax[i_l, i_j].text(1, 15, 'alpha = %.3f'%(popt[0]))
        ax[i_l, i_j].text(10, 15, '± %.3f'%(np.sqrt(perr[0])))
        ax[i_l, i_j].text(1, 13, 'k = %.3f'%(popt[1]))
        ax[i_l, i_j].text(10, 13, '± %.3f'%(np.sqrt(perr[1])))



        ax[i_l, i_j].set_title('condition {} '.format(j) + 'ground {} '.format(l), loc="left")
        
        ax[1,0].set_xlabel("traveled distance", loc="left")
        ax[0,0].set_ylabel("estimated distance")
        ax[i_l, i_j].set_xticks(list(set(x)))
        plt.rcParams['axes.facecolor'] = '#F9F9F9'

       # figs = list(map(plt.figure, plt.get_fignums()))
        i_l += 1
    i_j += 1
    i_l=0


    plt.tight_layout()
#pdf.savefig(fig)
   # plt.subplot_tool()

plt.show()

#pdf.close()       

          
          
