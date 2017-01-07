function HVI_experiment()
clear; clc;  
% Horizontal-Vertical Illusion Experiment
% This experiment explores whether human perceive the length of
% straight lines differently with different orientations

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
% subjectDistance    = 40;                    % distance between observer and screen (in cm)

% Stimuli
orientations         = [90 -60 -45 -30 0 30 45 60];
lineWidth            = 2;                     % line width for the stimuli (for 'DrawLine')
lineColor            = 250;                   % white
secondLine           = 3;                     % second lines are always 3 cm long

% Trial procedure
displayTime          = 0.1;                   % display time for both stimuli
delayTime            = 1;
breakTime            = 30;
pauseTime            = 0.1;                   % display time for blank screens
thinkTime            = 0.2;                   % time for subjects to decide which line is longer before they can respond
instructionTime      = 10;

% Session procedure
NCND                 = 64;                    % Total number of conditions(8 orien * 8 orien)
nRepPerBlock         = 2;
nBlocksPerSession    = 5;
%-----------------------------------

% set rand state for this run
randSeed = sum(100*clock);
rng(randSeed);

% obtain subject info & session info
run_type    = [];
subjectID   = [];
session_num = [];
psyinit     = []; % PSYBAYES initialization structure
% Define range for stimulus and for parameters of the psychometric function
psyinit.range.x      = [2,    4];
psyinit.range.mu     = [2,    4];
psyinit.range.sigma  = [0.05, 1.5];
psyinit.range.lambda = [0,    0.2];

method = 'ent';     % Minimize the expected posterior entropy
vars = [1 0 0];     % Minimize posterior entropy of the mean only
plotflag = 0;       % Plot visualization (should be off in the experiment)
    
% -1:debug run;  0:experimenter run;  1:subject run
while isempty(run_type) || ~(any(run_type==[-1,0,1]))
    run_type = input('Run type: ');
end

% check if the subject's info has been entered
while isempty(subjectID)
    subjectID = input('Subject initials: ','s');
end

while isempty(session_num) || session_num < 1 || session_num > 5
    session_num = input('Number of session: ');
end


if run_type == -1 || run_type == 0
    NCND = 1;
    breakTime = 0;
end

if ~exist(['Experiment_condition/' upper(subjectID)],'file')
    mkdir('Experiment_condition', upper(subjectID));
end


