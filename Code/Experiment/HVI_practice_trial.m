function HVI_practice_trial()
clear; clc;

% This practice session consists of 8 trials
% The goal is to ensure subjects have seen every orientation the same
% number of times


%%
%------- EXPERIMENT SETTINGS -------
% General screen settings
bgcolor              = 128;                   % set background color to be a certain grey
fixation_color       = [200 0 0];             % bright red
delay_fixation       = [0 0 153];             % dark blue; was [0 200 0]-neon green
fixation_size        = [0 0 7 7];             % size of the red dot
textSize             = 24;                    % was 20
screen_ppi           = 264;                   % 128 for macbook air; 264 for ipad
screenId             = 2;                     % 0-macbook windows screen; 2-ipad screen

% Stimuli
orientations         = [90 -60 -45 -30 0 30 45 60];
lineWidth            = 2;                     % line width for the stimuli (for 'DrawLine')
lineColor            = 250;                   % white
secondLine           = 3;                     % second lines are always 3 cm long

% Trial procedure
displayTime          = 0.1;                   % display time for both stimuli
delayTime            = 1;
pauseTime            = 0.1;                   % display time for blank screens
thinkTime            = 0.2;                   % time for subjects to decide which line is longer before they can respond

% Session procedure
num_orien            = 8;                    % Total number of conditions for each line(8)
NCND                 = 8;
length_vector        = linspace(2, 4, 8);
random_vector        = randperm(NCND);
shuffled_length      = length_vector(random_vector)';
%-----------------------------------

% set rand state for this run
randSeed = sum(100*clock);
rng(randSeed);

% obtain subject info & session info
subjectID = [];

psyinit = []; % PSYBAYES initialization structure
% Define range for stimulus and for parameters of the psychometric function
psyinit.range.x = [2 4];
psyinit.range.mu = [2,4];
psyinit.range.sigma = [0.05,1];
psyinit.range.lambda = [0,0.2];

% check if the subject's info has been entered
while isempty(subjectID)
    subjectID = input('Subject initials: ','s');
end


