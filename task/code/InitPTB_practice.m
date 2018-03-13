function [PTBParams, study, homepath] = InitPTB_practice(homepath)
% Function for initializing parameters at the beginning of a session
%
% homepath: Path name to scripts directory for the study
%
% Author: Cendri Hutcherson
% Modified by: Dani Cosme
% Last Modified: 10-06-2017

%% Housecleaning before the guests arrive
cd(homepath);
clear all; close all; Screen('CloseAll'); 
homepath = [pwd '/'];

%% Get study and subject info and whether MRI or behavioral session
ssnid = '1'; %removed user input: input('Session number (1-5):  ', 's');

% set prompt info and default answers
prompt={'Study code'; 'Subject number (3 digits)'; 'MRI session? (0 = no, 1 = yes)'};
name='Subject Info';
defAns={''; '999'; ''};
options.WindowStyle = 'normal';

% open dialog box
% To change the default font size, you need to edit this directly in the
% inputdlg function by typing: edit inputdlg.m
% TextInfo.FontSize = get(0,'FactoryUicontrolFontSize') -->
% TextInfo.FontSize = 14

answer=inputdlg(prompt,name,1,defAns,options);

% name variables from inputs
study=answer{1};
subjid=answer{2};
inMRI = str2double(answer{3});

%% Initialize PsychToolbox parameters and save in PTBParams struct
AssertOpenGL;
ListenChar(2); % don't print keypresses to screen
%Screen('Preference', 'SkipSyncTests', 1); % use if VBL fails; use this setting on the laptop
Screen('Preference', 'VisualDebugLevel',3);

HideCursor; %comment out for testing only

% Set screen number
%screenNum=max(Screen('Screens'));
screenNum=0;

% Set screen size and parameters
[w, rect] = Screen('OpenWindow',screenNum);
%[w, rect] = Screen('OpenWindow',screenNum, [], [0 0 960 600]); %DCos 2015.06.25, Use for debugging

ctr = [rect(3)/2, rect(4)/2]; 
ifi = Screen('GetFlipInterval', w);

% Save parameters in PTBParams structure
PTBParams.win = w;
PTBParams.rect = rect;
PTBParams.ctr = ctr;
PTBParams.white = WhiteIndex(w);
PTBParams.black = BlackIndex(w);
PTBParams.yellow = [240 189 0];
PTBParams.green = [142 166 4];
PTBParams.blue = [0 161 228];
PTBParams.teal = [77 161 169];
PTBParams.red = [252 3 8];
PTBParams.gray = (WhiteIndex(w) + BlackIndex(w))/2;
PTBParams.ifi = ifi;
PTBParams.homepath = homepath;
PTBParams.keys = initKeys(inMRI);
PTBParams.inMRI = inMRI;
PTBParams.subjid = subjid;
PTBParams.ssnid = ssnid;

% Flip screen
Screen(w,'TextSize',round(.2*ctr(2)));
Screen('TextFont',w,'Futura');
Screen('FillRect',w,PTBParams.black);

% Used to initialize mousetracking object, otherwise the first time
% this is called elsewhere it can take up to 300ms, throwing off timing
[tempx, tempy] = GetMouse(w);

WaitSecs(.5);
    
%% Seed random number generator 
% Note that different versions of Matlab allow/deprecate different random 
% number generators, so I've incorporated some flexibility here

[v, d] = version; % get Matlab version
if datenum(d) > datenum('April 8, 2011') % compare to first release of rng
    rng(GetSecs, 'twister')
else
    rand('twister',sum(100*clock));
end

