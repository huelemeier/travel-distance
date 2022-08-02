clear all;

addpath('functions')

rng('shuffle');

%% Please adjust the following lines per VP and block
ID = 99; % input('Enter subject ID '); %Input subject ID, this will also be the file name of the output
session = 3; %input('Enter session number '); %Input session number, this will also be the file name of the output
practice = 1;%input('Practice run [1] Experimental run [0] '); %input whether this is a practice run or not



%% Nothing more to adjust here about the walker type, the presentation of a ground, and the drawing of the true traveled distance.
walker_type = 1;%input walker type [0 = scrambled, walker] [1 = normal walker];
observer_translating = 1;%input('Observer translating [1] or static [0]? ');
gravel = [1];%Does a ground generally appear? 1 = yes, 0 = no. 
eye_height = 1.6;
show_true_distance = false; %show true traveled distance. 


travel_distance = [4, 5.66, 8, 11.31, 16, 22.63]; %in m 4, 5.66, 8, 11.31, 16, 22.63
travel_speed_rep = [1, 2]; % because speed should differ between distances, we need to classify, which type of speed we should pick.

facing = [0, 180]; %walker facing direction
d = 60;  %scene depth 



% GL data structure needed for all OpenGL demos:
global GL


% Is the script running in OpenGL Psychtoolbox? Abort, if not.
AssertOpenGL;

% Restrict KbCheck to checking of ESCAPE key:
KbName('UnifyKeynames');
% Screen('Preference','Verbosity',1);
Screen('Preference', 'SkipSyncTests', 0);



% Find the screen to use for display:
screenid=max(Screen('Screens'));
stereoMode = 0;
multiSample = 0;
sca
Screen('Preference', 'SkipSyncTests', 1);

%-----------
% Parameters
%-----------

numwalkers = 30; %number of walkers 

% depending on the session, change number of stimulus repitions
if session == 1 || session == 3
    k = 3;
elseif session == 2 || session == 4
    k = 2;
end

% recode the block number depending on the session
if session == 1 || session == 2
    block = 1;
elseif session == 3 || session == 4
    block = 2;
end

% the program changes the ground (gravel vs stripes) depending on the
% participant id and the block number. Particpants had two blocks with two
% sessions each. They either started with a gravel or stripes ground. The
% variable ground type is blocked:
s = (-1)^(ID+block);
if s == -1
    groundtype = 2;
else
    groundtype = 1;
end


%set up conditions and trial sequence // there are 36 stimulus combinations
%in total
independent_variable_sets = {[1 0], [facing], [travel_distance], [travel_speed_rep], [gravel]}; % static vs moving - facing - target distance - travel distance - limb articulation - facing
[independent_variable_1 independent_variable_2 independent_variable_3 independent_variable_4 independent_variable_5] = ndgrid(independent_variable_sets{:});
conditions = [independent_variable_1(:) independent_variable_2(:) independent_variable_3(:) independent_variable_4(:) independent_variable_5(:)];
conditions(conditions(:, 1)== 0 & conditions(:,2) == 180, :) = [] ; % delete static walkers with 180 facing


trials = repmat(conditions,k,1); % repeat stimulus combinations k-times
trials = trials(randperm(length(trials)),:); %randomize stimulus presentation

% set up practice trials
if practice
    trials = conditions([6, 8, 9, 10, 14, 22, 26,27 ,30 ,32], :); % each practice blocks conveys the same 10 stimuli out of 36 possible stimulus combinations
    trials = trials(randperm(length(trials)),:);% randomize stimulus presentation.
end

% Setup Psychtoolbox for OpenGL 3D rendering support and initialize the
% mogl OpenGL for Matlab wrapper:
InitializeMatlabOpenGL;

PsychImaging('PrepareConfiguration');
% Open a double-buffered full-screen window on the main displays screen.
[win, winRect] = PsychImaging('OpenWindow', screenid, 0, [0 0 800 600], [], [], stereoMode, multiSample); % create a second window (size 800 x 600) displaying the experiemt
[win_xcenter, win_ycenter] = RectCenter(winRect);
xwidth=RectWidth(winRect);
yheight=RectHeight(winRect);

