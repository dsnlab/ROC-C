%% runGetStimROC.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Dani Cosme
%
% Description: This script selects food images based on their ratings,
% randomizes them, and adds the images to the ROC/Resources folder
% 
% Inputs: Ratings .csv file in dropbox path (defined below) with the 
% following name: [study][subject ID]_ratings.csv (e.g. DEV999_ratings.csv)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Housecleaning before the guests arrive
pathtofile = mfilename('fullpath');
homepath = pathtofile(1:(regexp(pathtofile,'code/runGetStim') - 1));
addpath(homepath);

cd(homepath);
clear all; close all; Screen('CloseAll'); 
homepath = [pwd '/'];

% set defaults for random number generator
rng('default')
rng('shuffle')

%% Set dropbox path for copying
dropboxDir = '~/Dropbox (PfeiBer Lab)/FreshmanProject/Tasks/ROC-C/output';

%% Get study, subject id, and session number from user
ssnid = '1'; %removed user input: input('Session number (1-5):  ', 's');

% set prompt info and default answers
prompt = {'Study code'; 'Subject number (3 digits)'};
name = 'Subject Info';
defAns = {'FP'; '999'};
options.WindowStyle = 'normal';

% open dialog box
% To change the default font size, you need to edit this directly in the
% inputdlg function by typing: edit inputdlg.m
% TextInfo.FontSize = get(0,'FactoryUicontrolFontSize') -->
% TextInfo.FontSize = 14

answer = inputdlg(prompt,name,1,defAns,options);

% name variables from inputs
study = answer{1};
subjid = answer{2};

%% Specify number of craved and less craved images
n_craved = 60;
n_notcraved = 30;
n_practice = 9;

%% Specify number of runs and trials per run
nruns = 3;
ntrials = 30;

%% Load image info
% Define ratings path
ratingspath = fullfile(homepath,'ratings');

% Define subject input file
subinput = sprintf('%s/%s%s_ratings.csv',ratingspath,study,subjid);

% Load image rating info
if exist(subinput)
    fid=fopen(subinput);
    imageinfo = textscan(fid, '%n%n%s', 'Delimiter', ',', 'treatAsEmpty','NULL', 'EmptyValue', NaN);
    fclose(fid);
else
    error(sprintf('Subject input file (%s) does not exist',subinput));
end

%% Check if there are enough stimuli for the number of trials specified
if length(imageinfo{1,1}) < n_craved + n_notcraved
    error('The number of stimuli available is less than the number of trials specified');
end

%% Check if number of stimuli set is divisible by the number of runs
if mod(ntrials,nruns) ~= 0
    error('The number of trials is not divisible by the number of runs. Check the inputs.')
end

%% Create run directories and remove old images and unnecessary run directories
% Remove current images from run directories
nrundirs = numel(dir(sprintf('%sstimuli/run*',homepath)));
for i = 1:nrundirs
    rundir = dir(fullfile(sprintf('%sstimuli/run%d', homepath, i)));
    if numel(rundir) > 2
        disp(sprintf('Removing files from run directory %d',i))
        delete(sprintf('%sstimuli/run%d/*.jpg', homepath, i));
    end
end

% Remove unnecessary run directories
for i = 1:nrundirs
    if i > nruns
        disp(sprintf('Removing unnecessary run directory %d',i))
        rundir = (sprintf('%sstimuli/run%d', homepath, i));
        rmdir(rundir)
    end
end

% Create directories if they do not exist
for i = 1:nruns
    rundir = fullfile(sprintf('%sstimuli/run%d', homepath, i));
    if ~exist(rundir)
        disp(sprintf('Run directory %d did not exist. Creating it now',i))
        mkdir(rundir);
    end 
end

% Remove practice images and create directory if it does not exist
practicedir = fullfile(sprintf('%sstimuli/practice', homepath));
if numel(dir(practicedir)) > 2
    disp('Removing files from practice directory')
    delete(sprintf('%sstimuli/practice/*.jpg', homepath));
end

if ~exist(practicedir)
    disp('Practice directory did not exist. Creating it now')
    mkdir(practicedir);
end 

%% Sort foods to determine craved and less craved foods
ratings = imageinfo{1,1};
category = imageinfo{1,2};
images = imageinfo{1,3};

% Code NaN ratings as 0 for sorting
ratingsNaN = [ratings, category];
if sum(isnan(ratingsNaN(:,1))) > 0
    warning('Converting NaNs to 0');
    ratingsNaN(isnan(ratingsNaN(:,1))) = 0;
end

% Sort images by rating (ascending 1 --> 4) and category (descending 3 --> 1)
[sortedvals, sortidx] = sortrows(ratingsNaN,[1, -2]);
sortedratings = sortedvals(:,1);

% Check if there are enough trials with ratings 1-4 and exclude 0s and NaNs
sumtrials = sum(sortedratings(:,1) > 0);
ntrials = n_craved + n_notcraved;
deficit = ntrials - sumtrials;

