function [sim,cc_prc,cc_obs] = param_recovery(fits,options,data)
%param_recovery Performs parameter recovery for all models

arguments (Input)
    fits
    options
    data
end

arguments (Output)
    sim
    cc_prc
    cc_obs
end

fit_prc = [];
fit_obs = [];
recov_prc = [];
recov_obs = [];
cc_prc = [];
cc_obs = [];

set(groot,'defaultFigureVisible','off'); 

cd(fullfile("Graphs", "Param_Recovery"))

for i = 1:numel(options.obsNames)
    for j = 1:numel(options.percNames)
        
        filename = "Param_Recovery_" + options.percNames{j} + options.obsNames{i} + ".pdf";

        cd(fullfile("Graphs", "Param_Recovery"))

        if isfile(filename) == 1
            info = pdfinfo(filename);
            numFigures = info.NumPages;
            
            if numFigures >= data.NewRunIndex(end)
            continue    

            else
                delete(filename);
            end
        end
        
        if options.obsNames{i} == "unitsq_mu3" && (options.percNames{j} == "rw" || options.percnames{j} == "sutton")
        continue
        end


        for  h = 1:(data.NewRunIndex(end))
            sessiondata = data(data.NewRunIndex == i, :);
            
            sim.(options.obsNames{i}).(options.percNames{j})(h) = tapas_simModel(sessiondata.Correct_Side,...
                options.percArgs{j},...
                fits.(options.obsNames{i}).(options.percNames{j})(h).p_prc.p,...
                options.obsArgs{i},...
                fits.(options.obsNames{i}).(options.percNames{j})(h).p_obs.p);
        
            recover_fit = tapas_fitModel(sim.(options.obsNames{i}).(options.percNames{j})(h).y,...
                sessiondata.Correct_Side,...
                options.percArgs{j},...
                options.obsArgs{i},...
                options.optim);
        
            fit_prc.(options.obsNames{i}).(options.percNames{j}) = [fit_prc.(options.obsNames{i}).(options.percNames{j}); fits.(options.obsNames{i}).(options.percNames{j})(h).p_prc.p];
            recov_prc.(options.obsNames{i}).(options.percNames{j}) = [recov_prc.(options.obsNames{i}).(options.percNames{j}); recover_fit.p_prc.p];

            fit_obs.(options.obsNames{i}).(options.percNames{j}) = [fit_obs.(options.obsNames{i}).(options.percNames{j}); fits.(options.obsNames{i}).(options.percNames{j})(h).p_obs.p];
            recov_obs.(options.obsNames{i}).(options.percNames{j}) = [recov_obs.(options.obsNames{i}).(options.percNames{j}); recover_fit.p_obs.p];

        end
        
        for k = 1:size(fit_prc.(options.obsNames{i}).(options.percNames{j}), 2)
        scatter(fit_prc.(options.obsNames{i}).(options.percNames{j}), recov_prc.(options.obsNames{i}).(options.percNames{j})(:,k));
        filename = "Recov_Prc_" + options.percNames{j} + options.obsNames{i} + ".pdf";
        
        fig = gcf;
        exportgraphics(fig, filename, 'Append', true);

        cc_prc.(options.obsNames{i}).(options.percNames{j}) = [cc_obs.(options.obsNames{i}).(options.percNames{j}), ...
            corrcoef(fit_prc.(options.obsNames{i}).(options.percNames{j})(:,k), recov_prc.(options.obsNames{i}).(options.percNames{j})(:,k))]
        end

        for l = 1:size(fit_obs.(options.obsNames{i}).(options.percNames{j}), 2)
        scatter(fit_obs.(options.obsNames{i}).(options.percNames{j})(:,l), recov_obs.(options.obsNames{i}).(options.percNames{j})(:,l));
        filename = "Recov_Obs_" + options.percNames{j} + options.obsNames{i} + ".pdf";
        
        fig = gcf;
        exportgraphics(fig, filename, 'Append', true);

        cc_obs.(options.obsNames{i}).(options.percNames{j}) = [cc_obs.(options.obsNames{i}).(options.percNames{j}), ...
            corrcoef(fit_obs.(options.obsNames{i}).(options.percNames{j})(:,l), recov_obs.(options.obsNames{i}).(options.percNames{j})(:,l))]
        end
    end
end

set(groot,'defaultFigureVisible','on');
cd ..
cd ..

end