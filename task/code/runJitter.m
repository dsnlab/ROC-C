%% runJitter.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Dani Cosme
%
% Description: This script creates the jitter based on the number of
% specified trials and saves a vector of values in ROC-C/task/input as a 
% .mat file (jitter.mat)
% 
% Dependencies: jitter.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set path
pathtofile = mfilename('fullpath');
homepath = pathtofile(1:(regexp(pathtofile,'code/runJitter') - 1));

%% Create jitter vector
meanVal = input('Mean:  ');
ntrials = input('Number of trials per run:  ');
outfile = input('File name (e.g. jitter.mat):  ', 's');
Jitter = jitter(meanVal,ntrials,0);  %mean in first position, num trials in second position, sample from long tail in third position
fprintf('The mean jitter is %1.2f\n', mean(Jitter));

%% Save jitter vector
outputfile = fullfile(homepath,'input',outfile);
save(outputfile,'Jitter')
