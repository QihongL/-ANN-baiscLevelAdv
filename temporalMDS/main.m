%% superordinate classfication
% the OVERALL GOAL of this program is to convert a 'neural response' from
% ANN (in the form of a time series) and outputs a 'class' that represents
% a superordinate level category
function gs = main()

%% Specify the Path information (user needs to do this!)
PATH.PROJECT = '/Users/Qihong/Dropbox/github/categorization_PDP/';
% PATH.DATA_FOLDER = 'sim21.5_lessHidden';
PATH.DATA_FOLDER = 'sim16_large';
% provide the NAMEs of the data files (user need to set them mannually)
FILENAME.DATA = 'hiddenAll_e3.txt';
FILENAME.PROTOTYPE = 'PROTO.xlsx';

%% set some paramters
showresults = true;
% Spatial bluring
spaBlur = true;
% Normal noise
variance = 0;
% specifiy the number of folds for CV
K = 3;

%% load the data and the prototype
[output, param] = loadData(PATH, FILENAME);

%% data preprocessing
% get activation matrices
activationMatrix = getActivationMatrices(output, param);
numTimePoints = size(activationMatrix,1);
% get labels
[~, Y] = getLabels(param);

% loop over all categories
numCategories = size(Y,2);
for j = 1 : numCategories
    %% attach labels
    data = attachLabels(activationMatrix, Y(:,j));
    %% set up Cross validation blocks
    CVB = logical(mod(1:param.numStimuli,K) == 0);
    
    % preallocation
    accuracy = nan(numTimePoints, 1);
    deviation = nan(numTimePoints, 1);
    %% Run Logistic regression classification for all time points
    % loop over time
    for i = 1 : numTimePoints
        % compute the accuracy for every time points
        [accuracy(i), deviation(i)] = logisticReg(data{i}, CVB, variance, spaBlur, showresults);
    end
    gs.accuracy{j} = accuracy;
    gs.deviation{j} = deviation;
end

%% A function that visualizes the results
[overallScore] = averagingResults(gs,numCategories, numTimePoints);
visualizeResults(overallScore)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Helper functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Visualize the results
function visualizeResults(score)
fontsize = 18;
% Plot the CV accuracies against time
subplot(1,2,1)
plot(score.accuracy)
ylim([(min(score.accuracy)-5) 100])
xlabel('time', 'FontSize', fontsize)
ylabel('cross-validated accuracy (%)', 'FontSize', fontsize)
title('accuracy against time', 'FontSize', fontsize)
% Plot the sum of absolute deviations (on the test set) against time
subplot(1,2,2)
plot(score.deviation)
xlabel('time', 'FontSize', fontsize)
ylabel('sum|deviation| from targets (0 or 1)', 'FontSize', fontsize)
title('absolute deviation against time', 'FontSize', fontsize)
end

%% averaging the results across simulations
function [score] = averagingResults(gs,numSim, numTimePoints)
% preallocate
accuracy = zeros(numTimePoints, 1);
deviation = zeros(numTimePoints, 1);
% accumulate
for i = 1 : numSim
    accuracy = accuracy + gs.accuracy{i};
    deviation = deviation + gs.deviation{i};
end
% take mean
score.accuracy = accuracy / numSim;
score.deviation = deviation / numSim;
end



% specify how many simulations you want to do
% numSim = 10;
% gs.accuracy = cell(numSim,1);
% gs.deviation = cell(numSim,1);
% run more simulations, since there is randomness in noise component