screen_height=198; %physical height of display in cm
screen_width=248; %physical width of display in cm
screen_distance=100; %physical viewing distance in cm
screen_distance_in_pixels=xwidth/screen_width*screen_distance; %physical viewing distance in pixel

% Measure the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', win);

HideCursor;
Priority(MaxPriority(win));

% Setup the OpenGL rendering context of the onscreen window for use by
% OpenGL wrapper. After this command, all following OpenGL commands will
% draw into the onscreen window 'win':
Screen('BeginOpenGL', win);

% Set viewport properly:
glViewport(0, 0, xwidth, yheight);

% Setup default drawing color to yellow (R,G,B)=(1,1,0). This color only
% gets used when lighting is disabled - if you comment out the call to
% glEnable(GL.LIGHTING).
glColor3f(1,1,0);

% Setup OpenGL local lighting model: The lighting model supported by
% OpenGL is a local Phong model with Gouraud shading.

% Enable the first local light source GL.LIGHT_0. Each OpenGL
% implementation is guaranteed to support at least 8 light sources,
% GL.LIGHT0, ..., GL.LIGHT7
glEnable(GL.LIGHT0);

% Enable alpha-blending for smooth dot drawing:
glEnable(GL.BLEND);
glBlendFunc(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA);
glEnable(GL.DEPTH_TEST);

% Set projection matrix: This defines a perspective projection,
% corresponding to the model of a pin-hole camera - which is a good
% approximation of the human eye and of standard real world cameras --
% well, the best aproximation one can do with 3 lines of code ;-)
glMatrixMode(GL.PROJECTION);
glLoadIdentity;

% Field of view = 2*atan(H/2N) where H is monitor height and N is viewing distance. Objects closer than
% 0.1 distance units or farther away than 50 distance units get clipped
% away, aspect ratio is adapted to the monitors aspect ratio:
gluPerspective(89, xwidth/yheight, 0.5, d); 


% Setup modelview matrix: This defines the position, orientation and
% looking direction of the virtual camera:
glMatrixMode(GL.MODELVIEW);
glLoadIdentity;

% Our point lightsource is at position (x,y,z) == (1,2,3)...
glLightfv(GL.LIGHT0,GL.POSITION,[ 1 2 3 0 ]);

% Set background clear color to 'black' (R,G,B,A)=(0,0,0,0):
glClearColor(0,0,0,0);

% Clear out the backbuffer: This also cleans the depth-buffer for
% proper occlusion handling: You need to glClear the depth buffer whenever
% you redraw your scene, e.g., in an animation loop. Otherwise occlusion
% handling will screw up in funny ways...
glClear(GL.DEPTH_BUFFER_BIT);

% Finish OpenGL rendering into PTB window. This will switch back to the
% standard 2D drawing functions of Screen and will check for OpenGL errors.

vprt1 = glGetIntegerv(GL.VIEWPORT);
Screen('EndOpenGL', win);

% Show rendered image at next vertical retrace:
Screen('Flip', win);

fps=Screen('FrameRate', win);   %use PTB framerate if its ok. 
if fps == 0
    flip_count = 0;                 %rough estimate of the frame rate per second
    timerID=tic;                    %I did this because for some reson the PTB estimate wasn't working
    while (toc(timerID) < 1)        %pretty sure this is due to the mac LCD monitors
        Screen('Flip',win);
        flip_count=flip_count+1;
    end
    frame_rate_estimate=flip_count;
    fps = frame_rate_estimate;
end

% initiate observer translation with 0 velocity
if observer_translating==0
    tspeed=0;
end


%first stuff the observer sees when they start the experiment
[~, ~, buttons1]=GetMouse(screenid);
Screen('TextSize',win, 20);
white = WhiteIndex(win);

while ~any(buttons1)
    Screen('DrawText',win, 'Click the mouse to begin the experiment.',win_xcenter-200,win_ycenter,white);
    Screen('DrawingFinished', win);
    Screen('Flip', win);
    [~, ~, buttons1]=GetMouse(screenid);
end



