ls
clear all; clc

trainModel = 1;

modelName = 'network.txt';
procFileName = '../procs.tcl';
trainFileName = 'train.txt';
conditions = {'normal', 'rapid'};
condition = conditions{1};
trainLength = 500;
maxEpoch = 10000;

subFolderName = '00';


allstages = '';
for epochs = trainLength: trainLength: maxEpoch
    if trainModel
        temp_train_text = sprintf('train %d; saveWeights %s/e%.2d.wt -text; ', trainLength, subFolderName, epochs/100);
    else
        temp_train_qtext = sprintf('loadWeights e%.2d.wt; ', epochs/100);
    end
    temp_test_text = sprintf('testAllActs %s/verbal_%s_e%.2d.txt VerbalRep; testAllActs %s/hidden_%s_e%.2d.txt hidden; ', ...
        subFolderName, condition, epochs/100, subFolderName, condition, epochs/100);
    reload_text = sprintf('loadExamples %s; ', trainFileName);
    onestage = strcat(temp_train_text, temp_test_text, reload_text);
    allstages = strcat(allstages, onestage);
    fprintf(onestage)
    fprintf('\n')
end
output = sprintf('lens -n -c %s " source %s; %s exit"', modelName, procFileName, allstages);

fprintf(output)
fprintf('\n')


