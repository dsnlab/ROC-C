%% bidFood.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Cendri Hutcherson
% Modified by: Dani Cosme
% Last Modified: 10-06-2017
%
% Description: Show food picture for variable number of seconds, then
% prompt with bid 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Run script for each trial
% Specify food image
if PTBParams.inMRI == 1 && blockTrial == 3
    ISI = Jitter(trial)+1;
elseif PTBParams.inMRI == 1 && blockTrial < 3
    ISI = Jitter(trial)+3;
else
    ISI = Jitter(trial);
end

% Define trial start
trialStart=GetSecs;

% Display food
foodCoords = findPicLoc(size(foodJpg{foodTrial}),[.5,.45],PTBParams,'ScreenPct',.55);
FoodScreen = Screen('MakeTexture',PTBParams.win,foodJpg{foodTrial});
Screen('DrawTexture',PTBParams.win,FoodScreen,[],foodCoords);
Screen('FrameRect', PTBParams.win, color, foodCoords, 10);
foodOn = Screen(PTBParams.win,'Flip', trialStart+ISI); 

% Display fixation cross
DrawFormattedText(PTBParams.win,'+','center','center',PTBParams.white);
fixOn = Screen(PTBParams.win,'Flip', foodOn+foodWait);

% Display rating prompt after time specified in WaitTime
Screen(PTBParams.win,'TextSize',round(.15*PTBParams.ctr(2)));
DrawFormattedText(PTBParams.win,'Desire to eat?','center',posCue_y,PTBParams.white);
Screen(PTBParams.win,'TextSize',round(.15*PTBParams.ctr(2)));
DrawFormattedText(PTBParams.win,'no desire',.65*posRate1_x,posPress_y,PTBParams.blue);
DrawFormattedText(PTBParams.win,'strong desire',.97*posRate2_x,posPress_y,PTBParams.blue);
DrawFormattedText(PTBParams.win,'\n\n1    -------    2    -------    3    -------   4','center',posPress_y,PTBParams.white);
ratingOn = Screen(PTBParams.win,'Flip',fixOn+fixRatings);
Screen('Close',FoodScreen);