% start trial loop
for trial = 1:length(trials)
    


    % set up conditions for this trial
    translating                 = trials(trial,1);
    articulating                = trials(trial,1);
    mean_walker_facing          = trials(trial,2);
    travel_distance             = trials(trial,3);
    travel_speed_rep            = trials(trial,4);
    gravel                      = trials(trial,5);
    
 

    % Each distance was run with at least two different speeds
    travel_speed = 0.793; % walker speed is 0.013 (fps). 

    if travel_speed_rep == 1
        travel_speed = 0.793;
    elseif travel_speed_rep == 2 & travel_distance < 10
        travel_speed = 0.793*0.5;
    elseif travel_speed_rep == 2 & travel_distance > 10
        travel_speed = 0.793*1.5;
    end
    
    travel_duration = travel_distance/travel_speed; %travel_speed = [0.5, 1, 2, 4]; %m/s
    tspeed = (travel_distance/travel_duration)/fps;  %calculate speed with which the observer translates through the environment from distance and duration
    nframes = travel_duration*fps; %calculate number of frames from duration
    numsecs = nframes*ifi;
    walker_facing = mean_walker_facing * ones(1,numwalkers); % all walkers have the same walker facing


    %% set up walker
    % the stimulus presents three articulation speeds with matching
    % translation speed. 
    % Matlab reads in walker data
    origin_directory = pwd;
    FID = fopen('sample_walker3.txt');    %open walker data file
    sample_walker_1 = fscanf(FID,'%f');      %read into matlab
    fclose(FID);
    sample_walker_1=reshape(sample_walker_1,3,[]).*0.00001;  %order and scale walker array
    
    % load in extrapolated data:
    FID = fopen('sample_walker_exp_0.8.txt');    %open walker data file
    sample_walker_0_8 = fscanf(FID,'%f');      %read into matlab
    fclose(FID);
    sample_walker_0_8=reshape(sample_walker_0_8,3,[]);  %order and scale walker array
    
    FID = fopen('sample_walker_exp_1.2.txt');    %open walker data file
    sample_walker_1_2 = fscanf(FID,'%f');      %read into matlab
    fclose(FID);
    sample_walker_1_2=reshape(sample_walker_1_2,3,[]);  %order and scale walker array

    
    % assign articulation speeds to the crowd
    artspeed = ones(1,numwalkers)*0.013;
    artspeed(1:10) = 0.0154;
    artspeed(11:20) = 0.0104;
    artspeed = artspeed(randperm(length(artspeed)));
    

    % set articulation speed and matching walker file
    for i=1:length(artspeed)

        if artspeed(i) == 0.013
            walker_array = sample_walker_1; % normal limb articulation
        elseif artspeed(i) == 0.0104
            walker_array = sample_walker_0_8; % slower limb articulation
        elseif artspeed(i) == 0.0154
            walker_array = sample_walker_1_2; % faster limb articulation
        end
    
    end

        
    %% set walker stuff

    if walker_type == 0
        walker_array = genscramwalker(walker_array,16);
    end

    clear xi
    %randomly select starting phase
    numorder=(1:16:length(walker_array));
    xi(1:numwalkers)=numorder(randi([1 length(numorder)],1,numwalkers));


    %% set walker facing and translation   

    % initialize walker translation state
    translate_walker= zeros(1,numwalkers);

    % set translation speed
    if translating 
        translation_speed =  artspeed; %0.013;%0.013506;  
    else
        translation_speed = 0;  
    end

    %generate walker random starting positions
    [walkerX,walkerY,walkerZ] = CreateUniformDotsIn3DFrustum(numwalkers,56,xwidth/yheight,0.5,d/2-4,1.2); %generate walker positions

    % rearrange walkers so that they do not run into the
    % participant:
    if mean_walker_facing == 0
        walkerX(walkerX < 1.5 & walkerX > 0) = walkerX(walkerX < 1.5 & walkerX > 0) + 1.5;
        walkerX(walkerX < 0 & walkerX > -1.5) =   walkerX(walkerX < 0 & walkerX > -1.5) - 1.5;
    end

    %give each walker a random color
    walkerCol = rand(3,numwalkers);


    %% set up ground plane

    %choose the correct ground type
    if groundtype == 1
        myimg = imread('gravel.rgb.tiff'); % gravel: provides optic flow
    elseif groundtype == 2
        myimg = imread('streifen.rgb.tiff'); %stripes: provides no optic flow
    end

    mytex = Screen('MakeTexture', win, myimg, [], 1);

    % Retrieve OpenGL handles to the PTB texture. These are needed to use the texture
    % from "normal" OpenGL code:
    [gltex, gltextarget] = Screen('GetOpenGLTexture', win, mytex);
    


    %% set heading stuff
    Screen('BeginOpenGL',win)
    glLoadIdentity
    viewport=glGetIntegerv(GL.VIEWPORT); %viewport
    modelview=glGetDoublev(GL.MODELVIEW_MATRIX); %modelview matrix
    projection=glGetDoublev(GL.PROJECTION_MATRIX); %projection matrix

    heading_deg = 0;
    heading_world = -tand(heading_deg)*d;

    translate_observer=0; %start observer motion speed at zero

    % shift crowd to center on screen
    walkerX = walkerX - tand(heading_deg)*8;

    %% view frustum for culling used later

    glLoadIdentity

    glRotatef(-heading_deg,0,1,0)
    proj=glGetFloatv(GL.PROJECTION_MATRIX);
    modl=glGetFloatv(GL.MODELVIEW_MATRIX);
    modl=reshape(modl,4,4);
    proj=reshape(proj,4,4);
    frustum=getFrustum(proj,modl);

    Screen('EndOpenGL', win)

    %% Animation loop within trial loop

    tic %starting the timer to measure the acutal presentation time.

    for i = 1:nframes
    framesend = nframes-i; % measure how many frames are still left. This number is used to replace approaching walkers in a way that they do not collide with participants. At the end of each trial, walkers can be palced within the walking corridor of the participant

        %abort program early
        exitkey=KbCheck;
        if exitkey
