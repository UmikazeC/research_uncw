function correlationplotSCENE(consolidatedTable)
     % 初始化一个空的 table 用于开始合并过程
    exp = table();
    
    % 遍历 consolidatedTable 中的每个 table
    for j = 1:4
        
        for i = 1:3
            currentTable = consolidatedTable{(j-1)*3+i};
            
            % 检查当前元素是否为 table
            if ~istable(currentTable)
                error('Each item in the cell array must be a table.');
            end
            
            % 如果是第一个 table，直接将其赋值给 combinedTable
            if i == 1
                exp = currentTable;
            else
                % 合并当前 table 到已有的 combinedTable 中
                exp = vertcat(exp, currentTable);
            end
        end
    
        % Create a matrix of variables for correlation analysis
        variables = [exp.reaction_time exp.distance_to_walker exp.avg_focus_dist exp.high_freq exp.maxbrake exp.maxsteer exp.avgsteer exp.abssteer exp.avgbrake exp.d_v];
        
        % Step 3: Compute Correlation Matrix
        correlation_matrix = corr(variables, 'Rows', 'complete');
        figure()
        % Visualize Correlation Matrix using Heatmap
        labels = {'reaction_time', 'distance to walker', 'avg focus dist', 'high_freq', 'maxbrake', 'maxsteer', 'avgsteer','abssteer', 'avgbrake', 'd_v'};
        h = heatmap(labels, labels, correlation_matrix);
        h.Title = 'Heatmap of Correlation Matrix';
        h.XLabel = 'Variables';
        h.YLabel = 'Variables';
        h.Colormap = jet;  % Use jet colormap for better color contrast
        h.ColorLimits = [-1 1];  % Set color limits from -1 to 1 to show full range of correlation

         figure;
         boxplot(exp.avgsteer);
         title('Boxplot of steering');
         xlabel('All exps');
         ylabel('reaction_time');
        % figure;
        % scatter(exp.maxbrake, exp.avgbrake);
        % title('Scatter Plot of maxbrake vs. avgbrake');
        % xlabel('maxbrake');
        % ylabel('avgbrake');
    end
end