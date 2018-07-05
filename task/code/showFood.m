%% showFood.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Dani Cosme
%
% Description: Show food picture for variable number of seconds, then
% prompt with bid 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Run script for each trial
% Display food
foodCoords = findPicLoc(size(foodJpg{foodTrial}),[.5,.45],PTBParams,'ScreenPct',.55);
FoodScreen = Screen('MakeTexture',PTBParams.win,foodJpg{foodTrial});
Screen('DrawTexture',PTBParams.win,FoodScreen,[],foodCoords);
Screen('FrameRect', PTBParams.win, color, foodCoords, 10);
foodOn = Screen(PTBParams.win,'Flip');
WaitSecs(foodWait);
foodOnset = foodOn-StartTime;
if PTBParams.debugging == 1
    if blockTrial == 1; fprintf('fixCue dur = %.1f\n', foodOnset - fixOnset); end
    if blockTrial > 1; fprintf('ITI dur = %.1f, ITI = %.1f\n', foodOnset - itiOnset, ITI); end
end

% Display fixation cross
DrawFormattedText(PTBParams.win,'+','center','center',PTBParams.white);
fixOn = Screen(PTBParams.win,'Flip');
WaitSecs(fixRatings);
fixRatingOnset = fixOn-StartTime;
foodDuration = fixRatingOnset-foodOnset;
if PTBParams.debugging == 1; fprintf('food dur = %.1f\n', foodDuration); end

% Specify trial info for logging
foodPic = char(jpgs(foodTrial));
foodNum = foodTrial;
cond = char(trialOrder(trial));
likingRating = ratings(find(strcmp(foodPic, images)));
if sum(strcmp(char(foodPic),eval(sprintf('%s_craved',runNum)))) == 1
    craved = 1;
else
    craved = 0;
end

