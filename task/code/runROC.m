%% Regulation of Craving task %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Dani Cosme
% Last Modified: 03-01-2018
%
% Description: This script runs the task. You will be prompted to specify
% which version of the task you'd like to run (MRI, behavioral). 
% 
% You do not need to run the initial setup (InitPTB.m).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initial setup for PsychToolbox, using InitPTB.m
clear all;

pathtofile = mfilename('fullpath');
homepath = pathtofile(1:(regexp(pathtofile,'code/runROC') - 1));
addpath(fullfile(homepath,'code'));
[PTBParams, runNum, study, homepath] = InitPTB(homepath);

% set defaults for random number generator
rng('default')
rng('shuffle')

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

%% Load subject condition info
subInput = sprintf('%sinput/%s%d_%s_condinfo.mat',homepath,study,PTBParams.subjid, PTBParams.ssnid);

if exist(subInput)
    load(subInput);
else
    error('Subject input file (%s) does not exist. \nPlease ensure you have run runGetStimWTP.m',subInput);
end

%% Define image order based on trial and condition info
jpgs = cell(1,length(trialOrder));
conds = unique(trialOrder);
blockSize = 3;
a = 1;
c = 1;
for i = 1:length(conds)
    condition = conds{i};
    idxs = find(strcmp(trialOrder,condition));
    b = 1;
    for j = 1:length(idxs)/blockSize
        % set index position
        idx = idxs(b);
        
        % fill with first craved image
        jpgs{idx} = eval(sprintf('run%d_craved{a,1}',PTBParams.(char(runNum)).runid));
        
        % update index positions
        a = a+1;
        b = b+1;
        idx = idxs(b);
        
        % fill with second craved image
        jpgs{idx} = eval(sprintf('run%d_craved{a,1}',PTBParams.(char(runNum)).runid));
        
        % update index positions
        b = b+1;
        idx = idxs(b);
        
        % fill with second craved image
        jpgs{idx} = eval(sprintf('run%d_notcraved{c,1}',PTBParams.(char(runNum)).runid));
        
        % update index positions
        a = a+1;
        b = b+1;
        c = c+1;
    end
end

%% Check images to ensure no image is selected twice
[unique_jpgs, i] = unique(jpgs,'first');
duplicates = jpgs(not(ismember(1:numel(jpgs),i)));

if ~isempty(duplicates)
    disp(sort(jpgs));
    error('Duplicate files found. Please check ensure there are enough stimuli available.');
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

