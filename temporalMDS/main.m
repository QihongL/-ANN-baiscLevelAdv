%% superordinate classfication
% the OVERALL GOAL of this program is to convert a 'neural response' from
% ANN (in the form of a time series) and outputs a 'class' that represents
% a superordinate level category
function distMat = main()
%% Specify the Path information (user needs to do this!)
PATH.PROJECT = '/Users/Qihong/Dropbox/github/categorization_PDP/';
% PATH.DATA_FOLDER = 'sim21.5_lessHidden';
PATH.DATA_FOLDER = 'sim16_large';
% provide the NAMEs of the data files (user need to set them mannually)
FILENAME.DATA = 'hiddenAll_e3.txt';
FILENAME.PROTOTYPE = 'PROTO.xlsx';

%% load the data and the prototype
[output, param] = loadData(PATH, FILENAME);

%% data preprocessing
% get activation matrices
activationMatrix = getActivationMatrices(output, param);
numTimePoints = size(activationMatrix,1);
% get labels
[~, Y] = getLabels(param);

%% loop over all categories
numCategories = size(Y,2);
distMat = cell(numTimePoints,numCategories);
% loop over all time points
for j = 1 : numCategories
    %% Run MDS for all time points
    for i = 1 : numTimePoints
        distMat{i,j} = squareform(pdist(activationMatrix{i}, 'euclidean'));
    end
end

%% set up selection matrix for distances
select = getSelectionMatrices(param);
%% compute mean distances for 3 levels over time
avgDist = cell(param.numCategory.sup,1);
for j = 1:param.numCategory.sup
    avgDist{j} = getAvgDistOverTime(distMat(:,j), select);
end

%% compute mean distance across all super classes
avgDist = avgDistAcrossSuperClasses(avgDist);

%% plot it 
plotAvgDistances(avgDist);


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% Some Helper functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% plot the results
function plotAvgDistances(avgDist)
figure
% plot the mean distances over time 
hold on 
LW = 2;
plot(avgDist.sup,'linewidth',LW);
plot(avgDist.bas,'linewidth',LW);
plot(avgDist.sub,'linewidth',LW);
hold off

% add texts
FS = 16;
title('Average distances over time','fontsize', FS);
legend({'superordinate', 'basic', 'subordinate'},'Fontsize', FS ...
    ,'Location','southeast');
ylabel('mean distance','fontsize', FS);
xlabel('stimuli onset time','fontsize', FS);
end

%% compute average MDS distance across all super classes trained 
function dist = avgDistAcrossSuperClasses(avgDist)
numCategories = size(avgDist,1);
dist.sup = avgDist{1}.sup;
dist.bas = avgDist{1}.bas;
dist.sub = avgDist{1}.sub;
% sum distances over all super classes
for i = 2 :numCategories
    dist.sup = dist.sup + avgDist{i}.sup;
    dist.bas = dist.bas + avgDist{i}.bas;
    dist.sub = dist.sub + avgDist{i}.sub;
end
% compute average
dist.sup = dist.sup / numCategories;
dist.bas = dist.bas / numCategories;
dist.sub = dist.sub / numCategories;
end


%% compute average MDS distance over time 
function avgDist = getAvgDistOverTime(distMatices, select)
% get number of time points
numTimePoints = length(distMatices);
% preallocate 
avgDist.sup = nan(numTimePoints,1);
avgDist.bas = nan(numTimePoints,1);
avgDist.sub = nan(numTimePoints,1);

% loop over all time points to get distances over time 
for i = 1 : numTimePoints;
    curMat = distMatices{i};
    % get average distance
    avgDist.sup(i) = mean(curMat(select.sup));
    avgDist.bas(i) = mean(curMat(select.bas));
    avgDist.sub(i) = mean(curMat(select.sub));
end

end

%% compute the direct sum of the N identical matrices
function output = iterDsum(matrix, iteration)
output = matrix;
% compute the direct sum
while iteration > 1
    iteration = iteration - 1;
    output = dsum(output, matrix);
end
end

%% set up selection matrix for superordinate distance and basic distance
function select = getSelectionMatrices(param)

% get superordinate selection matrix
temp = true(param.numInstances,param.numInstances);
select.sup = ~iterDsum(temp,param.numCategory.sup);

% get basic level selection matrix
temp = true(param.numCategory.bas,param.numCategory.bas);
temp = iterDsum(temp,(param.numCategory.bas*param.numCategory.sup));
select.bas = (~logical(temp + select.sup));

% get the subordinate level selection matrix
select.sub = ~logical(select.bas + select.sup + eye(param.numStimuli));
end
