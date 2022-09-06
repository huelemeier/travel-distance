# Distance perception in the presence of biological motion
This repository contain scripts to run the experiment and to do the follow-up analyses.
These scripts simulate an observer's forwarding self-motion through a crowd of point-light walkers. In each trial, self-motion simulation has a different velocity and traveled distance. Point-light walkers ressemble a crowd of humans that either approaches, leaves, or remains static. Participants' task is to carefully watch the simulation, and estimate the traveled distance after each trial by placing a walker on a line to the approached distance in the world. 
The following video shows one trial as example:

https://user-images.githubusercontent.com/69513270/182567281-a54efc79-a7d4-403b-8d10-4421c04e88fb.mp4

## Technical requirements and set-up
These scripts are optimized for MatLab 2021b with Psychtoolbox (http://psychtoolbox.org/download.html) and OpenGL add-on libraries from the Psychtoolbox. So what needs to be installed on you computer are Matlab and Psychtoolbox. If you want to run the analyses for your data, please install R with RStudio and Python with Spyder.

## Set-up
Download all the files and add them to your Matlab folder. Within your Matlab folder, create a subfolder names "functions". Move the script "geFrustum" to this subfolder. Add the Python and R files to your respective folder. 

## Explanation of the scripts
- github_travel_distance_0_16.m: This is the main script creating the scene. 
- getFrustum.m: this script generates frustum data. The main script uses this script to do some calculations. No need to adapt this script.
- extrapolatewalkerdata.m: we extrapolated walker motion data (sample_walker3) to generate slightly slower and faster articulating walkers. The matching translation speed is generated in the main script. You do not need to do anything with that script. If you want to, you can extrapolate your own walker motion speeds with that script. The main script does not use this script.
- sample_walker3: motion data for point_light walker with normal speed
- sample_walker_0.8: motion data for point_light walker with slower speed
- sample_walker_1.2: motion data for point_light walker with faster speed
- stripes.rgb.tiff: ground type stripes
- gravel.rgb.tiff: ground type gravel
- leaky fit.py: Python script to model the data according to the leaky path fit by Lappe et al. (2007)

# Stimulus script
## Run the script
Open the script in Matlab and click on 'run'. Matlab automatically requires your input in the command line, and subsequently asks questions. Enter the participant id and further information subsequently. When done, Psychtoolbox automatically opens a window and runs the script in that window. You will see the stimulus presentation. After each presentation, you are required to estimate your traveled distance by moving the mouse along the vertical axis. Confirm your answer by pressing the left mouse buttom. Subsequently, the next trial starts. The script finishes when all trials are done.

You want to see the true traveled distance? Just change show_true_distance (line 15) in the script from false to true:
```matlab
show_true_distance = true; %show true traveled distance. 
```

## Technical information about the scene

### Point-light walkers
We apply point-light walkers to operationalize human motion. These walkers originated from the motion-tracking data of a single walking human (de Lussanet et al., 2008). Each walker consists of 12 points corresponding to the ankles of a human body (knee, hip, hands, elbow, and shoulder joints). 

<img width="1920" alt="background point-light walker" src="https://user-images.githubusercontent.com/69513270/182680560-db827f69-a77c-470a-97c1-41b14cfd2a2b.png">

For the experiment, we create a crowd of 30 colored walkers. Each walker starts individually with a random selection starting position in the gait cycle. The group appears collectively as static, approaching or leaving the observer. Because point-light walkers are ambiguous in their facing direction when static, we only show static walkers facing the observer (Vanrie et al., 2004). 
![scene with stripes ground](https://user-images.githubusercontent.com/69513270/182351822-dc74d917-510e-4dd5-95c3-7c366598492c.png) ![scene with gravel ground](https://user-images.githubusercontent.com/69513270/182353091-25c86c42-f012-42db-bd85-f7a1c1abf1a3.png)

### Articulation speed
In real-life scenarios, humans differ in their translation, and thus, articulation speed (Masselink & Lappe, 2015). To keep the scene close to reality, we manipulate the articulation and translation speed of the walkers. The original motion-tracking data have a matching translation speed of 0.013 (0.6m/s.). By linear interpolation (see Matlab Skript extrapolatewalkerdata.m), we create two more motion files with either 0.8 (slower) or 1.2 times (faster) the original articulation speed. Translation speed is adjusted accordingly. The three different articulation and translation speeds are divided equally among the 30 point-light walkers. The average walker speed remains constant at 0.013 at any trial. Randomized position in depth combined with a randomized starting position in the gait cycle let the crowd appear naturally.

### Walker position
The walkers' positions are uniformly sampled in the frustum. We limit their position in depth to 26 m maximum so that walkers appear at an adequate sight. This limited in-depth position is beneficial for leaving crowds combined with slow observer speeds. When walkers disappear from the frustum, we replace them at 23 m in depth and correct for the movement speed of the observer.
To avoid collisions with static or approaching walkers, we place the walkers 1.5 m each left and right past the observer. Such a replacement creates a kind of tunnel to form through the crowd. Shortly before the end of the trial (maximum 600 frames left), walkers disappearing from the frustum can be placed within the tunnel without any risk of collision. This setting does not reveal any information about travel distance or travel velocity. But it makes the scene look realistic. Leaving crowds are located without such replacements within the frustum. 

### Experimental scene
The experimental world spans over 60 m scene depths. We placed a visible ground at eye height (1.60 m). Its appearance could either be structured (gravel) or unstructured (stripes in the motion direction). The gravel ground provides independent optic flow, while the stripes ground neither conveys any structure nor optic flow. 
<img width="664" alt="Bildschirmfoto 2022-08-02 um 12 32 11" src="https://user-images.githubusercontent.com/69513270/182355366-0e09f7b7-b11b-4c51-89cb-ccfa66a9b493.png">

### Self-motion simulation
We simulate observers' forwarding self-motion towards a crowd of point-light walkers. Travel distances are chosen by Lappe et al. (2007): 4.00 m, 5.66 m, 8.00 m, 11.31 m, 16.00 m, and 22.63 m. All distances are traveled at 0.013, equal to the average translation speed of the crowd. In addition, short distances (4.00 m, 5.66 m, 8.00 m) are simulated more slowly at 0.0104, which is half the crowd's average speed. For long distances (11.31 m, 16.00 m, 22.63 m), we choose a simulation speed of 0.0154, or 1.5 faster than the crowd. 

### Conditions
We combine three walker conditions (approaching vs. leaving vs. static), two ground conditions (gravel vs. stripes) with six traveled distances (4.00 m, 5.66 m, 8.00 m, 11.31 m, 16.00 m, 22.63 m), and two different self-motion speeds (equally fast as the walkers vs. unequally fast as the walkers). This combination of variables results in 72 trials. We repeat the stimulus combinations five times giving 360 in total. 

### Distance estimation // Procedure
Participants' task is to reproduce the traveled distance by placing a point-light walker on a blue line from a red starting line (at 2.624 m) as far as they went before ('adjust-to-target'-paradigm; Lappe & Frenz, 2009). Moving the walker in-depth immediately rescales it according to its position in depth. This rescaling should help participants receive a better depth impression, thus, increasing estimation accuracy. 
![distance estimation with walker on the estimation line](https://user-images.githubusercontent.com/69513270/182351519-199879d5-9e5f-4dc4-bfdb-97191539c257.png)

Depending on travel distance and velocity, a trial lasts between 5 and 28 seconds. To avoid fatigue effects we divide the experiment into four sessions on two days. So when entering the session number, make sure to choose a number between 1 and 4. Trials are blocked according to the ground type (gravel vs stripes). We assigned participants alternatingly to start their session with either the gravel or stripes ground type. 



# Analysis
The analysis includes descriptive and statistical analysis in R, and computational modeling in Python.

## Leaky path fit
According to the model (Lappe et al., 2007), two parameters influence the instantaneous change of distance: the leak factor α and the gain factor k. The leak rate descends, whereas the gain factor increases the integrated distance value over the length of motion. In the present way to ask participants to gauge their traveled distance ("adjust-to-target"), the gain factor k gradually increments the distance from the origin. The leakage increases proportionally to the current distance from the origin by the leak rate α. Hence, longer distances lead to more decrease in the current distance from the origin such that the extent of underestimation increases.
The python script now fits the model to the data and calculates α and k. Further, the script creates plot with raw data and their respective leaky model fit. The figure below shows some data as example
![example plot - data described by leaky fit](https://user-images.githubusercontent.com/69513270/188610759-6bdb3f01-59df-48b2-a8f8-22590ea9aaa2.jpg)
