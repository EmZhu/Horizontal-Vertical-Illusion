function HVI_calibration()
% CALIBRATION--display a circle and a central dot to help positioning
% cardboard and chin rest 

bgcolor           = 255 ;             % set background color to be a certain grey
fixation_size     = [0 0 7 7];        % size of the fixation dot
fixation_color    = 255;              % color of the dot is white
circle_size       = [0 0 1280 1280];  % a circle with radius of 6cm; [0 0 605 605] for macbook air; [0 0 1250 1250] for ipad 
circle_color      = 0;                                        
screenId          = 2;                % 0-macbook windows screen; 2-ipad screen

HideCursor;
Screen('Preference', 'SkipSyncTests',2) 
[windowPtr,rect] = Screen('OpenWindow',screenId,bgcolor); % windowPtr = 10; rect = [0 0 1024 768]
[mx, my] = RectCenter(rect); 
Screen('BlendFunction', windowPtr,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA')

AssertOpenGL;% check whether Psychtoolbox is working properly with "Screen()" functions

% shows 
Screen('FillRect',windowPtr, bgcolor);
circle = CenterRectOnPoint(circle_size, mx, my); 
Screen('FillOval',windowPtr, circle_color, circle);
dot = CenterRectOnPoint(fixation_size, mx, my); 
Screen('FillOval',windowPtr, fixation_color, dot);
Screen('Flip',windowPtr);
KbWait([], 2);

% exit upon any keypress
Screen('closeall');