% define trial and cue wait time
trial=1;
cueWait=2;

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
    
    % Randomize trial images within block
    foodTrials = [Food(trial), Food(trial+1), Food(trial+2)];
    foodRand = foodTrials(randperm(length(foodTrials)));
    
    % Draw preview images
    foodCoords1 = findPicLoc(size(foodJpg{foodRand(1)}),[.2,.45],PTBParams,'ScreenPct',.25);
    foodCoords2 = findPicLoc(size(foodJpg{foodRand(2)}),[.5,.45],PTBParams,'ScreenPct',.25);
    foodCoords3 = findPicLoc(size(foodJpg{foodRand(3)}),[.8,.45],PTBParams,'ScreenPct',.25);
    FoodScreen1 = Screen('MakeTexture',PTBParams.win,foodJpg{foodRand(1)});
    FoodScreen2 = Screen('MakeTexture',PTBParams.win,foodJpg{foodRand(2)});
    FoodScreen3 = Screen('MakeTexture',PTBParams.win,foodJpg{foodRand(3)});
    Screen('DrawTexture',PTBParams.win,FoodScreen1,[],foodCoords1);
    Screen('DrawTexture',PTBParams.win,FoodScreen2,[],foodCoords2);
    Screen('DrawTexture',PTBParams.win,FoodScreen3,[],foodCoords3);
    PreviewOn = Screen(PTBParams.win,'Flip'); 
    previewOnset = PreviewOn-StartTime;
    WaitSecs(3);

    % Draw block cue
    Screen(PTBParams.win,'TextSize',round(.4*PTBParams.ctr(2)));
    DrawFormattedText(PTBParams.win,cue,'center',posCue_y,color);
    Screen(PTBParams.win,'TextSize',round(.15*PTBParams.ctr(2)));
    DrawFormattedText(PTBParams.win,numText1,posPress1_x,posPress_y,PTBParams.white);
    DrawFormattedText(PTBParams.win,num1,posNum1_x,posNum_y,PTBParams.white);
    DrawFormattedText(PTBParams.win,numText2,posPress2_x,posPress_y,PTBParams.white);
    DrawFormattedText(PTBParams.win,num2,posNum2_x,posNum_y,PTBParams.white);
    BlockOn = Screen(PTBParams.win,'Flip');
    if PTBParams.inMRI == 1 %In the scanner use 56, if outside use 12
        [respCue, rtCue] = collectResponse(cueWait,0,'56');
    else
        [respCue, rtCue] = collectResponse(cueWait,0,'12'); %Changing the first argument changes the time the bid is on the screen
    end
    blockOnset = BlockOn-StartTime;
    
    for blockTrial = 1:blockSize %num trials
        foodTrial = foodRand(blockTrial); 
        showFood
        ratingWait = 2.5;
            if PTBParams.inMRI == 1 %In the scanner use 5678, if outside use 1234
                [respRating, rtRating] = collectResponse(ratingWait,0,'5678');
            else
                [respRating, rtRating] = collectResponse(ratingWait,0,'1234'); %Changing the first argument changes the time the bid is on the screen
            end
 
        % Draw effort ratings
        Screen(PTBParams.win,'TextSize',round(.15*PTBParams.ctr(2)));
        DrawFormattedText(PTBParams.win,'How hard was it to look or regulate?','center',posCue_y,PTBParams.white);
        Screen(PTBParams.win,'TextSize',round(.15*PTBParams.ctr(2)));
        DrawFormattedText(PTBParams.win,'not hard',.75*posPress1_x,posPress_y,PTBParams.white);
        DrawFormattedText(PTBParams.win,'very hard',1.05*posPress2_x,posPress_y,PTBParams.white);
        DrawFormattedText(PTBParams.win,'\n\n1    -------    2    -------    3    -------   4','center',posPress_y,PTBParams.white);
        ratingOff = Screen(PTBParams.win,'Flip');
        ratingOffset = ratingOff-StartTime;
        ratingDuration = ratingOffset-ratingOnset;
            if PTBParams.inMRI == 1 %In the scanner use 5678, if outside use 1234
                [respEffort, rtEffort] = collectResponse(ratingWait,0,'5678');
            else
                [respEffort, rtEffort] = collectResponse(ratingWait,0,'1234'); %Changing the first argument changes the time the bid is on the screen
            end
            
        % Draw fixation
        DrawFormattedText(PTBParams.win,'+','center','center',PTBParams.white);
        effortOff = Screen(PTBParams.win,'Flip');
        effortOnset = ratingOffset;
        effortOffset = effortOff-StartTime;
        effortDuration = effortOffset-ratingOffset;
        
        % Log data in .mat file
        logData(datafile,runNum,trial,previewOnset,blockOnset, ...
            trialStart,ISI, ...
            foodPic,foodNum,cond,likingRating, ...
            foodOnset,ratingOnset,effortOnset, ...
            foodDuration,ratingDuration,effortDuration, ...
            respCue,respRating,respEffort, ...
            rtCue,rtRating,rtEffort);
        
        % Update trial number
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

%% Save as .csv and copy files to dropbox
subCode = sprintf('FP%d',PTBParams.subjid);
subDir = fullfile(dropboxDir,subCode);
outputFile = fullfile(homepath,'output',subCode,sprintf('%s_%s.csv',subCode,runNum));

load(datafile)
toWrite = struct2table(rmfield(Data.(char(runNum)),{'time','StartTime','Jitter','EndTime'}));
writetable(toWrite, outputFile, 'WriteVariableNames', true);

if ~exist(subDir)
    copyfile(sprintf('output/%s',subCode), subDir);
    disp(sprintf('Output files copied to %s',subDir));
else
    copyfile(sprintf('output/%s/',subCode), subDir);
    disp(sprintf('Output files copied to %s',subDir));
end