# travel-distance-
Distance perception


Experimental Scene
The experimental world spans over 60 m scene depths. We placed a visible ground at eye height (1.60 m). Its appearance could either be structured (gravel) or unstructured (stripes in the motion direction). The gravel ground provides independent optic flow, while the stripes ground neither conveys any structure nor optic flow. 



Point-light walkers
We apply point-light walkers to operationalize human motion. These walkers originated from the motion-tracking data of a single walking human (de Lussanet et al., 2008). Each walker consists of 12 points corresponding to the ankles of a human body (knee, hip, hands, elbow, and shoulder joints). We create a crowd of 30 colored walkers. Each walker starts individually with a random selection starting position in the gait cycle. The group appears collectively as static, approaching or leaving the observer. Because point-light walkers are ambiguous in their facing direction when static, we only show static walkers facing the observer (Vanrie et al., 2004). 

Articulation speed
In real-life scenarios, humans differ in their translation, and thus, articulation speed (Masselink & Lappe, 2015). To keep the scene close to reality, we manipulate the articulation and translation speed of the walkers. The original motion-tracking data have a matching translation speed of 0.013 (0.6m/s.). By linear interpolation (see Matlab Skript extrapolatewalker.m), we create two more motion files with either 0.8 (slower) or 1.2 times (faster) the original articulation speed. Translation speed is adjusted accordingly. The three different articulation and translation speeds are divided equally among the 30 point-light walkers. The average walker speed remains constant at 0.013 at any trial. Randomized position in depth combined with a randomized starting position in the gait cycle let the crowd appear naturally.

Walker position
The walkers' positions are uniformly sampled in the frustum. We limit their position in depth to 26 m maximum so that walkers appear at an adequate sight. This limited in-depth position is beneficial for leaving crowds combined with slow observer speeds. When walkers disappear from the frustum, we replace them at 23 m in depth and correct for the movement speed of the observer.
To avoid collisions with static or approaching walkers, we place the walkers 1.5 m each left and right past the observer. Such a replacement creates a kind of tunnel to form through the crowd. Shortly before the end of the trial (maximum 600 frames left), walkers disappearing from the frustum can be placed within the tunnel without any risk of collision. This setting does not reveal any information about travel distance or travel velocity. But it makes the scene look realistic. Leaving crowds are located without such replacements within the frustum. 


Self-motion simulation
We simulate observers' forwarding self-motion towards a crowd of point-light walkers. Travel distances are chosen by Lappe et al. (2007): 4.00 m, 5.66 m, 8.00 m, 11.31 m, 16.00 m, and 22.63 m. All distances are traveled at 0.013, equal to the average translation speed of the crowd. In addition, short distances (4.00 m, 5.66 m, 8.00 m) are simulated more slowly at 0.0104, which is half the crowd's average speed. For long distances (11.31 m, 16.00 m, 22.63 m), we choose a simulation speed of 0.0154, or 1.5 faster than the crowd. 



Conditions
We combine three walker conditions (approaching vs. leaving vs. static), two ground conditions (gravel vs. stripes) with six traveled distances (4.00 m, 5.66 m, 8.00 m, 11.31 m, 16.00 m, 22.63 m), and two different self-motion speeds (equally fast as the walkers vs. unequally fast as the walkers). This combination of variables results in 72 trials. We repeat the stimulus combinations five times giving 360 in total. 



Procedure
Participants' task is to reproduce the traveled distance by placing a point-light walker on a blue line from a red starting line (at 2.624 m) as far as they went before ('adjust-to-target'-paradigm; Lappe & Frenz, 2009). Moving the walker in-depth immediately rescales it according to its position in depth. This rescaling should help participants receive a better depth impression, thus, increasing estimation accuracy. Depending on travel distance and velocity, a trial lasts between 5 and 28 seconds. 
To avoid fatigue effects we divide the experiment into two sessions on two days. Trials are blocked according to the ground type (gravel vs stripes). We assigned participants alternatingly to start their session with either the gravel or stripes ground type. 
