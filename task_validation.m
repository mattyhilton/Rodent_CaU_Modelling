close all; 
clear;

currentFolder = pwd;
addpath(genpath(currentFolder));

options = cau_options;

opts = detectImportOptions('Pre_Stress_Modelling_Data.csv');
opts = setvartype(opts, opts.VariableNames{1}, 'string'); 
data = readtable(strcat(options.folderlocation, filesep, "Data", filesep, "Pre_Stress_Modelling_Data.csv"), opts); 

%% Obtaining Bayes optimal priors
priors = obtain_bo_priors(data,options);
%% Sampling from Bayes optimal priors
sampling_from_priors(data,options);

%% Sampling from reduced Bayes optimal priors

two_level_model_config.priorsas = [NaN, 0, 0, NaN, 0, 0, 0, 0, NaN, 4, 0];
three_level_model_config.priorsas = [NaN, 0, .5, NaN, 0, .5, NaN, 0, 0, .5, 0, NaN, 2, 2];
ar1_model_config.priorsas = [NaN, 0, .5, NaN, 0, .5, NaN, 0, 0, NaN, 0, .5, NaN, 0, 0, .5, 0, NaN, 2, 2];

options.sampling = 2;

priors_sdhlv = sampling_from_priors(data,options);

%% Determining number of initialisations
% num_initialisations(data,options);

options.optim.nRandInit = 10;
%% Fitting models
[fits, lmes] = model_fitting(data,options);

%% Performing parameter recovery
[sim,cc_prc,cc_obs] = param_recovery(fits,options,data);

%% Performing model recovery
model_recovery(sim,data,options);

%% Performing model comparison
model_comparison(lmes, options)
