function allData = organizeExperimentData(dataDir)
    Ts = 0.1;
    Fs = 1/Ts;

    % 获取目录中所有的子文件夹
    folderList = dir(dataDir);
    folderList = folderList([folderList.isdir] & ~startsWith({folderList.name}, '.'));

    % 初始化一个结构体来存储数据
    allData = struct();

    % 遍历每个测试文件夹
    for folderIdx = 1:length(folderList)
        folderName = folderList(folderIdx).name;
        currentFolder = fullfile(dataDir, folderName);
        files = dir(fullfile(currentFolder, '*.csv'));

        % 读取所有CSV文件
        for fileIdx = 1:length(files)
            file = files(fileIdx);
            fileName = file.name;
            
             % 解析实验者序号和实验类型
            participantNum = regexp(fileName, '(?<=p_)\d+', 'match', 'once');
            experimentType = regexp(fileName, '(?<=exp_)[A-L]', 'match', 'once');
            
            % 确保participantNum和experimentType都不是空
            if isempty(participantNum) || isempty(experimentType)
                warning('Failed to parse participant number or experiment type from file name: %s', fileName);
                continue;  % 跳过当前文件的处理
            end

            participantField = ['p', participantNum];  % 构造有效的字段名

            % 检查当前参与者是否已经在allData中
            if ~isfield(allData, participantField)
                allData.(participantField) = struct();
            end
            
            % 检查该类型实验是否已经在该参与者下定义
            if ~isfield(allData.(participantField), experimentType)
                allData.(participantField).(experimentType) = {};
            end

            % 读取CSV文件并存储数据
            filePath = fullfile(currentFolder, file.name);
            csvData = readtable(filePath);
            allData.(participantField).(experimentType){end+1} = csvData;
            
            disp(participantField)
            disp(experimentType)
            

            % find steer time
            steer = find(diff(csvData.is_autonomous) < 0) + 1;
            if isempty(steer)
                reaction_time = NaN;
                dtw = NaN;
                avgFocus = NaN;
                maxbrake = NaN;
                maxsteer = NaN;
                avgsteer = NaN;
                abssteer = NaN;
                avgbrake = NaN;
                ped0val = NaN;
                ped1val = NaN;
                d_v = NaN;
                H_freq_pwr_P = NaN;
            else
                steer_time = csvData.time_s_(steer(end));
    
                % find start time
                start = find(diff(csvData.ped0_v_m_s_)>0) + 1;
                start_time = csvData.time_s_(start(1));
    
                % find reaction time
                reaction_time = steer_time-start_time;

                if (reaction_time < 0.1 || reaction_time > 3)
                    dtw = NaN;
                    avgFocus = NaN;
                    maxbrake = NaN;
                    maxsteer = NaN;
                    avgsteer = NaN;
                    avgbrake = NaN;
                    abssteer = NaN;
                    ped0val = NaN;
                    ped1val = NaN;
                    d_v = NaN;
                    H_freq_pwr_P = NaN;
                else
                    %find dtw
                    carx = csvData.car_x_m_(steer(end));
                    cary = -csvData.car_y_m_(steer(end));
                    ped0x = csvData.ped0_x_m_(steer(end));
                    ped0y = csvData.ped0_y_m_(steer(end));
                    ped1x = csvData.ped1_x_m_(steer(end));
                    ped1y = csvData.ped1_y_m_(steer(end));
                    ped0dtw = sqrt((carx-ped0x).*(carx-ped0x)+(cary-ped0y).*(cary-ped0y));
                    ped1dtw = sqrt((carx-ped1x).*(carx-ped1x)+(cary-ped1y).*(cary-ped1y));
                    dtw = 0.5*(ped0dtw+ped1dtw);
                    
                    % find gaze
                    gazex = csvData.gaze_x(start:steer(end));
                    gazey = csvData.gaze_y(start:steer(end));
                    ped0cx = csvData.ped0_cx(start:steer(end));
                    ped0cy = csvData.ped0_cy(start:steer(end));
                    ped1cx = csvData.ped1_cx(start:steer(end));
                    ped1cy = csvData.ped1_cy(start:steer(end));
                
                    ped0dist = sqrt((gazex-ped0cx).*(gazex-ped0cx)+(gazey-ped0cy).*(gazey-ped0cy));
                    ped1dist = sqrt((gazex-ped1cx).*(gazex-ped1cx)+(gazey-ped1cy).*(gazey-ped1cy));
                    for i = 1:length(gazex)
                        if ped0dist < 0.2
                            ped0focus = 1-5*ped0dist;
                        else
                            ped0focus = 0;
                        end
                    end
                    for i = 1:length(gazex)
                        if ped1dist < 0.2
                            ped1focus = 1-5*ped1dist;
                        else
                            ped1focus = 0;
                        end
                    end
                    avgFocus = mean(ped0focus)-mean(ped1focus);
                    
                    %gaze fft
                    focusplot = ped0focus-ped1focus;
                    Y = fft(focusplot);
                    L = length(focusplot);
                    P2 = abs(Y/L);
                    P1 = P2(1:L/2+1);
                    P1(2:end-1) = 2*P1(2:end-1);
                
                    pwr_after_2hz = sum(P1(floor(2/(Fs/L))+1:end));
                    total_pwr = sum(P1);

                    H_freq_pwr_P = pwr_after_2hz/total_pwr;
                    
                    % find steer
                    steercommand = csvData.controller_value_theta__turn_Max100_(steer:steer+9);
                    brakecommand = csvData.break___(steer:steer+9);
                    maxbrake = max(abs(brakecommand));
                    maxsteer = max(abs(steercommand));
                    avgsteer = mean(steercommand);
                    abssteer = abs(avgsteer);
                    avgbrake = mean(brakecommand);
        
                    %find dv
                    ped0id = csvData.ped0_val(1);
                    ped1id = csvData.ped1_val(1);
                    if strcmpi(ped0id, 'Pedophile') || strcmpi(ped0id, 'Rapist') || strcmpi(ped0id, 'Terrorist')
                        ped0val = 0;
                    else
                        if strcmpi(ped0id, 'Judge') || strcmpi(ped0id, 'Billionaire') || strcmpi(ped0id, 'Celebrity')
                            ped0val = 1;
                        else
                            ped0val = 2;
                        end
                    end
        
                    if strcmpi(ped1id, 'Pedophile') || strcmpi(ped1id, 'Rapist') || strcmpi(ped1id, 'Terrorist')
                        ped1val = 0;
                    else
                        if strcmpi(ped1id, 'Judge') || strcmpi(ped1id, 'Billionaire') || strcmpi(ped1id, 'Celebrity')
                            ped1val = 1;
                        else
                            ped1val = 2;
                        end
                    end
        
                    d_v = abs(ped0val - ped1val);
        
        
                    disp(ped0id)
                    disp(ped0val)
                end
            end


            csv_ana = table(reaction_time, dtw, avgFocus,H_freq_pwr_P,maxbrake,maxsteer,abssteer,avgsteer,avgbrake,ped0val,ped1val,d_v, ...
                'VariableNames', {'reaction_time', 'distance_to_walker', 'avg_focus_dist','high_freq','maxbrake','maxsteer','abssteer','avgsteer','avgbrake','ped0val','ped1val','d_v'});
            
            allData.(participantField).(experimentType){end+1} = csv_ana;


           
        end
    end
end
