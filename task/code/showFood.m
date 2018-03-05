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
if PTBParams.inMRI == 1
    ISI = Jitter(trial)+3;
else
    ISI = Jitter(trial);
end

% Display fixation 
%DrawFormattedText(PTBParams.win,'+','center','center',PTBParams.white);
%TrialStart = Screen(PTBParams.win,'Flip');
trialStart=GetSecs;
fixDuration = (trialStart-StartTime)-fixOnset;

% Display food
foodCoords = findPicLoc(size(foodJpg{foodTrial}),[.5,.45],PTBParams,'ScreenPct',.55);
FoodScreen = Screen('MakeTexture',PTBParams.win,foodJpg{foodTrial});
Screen('DrawTexture',PTBParams.win,FoodScreen,[],foodCoords);
Screen('FrameRect', PTBParams.win, color, foodCoords, 10);
foodOn = Screen(PTBParams.win,'Flip', trialStart+ISI); 

% Display rating prompt after time specified in WaitTime
Screen(PTBParams.win,'TextSize',round(.15*PTBParams.ctr(2)));
DrawFormattedText(PTBParams.win,'Desire to eat?','center',posCue_y,PTBParams.white);
Screen(PTBParams.win,'TextSize',round(.15*PTBParams.ctr(2)));
DrawFormattedText(PTBParams.win,'no desire',.65*posRate1_x,posPress_y,PTBParams.blue);
DrawFormattedText(PTBParams.win,'strong desire',.97*posRate2_x,posPress_y,PTBParams.blue);
DrawFormattedText(PTBParams.win,'\n\n1    -------    2    -------    3    -------   4','center',posPress_y,PTBParams.white);
ratingOn = Screen(PTBParams.win,'Flip',foodOn+foodWait);
Screen('Close',FoodScreen);

% Log trial info
foodPic = char(jpgs(foodTrial));
foodNum = foodTrial;
foodOnset = foodOn-StartTime;
ratingOnset = ratingOn-StartTime;
foodDuration = ratingOnset-foodOnset;
cond = char(trialOrder(trial));
likingRating = ratings(find(strcmp(foodPic, images)));
if sum(strcmp(char(foodPic),eval(sprintf('%s_craved',runNum)))) == 1
    craved = 1;
else
    craved = 0;
end

