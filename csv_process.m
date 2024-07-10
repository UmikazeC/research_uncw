clc
clear
close all
warning('off')

Ts = 0.1; % sample time for csv

% Let user select a directory
dataDir = uigetdir();

% Get all csvs
csvfiles =  organizeExperimentData(dataDir);

% consolidatedTable
consolidatedTable = consolidateExperimentAData(csvfiles);

%correlation analyze: same scene

correlationplotSCENE(consolidatedTable);

%correlation analyze: same d_v

%correlationplotDV(consolidatedTable);




