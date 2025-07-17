function [fits, lmes] = model_fitting(data,options)
%model_fitting Fits all the data to each model and prints a graph of the
%model fit

arguments (Input)
    data
    options
end

arguments (Output)
    fits
    lmes
end

cd("Saved_Variables")

if isfile('model_fitting.mat') == 1
    load('model_fitting.mat');
else
fits = [];
lmes = [];
end

cd ..

set(groot,'defaultFigureVisible','off'); 

for i = 1:numel(options.obsNames)
    for j = 1:numel(options.percNames)
        
        filename = "Fitted_" + options.percNames{j} + options.obsNames{i} + ".pdf";

        cd(fullfile("Graphs", "Fitting"))

        if isfile(filename) == 1
            info = pdfinfo(filename);
            numFigures = info.NumPages;
            
            if numFigures >= data.NewRunIndex(end)
            continue    

            else
                delete(filename);
            end
        end
        
        for h = 1:(data.NewRunIndex(end))
        
        sessiondata = data(data.NewRunIndex == h, :);

        if options.obsNames{i} == "unitsq_mu3" && (options.percNames{j} == "rw" || options.percnames{j} == "sutton")
        continue
        end
        
        fits.(options.obsNames{i}).(options.percNames{j})(h) = tapas_fitModel(sessiondata.Choice,...
                                                 sessiondata.Correct_Side,...
                                                 options.percArgs{j},...
                                                 options.obsArgs{i},...
                                                 options.optim);
    
        if j == 1
            tapas_rw_binary_plotTraj(fits.(options.obsNames{i}).(options.percNames{j})(h));
        elseif j == 5
            tapas_sutton_k1_binary_plotTraj(fits.(options.obsNames{i}).(options.percNames{j})(h));
        else
            tapas_ehgf_binary_plotTraj(fits.(options.obsNames{i}).(options.percNames{j})(h));
        end
        
        fig = gcf;
        exportgraphics(fig, filename, 'Append', true);

        lmes.(options.obsNames{i}).(options.percNames{j})(h, :) = fits.(options.obsNames{i}).(options.percNames{j})(h).optim.LME;

        end
        
        cd ..
        cd ..
        cd("Saved_Variables")

        save("fitting.mat", "lmes", "fits")

        cd ..
        cd(fullfile("Graphs", "Fitting"))

    end
end

set(groot,'defaultFigureVisible','on'); 

end