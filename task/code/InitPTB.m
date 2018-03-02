function [PTBParams, runNum, study, homepath] = InitPTB(homepath)
% function [subjid ssnid datafile PTBParams] = InitPTB(homepath)
% 
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

%% Get study and subject info 
% Check to make sure aren't about to overwrite duplicate session!
checksubjid = 1;
while checksubjid == 1
    study = 'FP'; %removed user input for convenience
    subjid = input('Subject number (3 digits):  ', 's');
    ssnid = '1'; %removed user input: input('Session number (1-5):  ', 's');
    runid = input('Run number (1-3):  ');

    if runid == 1 && (exist(fullfile(homepath, 'SubjectData', [study subjid], [study,'.',subjid,'.',ssnid,'.mat']),'file') == 2)
        cont = input('WARNING: Datafile already exists!  Overwrite? (y/n)  ','s');
        if cont == 'y'
            checksubjid = 0;
        else
            checksubjid = 1;
        end
    else
        checksubjid = 0;
    end
end   

% Set defaults for subject number and session
if isempty(subjid)
    subjid = '999';
end

if isempty(ssnid)
    ssnid = '1';
end

% Create name of datafile where data will be stored    
if ~exist([homepath 'output/' study subjid],'dir')
    mkdir([homepath 'output/' study subjid]);
end

% Specify run number to use in the data structure
runNum = sprintf('run%d',runid);
datafile = fullfile(homepath, 'output', [study subjid], [study,'.',subjid,'.',ssnid,'.mat']);

if exist(datafile,'file')
    load(datafile);
end

Data.subjid = subjid;
Data.ssnid = ssnid;
Data.(char(runNum)).time = datestr(now);

save(datafile,'Data');

%% Initialize parameters for fMRI
inMRI = input('MRI session? 1 = yes, 0 = no: ');

% if no input, default = not in MRI
if isempty(inMRI)
    inMRI = 0;
end

%% Initialize PsychToolbox parameters and save in PTBParams struct
AssertOpenGL;
ListenChar(2); % don't print keypresses to screen
Screen('Preference', 'SkipSyncTests', 1); % use if VBL fails; use this setting on the laptop
%Screen('Preference', 'VisualDebugLevel',3);

HideCursor; %comment out for testing only

% Set screen number
%screenNum=max(Screen('Screens'));
screenNum=0;

% Set screen size and parameters
[w, rect] = Screen('OpenWindow',screenNum);
%[w, rect] = Screen('OpenWindow',screenNum, [], [0 0 960 600]); %DCos 2015.06.25, Use for debugging

ctr = [rect(3)/2, rect(4)/2]; 
white=WhiteIndex(w);
black=BlackIndex(w);
yellow = [240 189 0];
green=[43 101 0];
red = [252 3 8];
gray = (WhiteIndex(w) + BlackIndex(w))/2;
ifi = Screen('GetFlipInterval', w);

% Save parameters in PTBParams structure
PTBParams.win = w;
PTBParams.rect = rect;
PTBParams.ctr = ctr;
PTBParams.white = white;
PTBParams.black = black;
PTBParams.yellow = yellow;
PTBParams.green = green;
PTBParams.red = red;
PTBParams.gray = gray;
PTBParams.ifi = ifi;
PTBParams.datafile = datafile;
PTBParams.homepath = homepath;
PTBParams.subjid = str2double(subjid);
PTBParams.ssnid = ssnid;
PTBParams.keys = initKeys(inMRI);
PTBParams.inMRI = inMRI;
PTBParams.(char(runNum)).runid = runid;

% Save PTBParams structure
datafile = fullfile(homepath, 'output', [study subjid], ['PTBParams.',subjid,'.',ssnid,'.mat']);
save(datafile,'PTBParams');

% Flip screen
Screen(w,'TextSize',round(.2*ctr(2)));
Screen('TextFont',w,'Futura');
Screen('FillRect',w,black);

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