if deficit > 0
    warning('Too few images with ratings > 0. Including %d trials rated 0.', deficit);
    total = sumtrials + deficit;
    sortedratings_g0 = sortedratings(end-(total-1):end);
    sortidx_g0 = sortidx(end-(total-1):end);
else
    sortedratings_g0 = sortedratings(sortedratings > 0);
    sortidx_g0 = sortidx(sortedratings > 0);
end

% Select first and next n trials 
craved = images(sortidx_g0(end-(n_craved-1):end)); % highest rated n images
notcraved = images(sortidx_g0((end-n_craved-n_notcraved+1):end-(n_craved))); % next highest rated n images
%notcraved = images(sortidx_g0(1:n_notcraved)); % lowest rated n images

% Select practice images
practice = images(sortidx_g0((end-n_craved-n_notcraved-n_practice+1):(end-n_craved-n_notcraved))); % next highest n images 

% Randomize images
craved_rand = craved(randperm(length(craved)));
notcraved_rand = notcraved(randperm(length(notcraved)));

%% Craved foods: Specify runs and first and last images to select from top images
n = length(craved_rand)/nruns;
first = 1;
last = n; 

% Create run variables with image positions for craved foods
disp('Adding craved foods to run directories')
for i = 1:nruns
  % specify image positions and images
  evalc(sprintf('run%d_craved = craved_rand(first:last)', i));

  % move images
  for j = 1:length(eval(sprintf('run%d_craved',i)))
      runimg = eval(sprintf('run%d_craved{j}', i));
      category = runimg(1:regexp(runimg,'[0-9]{2}.jpg')-1);
      copyfile(fullfile(homepath,'stimuli','categories',category,runimg), fullfile(homepath,'stimuli',sprintf('run%d',i))); 
  end

  % update iterators
  first = first + n;
  last = last + n;
end


%% less craved foods: Specify runs and first and last images to select from top images
n = length(notcraved_rand)/nruns;
first = 1;
last = n; 

% Create run variables with image positions for less craved foods
disp('Adding less craved foods to run directories')
for i = 1:nruns
  % specify image positions and images
  evalc(sprintf('run%d_notcraved = notcraved_rand(first:last)', i));

  % move images
  for j = 1:length(eval(sprintf('run%d_notcraved',i)))
      runimg = eval(sprintf('run%d_notcraved{j}', i));
      category = runimg(1:regexp(runimg,'[0-9]{2}.jpg')-1);
      copyfile(fullfile(homepath,'stimuli','categories',category,runimg), fullfile(homepath,'stimuli',sprintf('run%d',i))); 
  end

  % update iterators
  first = first + n;
  last = last + n;
end

%% Copy practice images
disp('Adding practice images to practice directory')
for i = 1:length(practice)
  runimg = practice{i};
  category = runimg(1:regexp(runimg,'[0-9]{2}.jpg')-1);
  copyfile(fullfile(homepath,'stimuli','categories',category,runimg), fullfile(homepath,'stimuli/practice')); 
end

%% Check images to ensure no image is selected twice
runcheck = who('run*_*craved*');
b = [];
for i = 1:length(runcheck)
    a = eval(runcheck{i});
    b = vertcat(b,a);
end

[unique_b, i] = unique(b,'first');
duplicates = b(not(ismember(1:numel(b),i)));

if ~isempty(duplicates)
    disp(sort(b));
    error('Duplicate files found. Please check ensure there are enough stimuli available.');
end

%% Get ratings for selected images
selected = vertcat(craved, notcraved);
selectedidx = cellfun(@(x) ismember(x, selected), imageinfo{1,3}, 'UniformOutput', 0);
ratings = imageinfo{1,1}(cell2mat(selectedidx) == 1);
images = imageinfo{1,3}(cell2mat(selectedidx) == 1);

%% Print number of images in each run and practice directory
for i = 1:nruns
    n = numel(dir(sprintf('%sstimuli/run%d/*.jpg',homepath,i)));
    fprintf('Run directory %d contains %d images\n',i,n);
end

n = numel(dir(sprintf('%sstimuli/practice/*.jpg',homepath)));
fprintf('Practice directory contains %d images\n',n);
    
%% Save subject trial condition output
suboutput = sprintf('%sinput/%s%s_%s_condinfo.mat',homepath,study,subjid,ssnid);
save(suboutput, 'run*_*', 'images', 'ratings', 'practice')

%% Copy file to dropbox
subCode = sprintf('%s%s',study,subjid);
subDir = fullfile(dropboxDir,study,subCode);

if ~exist(subDir)
    mkdir(subDir);
    copyfile(suboutput, subDir);
    disp(sprintf('Output files copied to %s',subDir));
else
    copyfile(suboutput, subDir);
    disp(sprintf('Output files copied to %s',subDir));
end

%% Clean up
clear all; close all; Screen('CloseAll'); 