%% Matlab script to read in MOT-files
% 1. script: read in .mot and convert all rad in deg

clear;
clc;
close all;

% Initialize a structure to store the data
dataStruct = struct();
files = dir('*.mot');

% Read in data
startRow = 0;
    
for i = 1:size(files)

    % FOR MAC
    % filename = ['./', files(i).name];
    
    % FOR WINDOWS       
    filename = ['.\', files(i).name];
    %filename = [files(i).name];
          
    % Initialize data to an empty array and read in data
    data = []; 

    while isempty(data)
        try
            % Delimiter Tab; Offset row; offset column
            data = dlmread(filename, '\t', startRow, 0); 
        catch
            fprintf('Error reading data from %s at startRow = %d\n', filename, startRow);
            startRow = startRow + 1;
        end
    end

    [~,nCols] = size(data);

    % Read in column names
    fid=fopen(filename,'r'); 
    format = '%s';                      % into string 
    Spec = repmat(format, 1, nCols);
    
    % open text file into cell array
    C = textscan(fid,Spec,1,'delimiter','\t', 'headerlines',startRow-1); 

    for j = 1 : length(C)
         if strcmp(C{j},'Time')
            C{j} = {'time'};
        end
        
        if strcmp(C{j},'')
            C{j} = {['Unknow_', num2str(j)]};
        end
        
        if contains(C{j},'#')
            disp(j)
            C{j} = strrep(C{j},'#','');
        end      
    end
    
    % Concenate horizontally
    C =horzcat(C{:});
    
    % Finish
    tableData = array2table(data,'VariableNames', C);


    % Solve the Degree/Radian problem
    % List of column names in Degree
    % Add TIME to keep it original
    columnNamesInDegree = {'time', 'pelvis_rotation', 'arm_add_l', 'lumbar_bending', ...
        'elbow_flex_l', 'pelvis_tilt', 'pro_sup_l', 'knee_angle_r', ...
        'hip_flexion_l', 'pelvis_list', 'lumbar_rotation', 'lumbar_extension',...
        'elbow_flex_r', 'pro_sup_r', 'arm_add_r'};  % Achtung: neue columns
    
    % Factor for conversion from RAD to DEG
    factor = (360/(2*pi)); 
    
    tableData_old = tableData;
    % Get the list of variable names in the table
    allColumns = tableData.Properties.VariableNames;
    
    % Identify columns for multiplication (exclude columns to skip)
    columnsToMultiply = setdiff(allColumns, columnNamesInDegree);

    % Iterate through columns for multiplication and perform multiplication
    for k = 1:length(columnsToMultiply)
        columnName = columnsToMultiply{k};
        tableData.(columnName) = tableData.(columnName) * factor;
    end

    % Store the tableData in the structure
    dataStruct(i).tableData = tableData;        
    dataStruct(i).filename = filename;
    
    % Display loaded data size
    fprintf('Loaded data size from %s: %dx%d\n', filename, size(tableData, 1), size(tableData, 2));
    
    % Optional: Display progress
    %fprintf('Loaded file %d ', i );
    fprintf('Loaded file %d of %d\n', i, size(files));
    fprintf(' \n')
end



