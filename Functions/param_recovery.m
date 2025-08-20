function [sim,recovparams,cc_prc,cc_obs] = param_recovery(data,options)
%PARAM_RECOVERY Recovers parameters for all parameters for all models
arguments (Input)
    data
    options
end

arguments (Output)
    sim
    recovparams
    cc_prc
    cc_obs
end

load(fullfile("Saved_Variables", "fitting.mat"));

for i = 1:numel(options.obsNames)
    for j = 1:numel(options.percNames)

        if options.obsNames{i} == "unitsq_mu3" && (options.percNames{j} == "rw" || options.percNames{j} == "sutton")
            continue
        end
        
        fits_prc.(options.obsNames{i}).(options.percNames{j}) = [];
        fits_obs.(options.obsNames{i}).(options.percNames{j}) = [];
        rec_prc.(options.obsNames{i}).(options.percNames{j}) = [];
        rec_obs.(options.obsNames{i}).(options.percNames{j}) = [];

        for h = 1:(data.NewRunIndex(end))
            
            sessiondata = data(data.NewRunIndex == h, :);

            sim.(options.obsNames{i}).(options.percNames{j})(h) = tapas_simModel(sessiondata.Correct_Side,...
                    options.percArgs{j}.model,...
                    fits.(options.obsNames{i}).(options.percNames{j})(h).p_prc.p,...
                    options.obsArgs{i}.model,...
                    fits.(options.obsNames{i}).(options.percNames{j})(h).p_obs.p);
            
            fits_prc.(options.obsNames{i}).(options.percNames{j}) = [fits_prc.(options.obsNames{i}).(options.percNames{j}); fits.(options.obsNames{i}).(options.percNames{j})(h).p_prc.p];
            fits_obs.(options.obsNames{i}).(options.percNames{j}) = [fits_obs.(options.obsNames{i}).(options.percNames{j}); fits.(options.obsNames{i}).(options.percNames{j})(h).p_obs.p];
            
            recovparams.(options.obsNames{i}).(options.percNames{j})(h) = tapas_fitModel(sim.(options.obsNames{i}).(options.percNames{j})(h).y,...
                    sessiondata.Correct_Side,...
                    options.percArgs{j},...
                    options.obsArgs{i},...
                    options.optim);

            rec_prc.(options.obsNames{i}).(options.percNames{j}) = [rec_prc.(options.obsNames{i}).(options.percNames{j}); recovparams.(options.obsNames{i}).(options.percNames{j})(h).p_prc.p];
            rec_obs.(options.obsNames{i}).(options.percNames{j}) = [rec_obs.(options.obsNames{i}).(options.percNames{j}); recovparams.(options.obsNames{i}).(options.percNames{j})(h).p_obs.p];

        end

        for k = 1:size(fits_prc.(options.obsNames{i}).(options.percNames{j}), 2)
            cc_prc.(options.obsNames{i}).(options.percNames{j})(k) = corr(fits_prc.(options.obsNames{i}).(options.percNames{j})(:, k), rec_prc.(options.obsNames{i}).(options.percNames{j})(:, k));
        end
        
        for k = 1:size(fits_obs.(options.obsNames{i}).(options.percNames{j}), 2)
            cc_obs.(options.obsNames{i}).(options.percNames{j})(k) = corr(fits_obs.(options.obsNames{i}).(options.percNames{j})(:, k), rec_obs.(options.obsNames{i}).(options.percNames{j})(:, k));
        end

    end
end

end