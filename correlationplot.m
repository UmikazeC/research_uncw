function exp=correlationplot(consolidatedTable,experimentIndex)

    if experimentIndex > length(consolidatedTable) || experimentIndex < 1
        error('Invalid experiment index. Please provide a correct index.');
    end
    
    exp = consolidatedTable{1,experimentIndex};

    if ~istable(exp)
        error('Expected a table in the cell, but something else was found.');
    end

    % Create a matrix of variables for correlation analysis
    variables = [exp.reaction_time exp.distance_to_walker exp.avg_focus_dist exp.high_freq exp.maxbrake exp.maxsteer exp.avgsteer exp.avgbrake exp.d_v];
    
    % Step 3: Compute Correlation Matrix
    correlation_matrix = corr(variables, 'Rows', 'complete');
    
    % Visualize Correlation Matrix using Heatmap
    labels = {'reaction_time', 'distance to walker', 'left focus avg dist', 'right focus avg dist', 'high_freq', 'maxbrake', 'maxsteer', 'avgsteer', 'avgbrake', 'd_v'};
    h = heatmap(labels, labels, correlation_matrix);
    h.Title = 'Heatmap of Correlation Matrix';
    h.XLabel = 'Variables';
    h.YLabel = 'Variables';
    h.Colormap = jet;  % Use jet colormap for better color contrast
    h.ColorLimits = [-1 1];  % Set color limits from -1 to 1 to show full range of correlation
    
end