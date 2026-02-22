function exp_r = model_comparison(lmes,options)
%MODEL_COMPARISON Compares models using random Bayesian selection
%   See SPM toolbox and Stephan et al. (2009)
arguments (Input)
    lmes
    options
end

arguments (Output)
    exp_r
end

lmes_path = fullfile(pwd, "Saved_Variables");
graph_path = fullfile(pwd, "Graphs", "Model Comparison", "Model_Comparison.pdf");

set(groot,'defaultFigureVisible','off');

if isfile(lmes_path) == 1
    load(var_path, 'lmes');
end

lme_array = [];
x = [];

obsCount = numel(options.obsNames);
percCount = numel(options.percNames);
lme_array = zeros(1, obsCount * percCount); % Preallocate for efficiency
x = strings(1, obsCount * percCount); % Preallocate for efficiency

index = 1; % Initialize index for lme_array and x
for i = 1:obsCount
    for j = 1:percCount
        lme_array(index) = lmes.(options.obsNames{i}).(options.percNames{j});
        x(index) = strcat(options.obsNames{i}, options.percNames{j});
        index = index + 1; % Increment index
    end
end
[alpha, exp_r, xp, pxp, bor] = spm_BMS(lme_array);

bar(x, exp_r)
ylabel("p(r|y)")

fig = gcf;
exportgraphics(fig, graph_path);

set(groot,'defaultFigureVisible','off');

end