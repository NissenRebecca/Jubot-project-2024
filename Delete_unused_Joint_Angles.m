%% Matlab script to delete irrrelevant data from Jubot projet
% to improve computing time in subsequent script, only
% the necessary columns are considered
% 2023/09/12

clear

% Load the original data structure
loadedData = load('dataStruct_UPDATE.mat');
loadedData2 = load('dataStruct_VP07.mat');
loadedData3 = load('dataStruct_VP02_loaded07_cut.mat');
loadedData4 = load('dataStruct_VP06.mat');

%% Add VP07

% Names of the columns you want to keep
columnNamesToKeep = {'time', 'knee_angle_r', 'knee_angle_l', 'ankle_angle_r', 'ankle_angle_l'};

% Initialize a new data structure to store the filtered data and modified filenames
newDataStruct = struct('tableData', {}, 'Filename', {});

% Iterate through each entry in the first loaded data structure
for i = 1:length(loadedData.dataStruct)
    % Get the table for the current entry
    currentTable = loadedData.dataStruct(i).tableData;
    
    % Use only the specific columns you want to keep
    filteredTable = currentTable(:, columnNamesToKeep);
    
    % Get the original filename from the original data structure
    originalFilename = loadedData.dataStruct(i).filename;
    
    % Extract the desired portion of the filename using regular expressions
    modifiedFilename = regexp(originalFilename, '\./(\w+_\d+)_\d+_\d+', 'tokens', 'once');    
    
    % Add the filtered table and modified filename to the new data structure
    newDataStruct(i).tableData = filteredTable;
    newDataStruct(i).Filename = modifiedFilename;
end

%% Load the second data structure (VP07)

% Iterate through each entry in the second loaded data structure
for i = 1:length(loadedData2.dataStruct_VP07)
    % Get the table for the current entry
    currentTable = loadedData2.dataStruct_VP07(i).tableData;
    
    % Use only the specific columns you want to keep
    filteredTable = currentTable(:, columnNamesToKeep);
    
    % Get the original filename from the original data structure
    originalFilename = loadedData2.dataStruct_VP07(i).filename;
    
    % Extract the desired portion of the filename using regular expressions
    modifiedFilename = regexp(originalFilename, '\.\\(\w+_\d+)_\d+_\d+', 'tokens', 'once');
   
    
    % Add the filtered table and modified filename to the new data structure
    newDataStruct(end + 1).tableData = filteredTable;
    newDataStruct(end).Filename = modifiedFilename;
end


%% Load the third data structure (VP02 loaded07)

% Iterate through each entry in the second loaded data structure
for i = 1:length(loadedData3.dataStruct_VP02_cut)
    % Get the table for the current entry
    currentTable = loadedData3.dataStruct_VP02_cut(i).tableData;
    
    % Use only the specific columns you want to keep
    filteredTable = currentTable(:, columnNamesToKeep);
    
    % Get the original filename from the original data structure
    originalFilename = loadedData3.dataStruct_VP02_cut(i).filename;
    
    % Extract the desired portion of the filename using regular expressions
    modifiedFilename = regexp(originalFilename, '\\([^\\]+)_\d+_\d+', 'tokens', 'once');
   
    
    % Add the filtered table and modified filename to the new data structure
    newDataStruct(end + 1).tableData = filteredTable;
    newDataStruct(end).Filename = modifiedFilename;
end


%% Load the 4th data structure (VP06)

% Iterate through each entry in the second loaded data structure
for i = 1:length(loadedData4.dataStruct_VP06)
    % Get the table for the current entry
    currentTable = loadedData4.dataStruct_VP06(i).tableData;
    
    % Use only the specific columns you want to keep
    filteredTable = currentTable(:, columnNamesToKeep);
    
    % Get the original filename from the original data structure
    originalFilename = loadedData4.dataStruct_VP06(i).filename;
    
    % Extract the desired portion of the filename using regular expressions
    modifiedFilename = regexp(originalFilename, '\.\\(\w+_\d+)_\d+_\d+', 'tokens', 'once');
   
    
    % Add the filtered table and modified filename to the new data structure
    newDataStruct(end + 1).tableData = filteredTable;
    newDataStruct(end).Filename = modifiedFilename;
end


% Save the new data structure if needed
save('finalFinalDataStruct.mat', 'newDataStruct');

disp('All Done.');
