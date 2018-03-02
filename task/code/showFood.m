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
% Specify food image and fixation presentation lengths
WaitTime = 5; %Specifies how long to wait before rating screen appears
if PTBParams.inMRI == 1
    ISI = Jitter(trial)+3;
else
    ISI = Jitter(trial);
end

% Display fixation 
%DrawFormattedText(PTBParams.win,'+','center','center',PTBParams.white);
%TrialStart = Screen(PTBParams.win,'Flip');
trialStart=GetSecs;

% Display food
foodCoords = findPicLoc(size(foodJpg{foodTrial}),[.5,.45],PTBParams,'ScreenPct',.55);
FoodScreen = Screen('MakeTexture',PTBParams.win,foodJpg{foodTrial});
Screen('DrawTexture',PTBParams.win,FoodScreen,[],foodCoords);
Screen('FrameRect', PTBParams.win, color, foodCoords, 10);
FoodOn = Screen(PTBParams.win,'Flip', trialStart+ISI); 

% Display rating prompt after time specified in WaitTime
Screen(PTBParams.win,'TextSize',round(.15*PTBParams.ctr(2)));
DrawFormattedText(PTBParams.win,'How much do you want to eat this food?','center',posCue_y,PTBParams.white);
Screen(PTBParams.win,'TextSize',round(.15*PTBParams.ctr(2)));
DrawFormattedText(PTBParams.win,'no desire',.75*posPress1_x,posPress_y,PTBParams.white);
DrawFormattedText(PTBParams.win,'strong desire',.95*posPress2_x,posPress_y,PTBParams.white);
DrawFormattedText(PTBParams.win,'\n\n1    -------    2    -------    3    -------   4','center',posPress_y,PTBParams.white);
ratingOn = Screen(PTBParams.win,'Flip',FoodOn+WaitTime);
Screen('Close',FoodScreen);

% Log trial info
foodPic = char(jpgs(foodTrial));
foodNum = foodTrial;
foodOnset = FoodOn-StartTime;
ratingOnset = ratingOn-StartTime;
foodDuration = ratingOnset-foodOnset;
cond = char(trialOrder(trial));
likingRating = ratings(find(strcmp(foodPic, images)));
if sum(strcmp(char(foodPic),eval(sprintf('%s_craved',runNum)))) == 1
    craved = 1;
else
    craved = 0;
end