%             clear all
            return
        end

        Screen('BeginOpenGL',win);
        glClear(GL.DEPTH_BUFFER_BIT)
        glLoadIdentity

        gluLookAt(0,0,0,heading_world,0,-d,0,1,0); %set camera to look without rotating.
        glTranslatef(0,0,translate_observer) %translate scene

        % draw the ground
        if gravel == 1
            %draw texture on the ground
            glColor3f(1.0,1.0,1.0)

            % Enable texture mapping for this type of textures...
            glEnable(gltextarget);

            % Bind our texture, so it gets applied to all following objects:
            glBindTexture(gltextarget, gltex);

            % Clamping behaviour shall be a cyclic repeat:
            glTexParameteri(gltextarget, GL.TEXTURE_WRAP_S, GL.REPEAT);
            glTexParameteri(gltextarget, GL.TEXTURE_WRAP_T, GL.REPEAT);

            % Enable mip-mapping and generate the mipmap pyramid:
            glTexParameteri(gltextarget, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_LINEAR);
            glTexParameteri(gltextarget, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
            glGenerateMipmapEXT(GL.TEXTURE_2D);


            glBegin(GL.QUADS)
            glTexCoord2f(0.0, 0.0); glVertex3f(-100, -eye_height, -200);
            glTexCoord2f(0.0, 50.0); glVertex3f(-100, -eye_height, 0);
            glTexCoord2f(50.0, 50.0); glVertex3f(+100, -eye_height, 0);
            glTexCoord2f(50.0, 0.0); glVertex3f(+100, -eye_height, -200);
            glEnd();

            glDisable(GL.TEXTURE_2D); %disable texturing so that the colouring of the walker happens independently of the colouring of the texture

        end


        %% PLW code // animate the walkers

        for walker = 1:numwalkers %cycle through each walker. at this stage i draw each walker singularly.

            if xi(walker)+16+12 > length(walker_array) % <--this is the size of the scrambled walker data file
                xi(walker)=1;
            end
          

            %get walker array for frame
            xyzmatrix = walker_array(:,xi(walker):xi(walker)+11).*repmat([1;1;1],1,12);
            
            r_mat = [cosd(walker_facing(walker)), 0, -sind(walker_facing(walker));...
                    0,                                   1, 0;...
                    sind(walker_facing(walker)),  0, cosd(walker_facing(walker))];

            if articulating % innitiate articulation
                xi(:,walker) = xi(:,walker) + 16;
            end
            
            
            %% frustum culling to reposition lost walkers

            %get point
            p = [walkerX(walker),walkerY(walker),walkerZ(walker)+translate_observer]+[0,0,translate_walker(walker)]*r_mat;

            walkerDist = -p(3);

            %normalize
            p=p/norm(p);
            
            %test and cull
            if  frustum(1,1)*p(1) + frustum(1,2)*p(2) + frustum(1,3)*p(3) + frustum(1,4) < 0 || frustum(5,1)*p(1) + frustum(5,2)*p(2) + frustum(5,3)*p(3) + frustum(5,4) < 0 || frustum(2,1)*p(1) + frustum(2,2)*p(2) + frustum(2,3)*p(3) + frustum(2,4) < 0

                walkerZ(walker)=-(d/2-7)-translate_observer; %compensate for moving in depth
                
                walkerDist = -walkerZ(walker);

                % replace approaching walkers if they are palced within the
                % walking corridor of the observer. When the trial is about
                % to finish, walkers can be placed within that corridor
                if walkerX(walker) < 3 & walkerX(walker) > 0 & travel_distance < 11 || (framesend < 600)
                    walkerX(walker) = walkerX(walker) - 1.5;
                elseif walkerX(walker) < 0 & walkerX(walker) > -3 & travel_distance < 11 || (framesend < 600)
                    walkerX(walker) = walkerX(walker) + 1.5;
                end


                translate_walker(walker)=0;

            end

          
            
            %% point drawing // draw each point of the point-light walkers

            %these variables set up some point drawing
            nrdots=size(xyzmatrix,2);
            nvc=size(xyzmatrix,1);


            %this bit of code was taken out of the moglDrawDots3D psychtoolbox function which is EXTREMELY inefficient. it is much quicker to just use the relevant openGL function to draw points
            glVertexPointer(nvc, GL.DOUBLE, 0, xyzmatrix);
            glEnableClientState(GL.VERTEX_ARRAY);

            glEnable(GL.POINT_SMOOTH); %enable anti-aliasing
            glHint(GL.POINT_SMOOTH_HINT, GL.DONT_CARE); %but it doesnt need to be that fancy. they are just white dots after all

            glPushMatrix
            glTranslatef(walkerX(walker),walkerY(walker),walkerZ(walker)); %move the points to the right location


            %do facing rotation and walking translation
            glRotatef(walker_facing(walker)-90,0,1,0);
            glTranslatef(translate_walker(walker),0,0); 
            if translating
                translate_walker(walker)=translate_walker(walker) + translation_speed(walker);
            end

            %inverted walkers are rotated. Facing direction needs to be
            %inverted. Otherwise, translating walkers appear as moon
            %walkers
%             if walker_type == 2
%                 glRotatef(180,0,0,1)
%                 glTranslatef(0,-1.4,0)
%             end



            % adapt point size to the walker's position in depth
            if walkerDist > 0
                pointSize = 2*((d/2)/walkerDist);
            
                glColor3f(walkerCol(1,walker),walkerCol(2,walker),walkerCol(3,walker))
                glPointSize(pointSize)
                glDrawArrays(GL.POINTS, 0, nrdots); %draw the points
            end
            
            glPopMatrix

        end

       
        % show true traveled distance as blue point:
        if show_true_distance
            distance_point = [0, -eye_height, -travel_distance-eye_height]';

            %these variables set up some point drawing
            nrdots=size(distance_point,2);
            nvc=size(distance_point,1);

            glClear(GL.DEPTH_BUFFER_BIT)

            %this bit of code was taken out of the moglDrawDots3D psychtoolbox function which is EXTREMELY inefficient. it is much quicker to just use the relevant openGL function to draw points
            glVertexPointer(nvc, GL.DOUBLE, 0, distance_point);
            glEnableClientState(GL.VERTEX_ARRAY);

            glEnable(GL.POINT_SMOOTH); %enable anti-aliasing
            glHint(GL.POINT_SMOOTH_HINT, GL.DONT_CARE); %but it doesnt need to be that fancy. they are just white dots after all

            glPushMatrix               

            glColor3f(0.12,0.1,0.78)
            glPointSize(12)
            glDrawArrays(GL.POINTS, 0, nrdots); %draw the points
            glPopMatrix
        end   
                
        Screen('EndOpenGL',win);

        translate_observer=translate_observer+tspeed; % update translated position

        Screen('Flip', win);

    end %end animation loop of the trial


    % time stemps to control for presentation delay
    timestemp = toc;
    diff = numsecs-timestemp;

    Screen('Flip',win);
    WaitSecs(0.5); 
    
    %% Collect response

    buttons = 0;
    SetMouse(win_xcenter,397);

    while ~buttons

        [mx, my, buttons]=GetMouse(screenid); %get x and y coordinates of the computer mouse
        move_line = (my-400)/400*40; %this line of code moves the estimation line depending on the mouse position
        line_in_depth = -1.54*eye_height-move_line; % position of the estimation line in world coordinates //  equals distance_point(3) 
        
        % calculate estimated distance in meters and eye_heights
        estimated_distance_m = (line_in_depth + eye_height)*(-1)
        
        % calculate the estimated error in meters //
        % negative values indicate underestimation
        estimation_error_m = estimated_distance_m - travel_distance;
        

        Screen('BeginOpenGL',win)
        glClear(GL.DEPTH_BUFFER_BIT)

        glMatrixMode(GL.MODELVIEW)
        glLoadIdentity

        %% draw the world (ground, starting line in red, and if necessary the true distance point) and draw the estimation line with walker:
        gluLookAt(0,0,0,heading_world,0,-d,0,1,0); %set camera to look without rotating. normally just use thi

        glTranslatef(0,0,0) %translate scene

        % draw the ground:
        if gravel == 1
            % texture on the ground
            glColor3f(1.0,1.0,1.0)

            % Enable texture mapping for this type of textures...
            glEnable(gltextarget);

            % Bind our texture, so it gets applied to all following objects:
            glBindTexture(gltextarget, gltex);

            % Clamping behaviour shall be a cyclic repeat:
            glTexParameteri(gltextarget, GL.TEXTURE_WRAP_S, GL.REPEAT);
            glTexParameteri(gltextarget, GL.TEXTURE_WRAP_T, GL.REPEAT);

            % Enable mip-mapping and generate the mipmap pyramid:
            glTexParameteri(gltextarget, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_LINEAR);
            glTexParameteri(gltextarget, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
            glGenerateMipmapEXT(GL.TEXTURE_2D);

            glBegin(GL.QUADS)
            glTexCoord2f(0.0, 0.0); glVertex3f(-100, -eye_height, -200);
            glTexCoord2f(0.0, 50.0); glVertex3f(-100, -eye_height, 0);
            glTexCoord2f(50.0, 50.0); glVertex3f(+100, -eye_height, 0);
            glTexCoord2f(50.0, 0.0); glVertex3f(+100, -eye_height, -200);
            glEnd();

            glDisable(GL.TEXTURE_2D); %disable texturing so that the colouring of the walker happens independently of the colouring of the texture
        end
 
        if show_true_distance
            distance_point = [0, -eye_height, -travel_distance-eye_height]';

            %these variables set up some point drawing
            nrdots=size(distance_point,2);
            nvc=size(distance_point,1);

            glClear(GL.DEPTH_BUFFER_BIT)

            %this bit of code was taken out of the moglDrawDots3D psychtoolbox function which is EXTREMELY inefficient. it is much quicker to just use the relevant openGL function to draw points
            glVertexPointer(nvc, GL.DOUBLE, 0, distance_point);
            glEnableClientState(GL.VERTEX_ARRAY);

            glEnable(GL.POINT_SMOOTH); %enable anti-aliasing
            glHint(GL.POINT_SMOOTH_HINT, GL.DONT_CARE); %but it doesnt need to be that fancy. they are just white dots after all

            glPushMatrix               

            glColor3f(0.12,0.1,0.78)
            glPointSize(12)
            glDrawArrays(GL.POINTS, 0, nrdots); %draw the points
            glPopMatrix
        end  
 
        glColor3f(1.0,0.0,0.0);
        glLineWidth(3);

        glBegin(GL.LINES);
        glVertex3f(-100, -eye_height+0.01, -1.54*eye_height);
        glVertex3f(+100, -eye_height+0.01, -1.54*eye_height);

        glColor3f(0.0,1.0,1.0);
        glVertex3f(-100, -eye_height+0.01, -1.54*eye_height-move_line);
        glVertex3f(+100, -eye_height+0.01, -1.54*eye_height-move_line);
        glEnd();


        %draw a walker and place it on the estimation line. The size of the
        %points adapt to their position in depth;

         for walker = 1

            %get walker array for frame
            xyzmatrix = walker_array(:,xi(walker):xi(walker)+11).*repmat([1;1;1],1,12); %motion sequence of articulating walker            
            
            if xi(walker)+16+12 > length(walker_array) % <--this is the size of the scrambled walker data file %das sorgt für die vielen frames übereinander bzw die artikulation.
                xi(walker)=1;
            end
            


            %% point drawing:
            %these variables set up some point drawing
            nrdots=size(xyzmatrix,2);
            nvc=size(xyzmatrix,1);
            
            glClear(GL.DEPTH_BUFFER_BIT)
            
            glVertexPointer(nvc, GL.DOUBLE, 0, xyzmatrix);
            glEnableClientState(GL.VERTEX_ARRAY);
            
            glEnable(GL.POINT_SMOOTH); %enable anti-aliasing
            glHint(GL.POINT_SMOOTH_HINT, GL.DONT_CARE); %but it doesnt need to be that fancy. they are just white dots after all
            
            glPushMatrix
            glTranslatef(0, walkerY(walker), -move_line-eye_height); %move the points to the x-centered location, with a depth of -6.5
            
            %do facing rotation
            %walker_facing = 0; %define walker facing for the still image.
            glRotatef(facing-90,0,1,0) %rotate the walker along the y-axis with the mouse 
           
            walkerDist = sqrt((move_line+eye_height)^2);%-walkerZ(walker);

            pointSize = 2*((d/2)/walkerDist);

            glColor3f(0.0,1.0,1.0)
            glPointSize(pointSize)
            glDrawArrays(GL.POINTS, 0, nrdots); %draw the points

            
            glPopMatrix
            
              
            
            
        end %end loop for drawing the walker

        
        Screen('EndOpenGL',win)
       
        %collect response:
        if any(buttons)
            estimation_error_m = estimated_distance_m - travel_distance;
            estimated_distance_m;
        end


        Screen('Flip',win);
        
    end



    Screen('Flip',win);
    WaitSecs(0.5);



    %output // write output file

    output(trial,1) = ID;
    output(trial,2) = session;
    output(trial,3) = trial;
    output(trial,4) = gravel; %1 = gravel, 0 = black ground
    output(trial,5) = translating;
    output(trial,6) = articulating;
    output(trial,7) = mean_walker_facing;
    output(trial,8) = my;
    output(trial,9) = mx;
    output(trial,10) = move_line;
    output(trial,11) = travel_distance; 
    output(trial,12) = travel_duration; %in seconds
    output(trial,13) = travel_speed; %in m/s
    output(trial,14) = tspeed; % in m/fps
    output(trial,15) = nframes; 
    output(trial,16) = estimated_distance_m;
    output(trial,17) = estimation_error_m;
    output(trial,18) = timestemp;
    output(trial,19) = numsecs;
    output(trial,20) = groundtype;
    output(trial,21) = block;



    if ~practice

        cd('data');
        dlmwrite([num2str(ID), '_',num2str(session), '_',num2str(groundtype), '_travel_distance_16.txt'],output,'\t');
        cd(origin_directory)

    end

end

%% Done. Close screen and exit:c
Screen('CloseAll');

