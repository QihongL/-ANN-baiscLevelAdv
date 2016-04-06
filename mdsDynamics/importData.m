function [ data, nTimePts ] = importData( PATH, FILENAME, param)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% read prototype and parameters

% read data
PATH.DATA = genDataPath(PATH, FILENAME.ACT);
data = dlmread(PATH.DATA,' ', 0,2);
data(:,size(data,2)) = []; % last column are zeros (reason unknown...)
nTimePts = 25;    % you probably don't want to change it..
data(1 + (0:param.numStimuli-1)*(nTimePts+1),:) = []; % remove zero rows

end

