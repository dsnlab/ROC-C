function [PTBParams, runNum, study, homepath] = InitPTB(homepath)
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

%% Specify whether debugging
debugging = 0;

%% Get study and subject info and whether MRI or behavioral session
% Check to make sure aren't about to overwrite duplicate session!
checksubjid = 1;
while checksubjid == 1
    ssnid = '1'; %removed user input: input('Session number (1-5):  ', 's');

    % set prompt info and default answers
    prompt={'Study code'; 'Subject number (3 digits)'; 'Run number (1-3)'; 'MRI session? (0 = no, 1 = yes)'};
    name='Subject Info';
    defAns={'FP'; '999'; ''; ''};
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
    runid = str2double(answer{3});
    inMRI = str2double(answer{4});

    if runid == 1 && (exist(fullfile(homepath, 'output', [study subjid], [study,'.',subjid,'.',ssnid,'.mat']),'file') == 2)
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

%% Initialize PsychToolbox parameters and save in PTBParams struct
AssertOpenGL;
ListenChar(2); % don't print keypresses to screen
Screen('Preference', 'SkipSyncTests', 1); % use if VBL fails; use this setting on the laptop
%Screen('Preference', 'VisualDebugLevel',3);

if debugging ~= 1; HideCursor; end

% Set screen number
%screenNum=max(Screen('Screens'));
screenNum=0;

% Set screen size and parameters
if debugging == 1
    [w, rect] = Screen('OpenWindow',screenNum, [], [0 0 960/2 600/2]);
else 
    [w, rect] = Screen('OpenWindow',screenNum);
end

ctr = [rect(3)/2, rect(4)/2]; 
ifi = Screen('GetFlipInterval', w);

% Specify accepted responses
if inMRI == 1
    lookKey = '6';
    regKey = '7';
    choiceKeys = '67';
    rateKeys = '6789';
else
    lookKey = '1';
    regKey = '2';
    choiceKeys = '12';
    rateKeys = '1234';
end

% Save parameters in PTBParams structure
PTBParams.win = w;
PTBParams.rect = rect;
PTBParams.ctr = ctr;
PTBParams.white = WhiteIndex(w);
PTBParams.black = [29  31  33  255]./255; BlackIndex(w);
PTBParams.yellow = [240 189 0];
PTBParams.green = [142 166 4];
PTBParams.blue = [0 161 228];
PTBParams.teal = [77 161 169];
PTBParams.red = [252 3 8];
PTBParams.gray = (WhiteIndex(w) + BlackIndex(w))/2;
PTBParams.ifi = ifi;
PTBParams.datafile = datafile;
PTBParams.homepath = homepath;
PTBParams.subjid = subjid;
PTBParams.ssnid = ssnid;
PTBParams.keys = initKeys(inMRI, debugging);
PTBParams.inMRI = inMRI;
PTBParams.(char(runNum)).runid = runid;
PTBParams.debugging = debugging;
PTBParams.lookKey = lookKey;
PTBParams.regKey = regKey;
PTBParams.choiceKeys = choiceKeys;
PTBParams.rateKeys = rateKeys;

% Save PTBParams structure
datafile = fullfile(homepath, 'output', [study subjid], ['PTBParams.',subjid,'.',ssnid,'.mat']);
save(datafile,'PTBParams');

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

