%% Willingness to Pay task %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Cendri Hutcherson
% Modified by: Dani Cosme
% Last Modified: 10-06-2017
%
% Description: This script runs the task. You will be prompted to specify
% which version of the task you'd like to run (MRI, behavioral). 
% 
% You do not need to run the initial setup (InitPTB.m).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initial setup for PsychToolbox, using InitPTB.m
clear all;

pathtofile = mfilename('fullpath');
homepath = pathtofile(1:(regexp(pathtofile,'PTBScripts') - 1));
addpath(fullfile(homepath,'PTBScripts'));
[PTBParams, runNum, study] = InitPTB(homepath);
homepath=PTBParams.homepath;

%% Set dropbox path for copying
dropboxDir = '~/Dropbox (PfeiBer Lab)/FreshmanProject/Tasks/ROC-C/output';

%% Load trial and subject condition info
% Load trial condition order info (design created using the CAN lab GA)
% https://github.com/UOSAN/CanLabCore_GA/tree/master/SAN_GAs/DEV
%% UPDATE %%%%%%%%%%%%%%%%%%%%
order = [repelem({'LOOK', 'REGULATE'}, 2), repelem({'CHOOSE'},6)];
blockOrder = order(randperm(length(order)));
trialOrder = repelem(blockOrder, 3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load subject condition info
subInput = sprintf('%sinput/%s%d_%s_condinfo.mat',homepath,study,PTBParams.subjid, PTBParams.ssnid);

if exist(subInput)
    load(subInput);
else
    error('Subject input file (%s) does not exist. \nPlease ensure you have run runGetStimWTP.m',subInput);
end

% Define image order based on trial and condition info
jpgs = cell(1,length(trialOrder));
conds = unique(trialOrder);
blockSize = 3;
for i = 1:length(conds)
    cond = conds{i};
    idxs = find(strcmp(trialOrder,cond));
    a = 1;
    b = 1;
    c = 1;
    for j = 1:length(idxs)/blockSize
        idx = idxs(b);
        jpgs{idx} = eval(sprintf('run%d_craved{a,1}',PTBParams.(char(runNum)).runid));
        a = a+1;
        b = b+1;
        idx = idxs(b);
        jpgs{idx} = eval(sprintf('run%d_craved{a,1}',PTBParams.(char(runNum)).runid));
        b = b+1;
        idx = idxs(b);
        jpgs{idx} = eval(sprintf('run%d_notcraved{c,1}',PTBParams.(char(runNum)).runid));
        a = a+1;
        b = b+1;
        c = c+1;
    end
end

%% Preload Stimulus Pictures 
% Load food bitmaps into memory
for x = 1:length(jpgs)
    foodJpg{x} = imread(fullfile(sprintf('%sstimuli/run%d/%s', homepath, PTBParams.(char(runNum)).runid, jpgs{x})),'jpg');
end

% Specify food order (sequential because order is defined in previous chunk)
Food = 1:length(trialOrder);

%% Load jitter
if PTBParams.inMRI
    load(fullfile(homepath,'input','jitter.mat'))
else
    Jitter = ones(length(trialOrder),1);
end

% Check to make sure the number of trials and jitter is the same
if length(Jitter) < length(trialOrder)
    error('There are not enough jitter trials allocated. \nThere are %d jitters and %d trials. \nCheck jitter file %s and consider rerunning runJitter.m', ...
        length(Jitter), length(trialOrder), fullfile(homepath,'input','jitter.mat'))
end

%% Initialize keys
inputDevice = PTBParams.keys.deviceNum;

%% Load task instructions based on MRI or behavioral session
if PTBParams.inMRI == 1
    DrawFormattedText(PTBParams.win,'Calibrating scanner.\n\n Please hold very still.','center','center',PTBParams.white);
else 
    DrawFormattedText(PTBParams.win,'The task is about to begin.\n\n Get ready!','center','center',PTBParams.white);
end
Screen(PTBParams.win,'Flip');

%% Run task and log data
% Wait for the trigger before continuing
% Wait for a 'spacebar' to start the behavioral version, and an ' for the scanner version
scantrig;

datafile = PTBParams.datafile;
logData(datafile,runNum,1,StartTime,Jitter);

% Define text positions
posCue_y = PTBParams.rect(4)/3;
posPress1_x = PTBParams.rect(3)/8;
posPress2_x = 5.4*PTBParams.rect(3)/8;
posPress_y = 2*PTBParams.rect(4)/3.5;
posNum1_x = posPress1_x+(PTBParams.rect(3)/16);
posNum2_x = posPress2_x+(PTBParams.rect(3)/16);
posNum_y = 2*PTBParams.rect(4)/3.5;

trial=1;

% Run task
for block = 1:length(blockOrder)
    cue = blockOrder{block};
    if strcmp(cue,'CHOOSE')
        color = PTBParams.yellow;
        numText1 = 'LOOK';
        numText2 = 'REGULATE';
        num1 = '\n\n1';
        num2 = '\n\n2';
        posPress2_x = 4.85*PTBParams.rect(3)/8;
    elseif strcmp(cue,'REGULATE')
        color = PTBParams.red;
        numText1 = '';
        numText2 = 'PRESS';
        num1 = '';
        num2 = '\n\n2';
        posPress2_x = 5.4*PTBParams.rect(3)/8;
    else
        color = PTBParams.green;
        numText1 = 'PRESS';
        numText2 = '';
        num1 = '\n\n1';
        num2 = '';
        posPress2_x = 5.4*PTBParams.rect(3)/8;
    end
    Screen(PTBParams.win,'TextSize',round(.4*PTBParams.ctr(2)));
    DrawFormattedText(PTBParams.win,cue,'center',posCue_y,color);
    Screen(PTBParams.win,'TextSize',round(.15*PTBParams.ctr(2)));
    DrawFormattedText(PTBParams.win,numText1,posPress1_x,posPress_y,PTBParams.white);
    DrawFormattedText(PTBParams.win,num1,posNum1_x,posNum_y,PTBParams.white);
    DrawFormattedText(PTBParams.win,numText2,posPress2_x,posPress_y,PTBParams.white);
    DrawFormattedText(PTBParams.win,num2,posNum2_x,posNum_y,PTBParams.white);
    blockStart = Screen(PTBParams.win,'Flip');
    
    for blockTrial = 1:blockSize %num trials
        showFood
        ratingWait = 2.5;
            if PTBParams.inMRI == 1 %In the scanner use 5678, if outside use 1234
                [Resp, RT] = collectResponse(ratingWait,0,'5678');
            else
                [Resp, RT] = collectResponse(ratingWait,0,'1234'); %Changing the first argument changes the time the bid is on the screen
            end
 
        % draw effort ratings
        Screen(PTBParams.win,'TextSize',round(.15*PTBParams.ctr(2)));
        DrawFormattedText(PTBParams.win,'How hard was it to look or regulate?','center',posCue_y,PTBParams.white);
        Screen(PTBParams.win,'TextSize',round(.15*PTBParams.ctr(2)));
        DrawFormattedText(PTBParams.win,'not hard',.75*posPress1_x,posPress_y,PTBParams.white);
        DrawFormattedText(PTBParams.win,'very hard',1.05*posPress2_x,posPress_y,PTBParams.white);
        DrawFormattedText(PTBParams.win,'\n\n1    -------    2    -------    3    -------   4','center',posPress_y,PTBParams.white);
        RatingOff = Screen(PTBParams.win,'Flip');
        RatingOffset = RatingOff-StartTime;
        RatingDuration = RatingOffset-RatingOnset;
            if PTBParams.inMRI == 1 %In the scanner use 5678, if outside use 1234
                [Resp, RT] = collectResponse(ratingWait,0,'5678');
            else
                [Resp, RT] = collectResponse(ratingWait,0,'1234'); %Changing the first argument changes the time the bid is on the screen
            end
        DrawFormattedText(PTBParams.win,'+','center','center',PTBParams.white);
        EffortOff = Screen(PTBParams.win,'Flip');
        EffortOffset = EffortOff-StartTime;
        EffortDuration = EffortOffset-RatingOffset;
        %logData(datafile,runNum,trial,TrialStart,ISI,FoodOn,BidOn,FoodOnset,...
                %BidOnset,FoodDuration,RatingDuration,FoodPic,FoodNum,Cond,HealthCond,LikingCond,LikingRating,Resp,RT);
        trial=trial+1;
    end
end

% Wait for 6 seconds and log end time
WaitSecs(6);
EndTime = GetSecs-StartTime;
logData(datafile,runNum,1, EndTime);

DrawFormattedText(PTBParams.win,'The task is now complete.','center','center',PTBParams.white);
Screen(PTBParams.win,'Flip'); 
WaitSecs(4);

%% Close screen
if ~exist('sprout')
    % Housekeeping after the party
    Screen('CloseAll');
    ListenChar(0);
end

%% Copy file to dropbox
subCode = sprintf('DEV%d',PTBParams.subjid);
subDir = fullfile(dropboxDir,subCode);
if ~exist(subDir)
    copyfile(sprintf('SubjectData/%s',subCode), subDir);
    disp(sprintf('Output file copied to %s',subDir));
else
    copyfile(sprintf('SubjectData/%s/',subCode), subDir);
    disp(sprintf('Output file copied to %s',subDir));
end