fileOfCurrentSession = ['Practice_trial/' upper(subjectID) '.mat'];
%%
% open screen
HideCursor;
Screen('Preference', 'SkipSyncTests', 0);
[windowPtr,rect] = Screen('OpenWindow',screenId,bgcolor); % windowPtr = 10; rect = [0 0 1024 768]
Screen('BlendFunction', windowPtr,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');
Screen('fillRect',windowPtr,bgcolor);   % set background color to be a certain grey
Screen('TextSize',windowPtr,textSize);
instructionText = [
    '\n'...
    '\n'...
    '\n'...
    '\n'...
    '\n'...
    '\n'...
    '\n'...
    'This is a practice session.\n'...
    '\n'...
    '\n'...
    '\n'...
    '\n'...
    '\n'...
    '\n'...
    'When you are ready, press any key to start.\n'...
    '\n'...
    '\n'...
    '\n'...
    '\n'];

Screen('TextStyle', windowPtr, (1));
DrawFormattedText(windowPtr,instructionText,'center','center',[0 0 0]);
Screen('flip',windowPtr);
KbWait([], 2);

%-%-%-%-%-%-%-%-
%- INITIALIZE %-
%-%-%-%-%-%-%-%-

AssertOpenGL;                % check whether Psychtoolbox is working properly with "Screen()" functions
KbName('UnifyKeyNames');     % "esc" is "27"
KbCheck;

% screen info
[mx, my] = RectCenter(rect); % [mx my] = [1024 768](ipad)
w = rect(3);
h = rect(4); % [w h] = [1440 900](macbook air 13'); [w h] = [2048 1536](ipad);
screen_ppc = screen_ppi * 0.39370; % converted to cm %103.9368pixels/cm(ipad)

% r = []; %no response for first trials
reaction_vector = [];
response_vector = [];

orien_matrix = [orientations(randperm(num_orien))' orientations(randperm(num_orien))']; % Randomly permute order of conditions in each block


%-%-%-%-%-%-%-%-%-%-%-%-%
%- LOOP THROUGH TRIALS %-
%-%-%-%-%-%-%-%-%-%-%-%-%

for c = 1:NCND
    
    firstLine = shuffled_length(c);
    %randomly pick firstO and secondO from 1 of the 8 orientations
    %pick them independently
    firstO = orien_matrix(c,1);
    secondO = orien_matrix(c,2);
    
    
    % SCREEN 1: FIXATION
    Screen('FillRect',windowPtr, bgcolor);
    dot = CenterRectOnPoint(fixation_size, mx, my); % decides size and place of the fixation circle; all further 'FillOval' depends on this statement[512 384]
    Screen('FillOval',windowPtr, fixation_color, dot);
    Screen('Flip',windowPtr);
    pause(delayTime);
    
    
    % to make sure the disappearance of fixation point and appearance of stimulus do not look simultaneous
    Screen('FillRect',windowPtr, bgcolor);
    Screen('Flip',windowPtr);
    pause(pauseTime);
    
    
    % SCREEN 2: STIMULUS
    Screen('FillRect',windowPtr, bgcolor);
    screenLength1 = firstLine * screen_ppc / 2;
    x_center_px = w/2;
    y_center_px = h/2;
    add_x = cosd(firstO) * screenLength1;
    add_y = sind(firstO) * screenLength1;
    
    
    % show stimulus
    Screen('DrawLines', windowPtr, [x_center_px + add_x, x_center_px - add_x; y_center_px + add_y, y_center_px - add_y], lineWidth, lineColor, [], 2);
    Screen('Flip',windowPtr);
    pause(displayTime);
    
    
    
    % to make sure the dissppearance of fixation point and appearance of stimulus do not look simultaneous
    Screen('FillRect',windowPtr, bgcolor);
    Screen('Flip',windowPtr);
    pause(pauseTime);
    
    
    % SCREEN 3: DELAY
    Screen('FillRect',windowPtr, bgcolor);
    Screen('FillOval',windowPtr, fixation_color, dot);
    Screen('Flip',windowPtr);
    pause(delayTime);
    
    
    % to make sure the dissppearance of fixation point and appearance of stimulus do not look simultaneous
    Screen('FillRect',windowPtr, bgcolor);
    Screen('Flip',windowPtr);
    pause(pauseTime);
    
    
    % SCREEN 4: STIMULUS
    Screen('FillRect',windowPtr,bgcolor);
    screenLength2 = secondLine * screen_ppc / 2;
    add_x = cosd(secondO) * screenLength2;
    add_y = sind(secondO) * screenLength2;
    
    
    %show stimulus
    
    Screen('DrawLines', windowPtr, [x_center_px + add_x, x_center_px - add_x; y_center_px + add_y, y_center_px - add_y], lineWidth, lineColor, [], 2);
    Screen('Flip',windowPtr);
    pause(displayTime);
    
    
    % to make sure the dissppearance of fixation point and appearance of stimulus do not look simultaneous
    Screen('FillRect',windowPtr, bgcolor);
    Screen('Flip',windowPtr);
    pause(pauseTime);
    
    % SCREEN 5: RESPONSE
    Screen('FillRect',windowPtr, bgcolor);
    Screen('FillOval',windowPtr, delay_fixation, dot);
    Screen('Flip',windowPtr);
    
    
    ListenChar(0); % disable keyboard
    pause(thinkTime); % allow subjects 0.3 second to think
    ListenChar(1); % ennable keyboard
    
    tic;
    keyCode = zeros(1,256);
    % 37="left arrow",39="right arrow", 27="esc", 100="Numpad 4", 102="Numpad 6"
    while ~any([keyCode(37), keyCode(39), keyCode(27),keyCode(100),keyCode(102)])
        [~, ~,keyCode] = KbCheck; % wait for subject to press "left arrow", "right arrow" or "esc"
    end
    reactionTime = toc;
    
    if keyCode(37) || keyCode(100)
        r = 1;
    elseif keyCode(39) || keyCode(102)
        r = 2;
    end
    
    % check if ESC is pressed
    if keyCode(27) % check if ESC key is pressed
        Screen('closeall');
        error('Program aborted');
    end
    
    reaction_vector = [reaction_vector; reactionTime];
    response_vector = [response_vector; r];
end


Screen('fillRect',windowPtr,128);
endText = 'You have finished the practice trials.';
DrawFormattedText(windowPtr,endText,'center','center');
Screen('flip',windowPtr);
KbWait([], 2);
Screen('closeall');


% This operation cleans up temporary variables from POST to clear space in
% memory
display(sprintf('Saving to file...\n'));
output = [shuffled_length orien_matrix response_vector reaction_vector];
save(fileOfCurrentSession, 'output');
display('Completed.');

end