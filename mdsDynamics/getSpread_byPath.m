function [ meanSpread ] = getSpread_byPath( data, param, idx, nTimePts )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% preallocate 
catSize.sup = param.numStimuli / param.numCategory.sup;
catSize.bas = param.numStimuli /param.numCategory.sup /param.numCategory.bas;
path = cell(catSize.sup,1);
% meanPath.sup = zeros(nTimePts, size(data,2));
tempMeanPathSup = zeros(nTimePts, size(data,2));
meanPath.sup = cell(param.numCategory.sup,1);
meanPath.bas = zeros(nTimePts, size(data,2));
meanPath.all = zeros(nTimePts, size(data,2));
spread.sup = zeros(nTimePts, size(data,2));
spread.bas = zeros(nTimePts, size(data,2));
meanSpread.sup.within = zeros(nTimePts, size(data,2));
meanSpread.sup.bet = zeros(nTimePts, size(data,2));
meanSpread.bas.within = zeros(nTimePts, size(data,2));
meanSpread.bas.bet = zeros(nTimePts, size(data,2));

%% get all path
for i = 1 : param.numStimuli
    path{i} = data(idx(i,:),:);
    meanPath.all = meanPath.all + path{i};
end
% compute average path 
meanPath.all = meanPath.all / param.numStimuli;


%% compute the spread of the sup category 
for j = 1 : param.numCategory.sup

    % compute average "superordinate path" in semantic space
    for i = (1 + catSize.sup * (j-1)) : catSize.sup * j
        tempMeanPathSup = tempMeanPathSup + path{i};
    end
    % save the path 
    tempMeanPathSup = tempMeanPathSup / catSize.sup;
    meanPath.sup{j} = tempMeanPathSup;
    
    % get the spread between different super categories 
    % spread__sup&total = sum | meanSupPath - meanPath |
    meanSpread.sup.bet = meanSpread.sup.bet + abs(meanPath.sup{j} - meanPath.all);
    
    % sum the spread of the individual path to the average path
    % jth spread_sup = sum | path_ij - meanSupPath_j |
    for i = (1 + catSize.sup * (j-1)) : catSize.sup * j
        spread.sup = spread.sup + abs(path{i} - meanPath.sup{j});
    end
    % get the mean spread for one superordinate class
    % meanSupSpread_within = sum | spread_sup_j | (for all j)
    meanSpread.sup.within = meanSpread.sup.within + spread.sup;
end
% compute the mean spread.sup across sup category
meanSpread.sup.within = meanSpread.sup.within / param.numCategory.sup;
meanSpread.sup.bet = meanSpread.sup.bet / param.numCategory.sup;


%% compute the spread of the bas category 
supPathIdx = repmat(1:param.numCategory.sup,[param.numCategory.bas,1]);
supPathIdx = reshape(supPathIdx,[1,param.numCategory.sup*param.numCategory.bas]);

for j = 1 : param.numCategory.sup*param.numCategory.bas
    % compute average basic path in semantic space
    for i = (1 + catSize.bas * (j-1)) : catSize.bas * j
        meanPath.bas = meanPath.bas + path{i};
    end
    meanPath.bas = meanPath.bas / catSize.bas;
    
    % get the spread between class
    % basMeanSpread = sum | basMeanPath - supMeanPath |  (for all bas in sup)
    meanSpread.bas.bet = meanSpread.bas.bet + abs(meanPath.bas - meanPath.sup{supPathIdx(j)});
    
    % sum the spread.sup of the individual path to the average path
    % basSpread = sum | path_i - basMeanPath |  (for all i in bas)
    for i = 1 : (1 + catSize.bas * (j-1)) : catSize.bas * j
        spread.bas = spread.bas + abs(path{i} - meanPath.bas);
    end
    % get the mean spread for one superordinate class
    meanSpread.bas.within = meanSpread.bas.within + spread.bas;
end
% compute the mean spread across sup category
meanSpread.bas.within = meanSpread.bas.within / (param.numCategory.sup*param.numCategory.bas);
meanSpread.bas.bet = meanSpread.bas.bet/ (param.numCategory.sup*param.numCategory.bas);




end

