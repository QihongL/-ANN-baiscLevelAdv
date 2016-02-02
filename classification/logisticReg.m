%% Logistic regression classifier
% it TAKES a data set and a cross-validation block
% it RETURNS the cross-validated accuracy
function [meanAccuracy, meanResponse, meanDeviation] = logisticReg(data, CVB, param, showresults)
%% obtain the predictors and responses
X = data(: , 1 : (size(data,2) - 1));
y = data(:, size(data,2));

%% inject random normal noise (this might be important!)
X = X + normrnd(0,param.variance, size(X));
%% pre-process the data in accordance to the "classification option"
if param.classOpt == 1
    X = mean(X,2);
elseif param.classOpt == 2
    if param.subsetProp > 1 
        error('ERROR: subset Proportion should be less than 1!')
    end
    % select random subset of the data
    subset.numUnits = round(size(X,2) * param.subsetProp);
    subset.ind = randsample(size(X,2),subset.numUnits);
    X = X(:,subset.ind);
end

%% separate the training and testing sets
Xtest = X(CVB,:);
ytest = y(CVB,:);
Xtrain = X(~CVB,:);
ytrain = y(~CVB,:);

%% Compute Cost and Gradient using fminunc
%  Setup the data matrix appropriately, and add ones for the intercept term
[m, n] = size(Xtrain);
% Add the intercept term to the design matrix
Xtrain = [ones(m, 1) Xtrain];

% Initialize fitting parameters and options
initial_beta = zeros(n + 1, 1);
options = optimset('GradObj', 'on', 'MaxIter', 400);
%  Run fminunc to obtain the optimal beta
if showresults
    disp('Weights estimation in progress...')
end
beta = fminunc(@(t)(costFunction(t, Xtrain, ytrain)), initial_beta, options);

%% Predict and Accuracies
% compute the prediction
Xtest = [ones(size(Xtest,1), 1) Xtest]; % add the intercept term
rawPrediction = sigmoid(Xtest * beta);
predictedLabels  = rawPrediction >= 0.5;

% deviation = L1 norm (difference between prediction values and truth), 
% this is more sensitive than accuracy
deviation = sum(abs(rawPrediction - ytest));

%% compute the mean 
% meanResponse = sum(rawPrediction) / length(rawPrediction);
meanAccuracy = mean(double(predictedLabels == ytest)) * 100;
meanDeviation = deviation / length(rawPrediction);
meanResponse = mean([mean(rawPrediction(logical(ytest))), (1-mean(rawPrediction(~logical(ytest)))) ]);



%% show the results
if showresults
    % print the comparison between model response and the truth
    [rawPrediction , ytest]
    % Compute accuracy on our training set    
    fprintf('Cross-validated Accuracy: %.3f\n', meanAccuracy);
    disp('Done!')
end

end