fileOfLastSession = ['./Experiment_condition/' upper(subjectID) '/' upper(subjectID) '_' num2str(session_num-1) '.mat'];
fileOfCurrentSession = ['./Experiment_condition/' upper(subjectID) '/' upper(subjectID) '_' num2str(session_num) '.mat'];
%%
% START SCREEN
HideCursor;
Screen('Preference', 'SkipSyncTests',0);
%set(0,'units','piexels');
%get(0,'screensize'); % get pixel information of macbook air
[windowPtr,rect] = Screen('OpenWindow',screenId,bgcolor); % windowPtr = 10; rect = [0 0 1024 768]
Screen('BlendFunction', windowPtr,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');

% show start screen
Screen('fillRect',windowPtr,bgcolor);   % set background color to be a certain grey
Screen('TextSize',windowPtr,textSize);  % set text's size

% all the text will be shown in white
instructionText = [
    '\n'...
    '\n'...
    '\n'...
    'Please wait. Initializing...\n'...
    '\n'...
    '\n'...
    '\n'];

Screen('TextStyle', windowPtr, (1));
DrawFormattedText(windowPtr,instructionText,'center','center',[0 0 0]);
Screen('flip',windowPtr);

if session_num == 1
    random_vector = linspace(2,4,61);
    % 1st session: initialize the posterior for all conditions
    for iCnd = 1:NCND; post{iCnd} = psyinit; end
    for iCnd = 1:NCND
        [x(iCnd), post{iCnd}] = psybayes(psyinit, method, vars, [], [], [], plotflag);
        % overwrite initial x-values to pseudorandom numbers from [2,4]
        x(iCnd) = random_vector(ceil(rand(1)*length(random_vector)));
    end
else
    % From the second session onwards you should load POST from the file of
    % the subject's previous session
    if exist(fileOfLastSession, 'file')
        load(fileOfLastSession, 'post');
        for iCnd = 1:NCND
        [x(iCnd), post{iCnd}] = psybayes(post{iCnd}, method, vars, [], [], [], plotflag);
        end
    else
        Screen('closeall');
        error([fileOfLastSession,' not found']);
    end
end

% show start screen
Screen('fillRect',windowPtr,bgcolor);   % set background color to be a certain grey
Screen('TextSize',windowPtr,textSize);  % set text's size

% all the text will be shown in white
instructionText = [
    '\n'...
    '\n'...
    '\n'...
    '\n'...
    '\n'...
    '\n'...
    '\n'...
    'Today, you will be doing ' num2str(nBlocksPerSession) ' blocks of trials.\n'...
    '\n'...
    'On each trial, you will see two lines, one after the other.\n'...
    '\n'...
    '\n'...
    'The first line may have\n'...
    '\n'...
    'different lengths from trial to trial,\n'...
    '\n'...
    'but the second line will always have the same length.\n'...
    '\n'...
    'Your job is to judge which line looks longer on each trial.\n'...
    '\n'...
    '\n'...
    'Press the "1st" key if the 1st line looks longer;\n'...
    '\n'...
    'Press the "2nd" key if the 2nd line looks longer.\n'...
    '\n'...
    '\n'...
    '\n'...
    'The lines may have different angles from trial to trial,\n'...
    '\n'...
    'but angle has nothing to do with length.\n'...
    '\n'...
    '\n'...
    'After each block, you will have a break.\n'...
    '\n'...
    '\n'...
    '\n'...
    'When you are ready,\n'...
    '\n'...
    'Press any key to start the experiment.\n'];

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
[mx, my] = RectCenter(rect);
w = rect(3);
h = rect(4);
screen_ppc = screen_ppi * 0.39370;

r = []; %no response for first trials
reactionTime = [];


for iBlock = 1:nBlocksPerSession
    for iRep = 1:nRepPerBlock
        cndVec = randperm(NCND); % Randomly permute order of conditions in each block
        
        %-%-%-%-%-%-%-%-%-%-%-%-%
        %- LOOP THROUGH TRIALS %-
        %-%-%-%-%-%-%-%-%-%-%-%-%
        
        for iCnd = 1:NCND
            c = cndVec(iCnd);   % Condition c in the current trial
          
            firstLine = x(c);
            
            %find firstO and secondO from the # of condition
            [quotient, remainder] = quorem(sym(c), sym(length(orientations)));
            if remainder == 0
                firstO = orientations(end);  %last element in 'orientations'(60)
                secondO = orientations(quotient);
            else
                firstO= orientations(remainder);
                secondO = orientations(quotient + 1);
            end
            
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
            if run_type == -1
                Screen('DrawLines', windowPtr, [x_center_px + add_x, x_center_px - add_x; y_center_px + add_y, y_center_px - add_y], lineWidth, lineColor, [], 2);
                DrawFormattedText(windowPtr,num2str(firstLine),'center',(0.75*h),[0 0 0]);
                DrawFormattedText(windowPtr,num2str(firstO),'center',(0.8*h),[0 0 0]);
                Screen('Flip',windowPtr);
                KbWait([],2);
            else
                Screen('DrawLines', windowPtr, [x_center_px + add_x, x_center_px - add_x; y_center_px + add_y, y_center_px - add_y], lineWidth, lineColor, [], 2);
                Screen('Flip',windowPtr);
                pause(displayTime);
            end
            
            
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
            if run_type == -1
                Screen('DrawLines', windowPtr, [x_center_px + add_x, x_center_px - add_x; y_center_px + add_y, y_center_px - add_y], lineWidth, lineColor, [], 2);
                DrawFormattedText(windowPtr,num2str(secondLine),'center',(0.75*h),[0 0 0]);
                DrawFormattedText(windowPtr,num2str(secondO),'center',(0.8*h),[0 0 0]);
                Screen('Flip',windowPtr);
                KbWait([],2);
            else
                Screen('DrawLines', windowPtr, [x_center_px + add_x, x_center_px - add_x; y_center_px + add_y, y_center_px - add_y], lineWidth, lineColor, [], 2);
                Screen('Flip',windowPtr);
                pause(displayTime);
            end
            
            
            % to make sure the dissppearance of fixation point and appearance of stimulus do not look simultaneous
            Screen('FillRect',windowPtr, bgcolor);
            Screen('Flip',windowPtr);
            pause(pauseTime);
            
            % SCREEN 5: RESPONSE
            Screen('FillRect',windowPtr, bgcolor);
            Screen('FillOval',windowPtr, delay_fixation, dot);
            Screen('Flip',windowPtr);
            
            % allow subjects 0.2 second to think
            ListenChar(0); % disable keyboard
            pause(thinkTime);
            ListenChar(1); % enable keyboard
            
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
            
            % get length for first line for next trial
            [x(c), post{c}] = psybayes(post{c}, method, vars, x(c), r, reactionTime, plotflag);
            
            
            % check if ESC is pressed
            if keyCode(27) % check if ESC key is pressed
                Screen('closeall');
                error('Program aborted');
            end
        end
        
        % ---------------------MOTIVATIONAL COMMENT & BREAK--------------------
        % once a block is finished, the subject takes a break of minimum 30sec
        
        if iRep == 1
            if (iBlock == 1)
                Screen('TextSize',windowPtr,textSize);
                Screen('fillRect',windowPtr,bgcolor);
                motivationText = ['Congratulations, you are halfway through the first block!\n'...
                    '\n'...
                    '\n'...
                    'Press any key to continue'];
                DrawFormattedText(windowPtr,motivationText,'center','center');
                Screen('flip',windowPtr);
                pause(delayTime);
                KbWait([], 2);
            elseif (iBlock == 2)
                Screen('TextSize',windowPtr,textSize);
                Screen('fillRect',windowPtr,bgcolor);
                motivationText = ['You are halfway through the second block! Great job!\n'...
                    '\n'...
                    '\n'...
                    'Press any key to continue'];
                DrawFormattedText(windowPtr,motivationText,'center','center');
                Screen('flip',windowPtr);
                pause(delayTime);
                KbWait([], 2);
            elseif (iBlock == 3)
                Screen('TextSize',windowPtr,textSize);
                Screen('fillRect',windowPtr,bgcolor);
                motivationText = ['You are halfway through the third block! Excellent!\n'...
                    '\n'...
                    '\n'...
                    'Press any key to continue'];
                DrawFormattedText(windowPtr,motivationText,'center','center');
                Screen('flip',windowPtr);
                pause(delayTime);
                KbWait([], 2);
            elseif (iBlock == 4)
                Screen('TextSize',windowPtr,textSize);
                Screen('fillRect',windowPtr,bgcolor);
                motivationText = ['You are halfway through the fourth block! Keep it up!\n'...
                    '\n'...
                    '\n'...
                    'Press any key to continue'];
                DrawFormattedText(windowPtr,motivationText,'center','center');
                Screen('flip',windowPtr);
                pause(delayTime);
                KbWait([], 2);
            elseif (iBlock == 5)
                Screen('TextSize',windowPtr,textSize);
                Screen('fillRect',windowPtr,bgcolor);
                motivationText = ['You are halfway through the last block! Almost there!\n'...
                    '\n'...
                    '\n'...
                    'Press any key to continue'];
                DrawFormattedText(windowPtr,motivationText,'center','center');
                Screen('flip',windowPtr);
                pause(delayTime);
                KbWait([], 2);
            end
        end
    end
    
    if iBlock ~= nBlocksPerSession
        Screen('TextSize',windowPtr,textSize);
        breakStart = GetSecs;
        while ((GetSecs-breakStart) < breakTime)
            Screen('fillRect',windowPtr,bgcolor);
            totalBreak = GetSecs-breakStart; % while loop, totalBreak changes every second as GetSecs gets the current time
            breakText = ['Good job! You have finished ' num2str(iBlock) ' out of ' num2str(nBlocksPerSession) ' blocks.\n'...
                '\n'...
                'Please take a short break now.\n'...
                '\n'...
                '\n'...
                '\n'...
                '\n'...
                'Feel free to take off your eye patch and go outside of the room.\n'...
                '\n'...
                '\n'...
                '\n'...
                '\n'...
                '\n'...
                '\n'...
                '\n'...
                '\n'...
                'You can continue in ' num2str(ceil(breakTime-totalBreak)) ' seconds.\n'];
            DrawFormattedText(windowPtr,breakText,'center','center');
            Screen('flip',windowPtr);
        end
        
        % once 30s is up, the subject is prompted to press any key to resume the experiment
        Screen('fillRect',windowPtr,bgcolor);
        endBreakText = ['You have finished ' num2str(iBlock) ' out of ' num2str(nBlocksPerSession) ' blocks.\n'...
            '\n'...
            '\n'...
            'Press any key to continue.\n'];
        DrawFormattedText(windowPtr,endBreakText,'center','center');
        Screen('flip',windowPtr);
        KbWait([], 2);
        
        % remind subjects to put on the eye patch
        Screen('fillRect',windowPtr,bgcolor);
        endBreakText = ['Please make sure your eye patch is put on correctly\n'...
            '\n'...
            '\n'...
            '\n'...
            '\n'...
            '\n'...
            '\n'...
            '\n'...
            '\n'...
            'When you are ready,\n'...
            '\n'...
            'press any key to resume your session.\n'];
        DrawFormattedText(windowPtr,endBreakText,'center','center');
        Screen('flip',windowPtr);
        pause(delayTime);
        KbWait([], 2);
    end
end

Screen('fillRect',windowPtr,128);
endText = ['Congratulations! You have finished this session.\n'...
    '\n'...
    '\n'...
    '\n'...
    '\n'...
    '\n'...
    '\n'...
    '\n'...
    'Please let your experimenter know that\n'...
    '\n'...
    'you have completed this session.\n'...
    '\n'...
    '\n'...
    '\n'...
    'Thank you for your participation.'];
DrawFormattedText(windowPtr,endText,'center','center');
Screen('flip',windowPtr);
pause(instructionTime);
Screen('closeall');


% This operation cleans up temporary variables from POST to clear space in
% memory
display(sprintf('Saving to file...\n'));
% [x(c), post{c}] = psybayes(post{c}, method, vars, x(c), r, reactionTime, plotflag); %save response from last trial
for ii = 1:NCND
    [~,post{ii}, output{ii}] = psybayes(post{ii});
end
save(fileOfCurrentSession,'post','output','-v7.3');
display('Completed.');

end
