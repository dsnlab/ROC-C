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
ntrials = input('Total number of trials per condition (ROC-C = 30):  ');
Jitter = jitter(1,ntrials,0);  %mean in first position, num trials in second position, sample from long tail in third position
%Jitter(Jitter > 4.5) = 4.5; %truncate max to 4.5 seconds of jitter
fprintf('The mean jitter is %1.2f\n', mean(Jitter));

%% Save jitter vector
outputfile = fullfile(homepath,'input','jitter.mat');
save(outputfile,'Jitter')
