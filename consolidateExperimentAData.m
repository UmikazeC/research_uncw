function consolidatedTables = consolidateExperimentAData(allData)
    % 初始化一个 cell 数组来存储每种实验类型的整合表格
    experimentTypes = 'A':'L';  % 实验类型从 A 到 L
    consolidatedTables = cell(size(experimentTypes));

    % 遍历所有实验类型
    for k = 1:length(experimentTypes)
        type = experimentTypes(k);
        % 为当前实验类型初始化一个空的表格
        consolidatedTable = table([], [], [], [], [], [], [], [], [], [], [],[], ...
            'VariableNames', {'reaction_time', 'distance_to_walker', 'avg_focus_dist','high_freq','maxbrake','maxsteer','avgsteer','abssteer','avgbrake','ped0val','ped1val','d_v'});
        % 遍历allData结构体中所有的实验者
        participantFields = fieldnames(allData);
        for i = 1:length(participantFields)
            participantField = participantFields{i};

            % 检查当前实验类型是否存在
            if isfield(allData.(participantField), type)
                experimentData = allData.(participantField).(type);

                % 确保是表格类型然后整合数据
                if istable(experimentData{1, 2})
                    consolidatedTable = [consolidatedTable; experimentData{1, 2}];
                end
            end
        end
        
        % 存储当前实验类型的整合表格到cell数组中
        consolidatedTables{k} = consolidatedTable;
    end
end
