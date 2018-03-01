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
TrialStart=WaitSecs(2);

% Display food
foodCoords = findPicLoc(size(foodJpg{Food(trial)}),[.5,.45],PTBParams,'ScreenPct',.55);
FoodScreen = Screen('MakeTexture',PTBParams.win,foodJpg{Food(trial)});
Screen('DrawTexture',PTBParams.win,FoodScreen,[],foodCoords);
Screen('FrameRect', PTBParams.win, color, foodCoords, 5);
FoodOn = Screen(PTBParams.win,'Flip', TrialStart+ISI); 

% Display rating prompt after time specified in WaitTime
Screen(PTBParams.win,'TextSize',round(.15*PTBParams.ctr(2)));
DrawFormattedText(PTBParams.win,'How much do you want to eat this food?','center',posCue_y,PTBParams.white);
Screen(PTBParams.win,'TextSize',round(.15*PTBParams.ctr(2)));
DrawFormattedText(PTBParams.win,'no desire',.75*posPress1_x,posPress_y,PTBParams.white);
DrawFormattedText(PTBParams.win,'strong desire',.95*posPress2_x,posPress_y,PTBParams.white);
DrawFormattedText(PTBParams.win,'\n\n1    -------    2    -------    3    -------   4','center',posPress_y,PTBParams.white);
RatingOn = Screen(PTBParams.win,'Flip',FoodOn+WaitTime);
Screen('Close',FoodScreen);

% Log trial info
FoodPic = jpgs(Food(trial));
FoodNum = Food(trial);
FoodOnset = FoodOn-StartTime;
RatingOnset = RatingOn-StartTime;
FoodDuration = RatingOnset-FoodOnset;
Cond = trialOrder(trial);
LikingRating = ratings(find(strcmp(FoodPic, images)));
if sum(strcmp(char(FoodPic),eval(sprintf('%s_craved',runNum)))) == 1
    Craved = 1;
else
    Craved = 0;
end

