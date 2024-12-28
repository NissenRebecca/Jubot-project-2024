%% Matlab script to plot Joint angles from the JuBot project
%%
% README: just plot one VP at once
% change VP @ 'header'

close all;
clear;

%% Control Unit
% Change VP HERE
header = 'VP06';

disp("The current VP is: " + header);

% Select plots
plot_original_and_smoothed = false;
plot_all_steps = false;
plot_Max_Min_RoM = false;
plot_step_mean_std = false;
plot_run_order_RoM = true;
plot_mean_all_steps = true;


%% Load the data from 3 different files

% UPDATED main data
loadedData = load('finalFinalDataStruct.mat'); 

% UPDATED Data structure with the Initial contacts by Jonas
IC_extern = load('Data.mat');

% UPDATED information about all first frames
[num, txt, raw] = xlsread('VP_first frames_UPDATE.xlsx');
%% Match relevant data

headerIndex = find(strcmpi(header, txt(1, :)));
FF_column = num(:, headerIndex-1);  % minus 1 difference raw and num

% Initial Contat (IC_R) for the right leg

IC_loaded = IC_extern.Data.(header).loaded.IC_R;     
IC_loaded_firstframe = IC_loaded + FF_column(1);        

IC_loaded6 = IC_extern.Data.(header).loaded6.IC_R;     
IC_loaded6_firstframe = IC_loaded6 + FF_column(2);    

IC_loaded7 = IC_extern.Data.(header).loaded7.IC_R;   
IC_loaded7_firstframe = IC_loaded7 + FF_column(3);     

IC_unloaded = IC_extern.Data.(header).unloaded.IC_R;   
IC_unloaded_firstframe = IC_unloaded + FF_column(4);   

switch header
    case 'VP02';array_in_dataStruct = [1,2,67,5];          % VP02, (3/4) error -> 67
    case 'VP03';array_in_dataStruct = [6,7,8,9];           % VP03
    case 'VP04';array_in_dataStruct = [10,11,12,13];       % VP04
    case 'VP05';array_in_dataStruct = [14,15,16,17];       % VP05
    %case 'VP06';array_in_dataStruct = [18,19,20,21];      % VP06 - old data
    case 'VP08';array_in_dataStruct = [22,23,24,25];       % VP08, new VP07 below!
    case 'VP09';array_in_dataStruct = [26,27,28,30];       % VP09, (29) error
    case 'VP10';array_in_dataStruct = [31,32,33,34];       % VP10
    case 'VP11';array_in_dataStruct = [35,36,37,38];       % VP11
    case 'VP12';array_in_dataStruct = [39,40,41,42];       % VP12
    case 'VP13';array_in_dataStruct = [43,44,45,46];       % VP13
    case 'VP14';array_in_dataStruct = [47,48,49,50];       % VP14
    case 'VP15';array_in_dataStruct = [51,52,53,54];       % VP15
    case 'VP16';array_in_dataStruct = [55,56,57,58];       % VP16
    case 'VP17';array_in_dataStruct = [59,60,61,62];       % VP17
    case 'VP07';array_in_dataStruct = [63,64,65,66];       % VP07
    case 'VP06';array_in_dataStruct = [68,69,70,71];       % VP06 NEW
    otherwise
        % Handle cases when 'header' doesn't match any of the specified values.
        error('Unknown header: %s', header);
end

% Initialize variable to compare all RoM and all MEAN
all_ROM = [];
all_MEAN = [];


for index=1:length(array_in_dataStruct)
    
    % Assign the relevant data for the Initial contacts
    % the order of the runs (not the plots!) remains always the same:
    % loaded01, loaded06, loaded07, unloaded01

    if index == 1
        IC_and_FF = IC_loaded_firstframe; 
    elseif index == 2
        IC_and_FF = IC_loaded6_firstframe; 
    elseif index == 3
        IC_and_FF = IC_loaded7_firstframe; 
    elseif index == 4
        IC_and_FF = IC_unloaded_firstframe; 
    else
        disp('error!');
    end

    %% Lowpass Filter
    % apply Lowpass filter to the data to reduce noise

    fs = 1/0.005;
    fpass = 6;      % 6 Hz according to literature
    
    % consider just right knee angle here
    % left knee angle does not deliver more information
    filter_knee_angle_r = lowpass(loadedData.newDataStruct(array_in_dataStruct(index)).tableData.knee_angle_r, fpass, fs);
    
    %% Plot 1: Original and smoothed data
    if plot_original_and_smoothed
        plotOriginalAndSmoothed(loadedData, array_in_dataStruct(index), IC_and_FF);
    end
          
    
    %% Segmentation of every step
    % The information about the initial contacts is by Jonas
    
    % Initialize cell array to store segments
    segments = cell(1, numel(IC_and_FF) - 1);
    
    % New segment @ each IC frame
    for i = 1:numel(IC_and_FF) - 1
        
        start_idx = IC_and_FF(i);
        end_idx = IC_and_FF(i + 1);
        
        if end_idx <= length(filter_knee_angle_r)

            % Extract the segment of data between maxima
            segment = filter_knee_angle_r(start_idx:end_idx);            
            
            % A normalization is done to get every step the same length
                desired_time_points = 100;      % number of the time points after the normalization (100 % --> 100)
                n = length(segment);            % number of data points of data to normalize
                t = (0:fs:(n-1)*fs);            % new sampling points
                t_norm = linspace(0, t(end), desired_time_points);
                data_normalized = interp1(t, segment, t_norm, 'spline');              

            % Save the segment in the cell array
            segments{i} = data_normalized;

            % just to try normaliazion vs. non-normalization
            % segments{i} = segment;
        else
            % disp('Out of range')
        end
    end   
    
    %% Plot 2: Show all the segments in one single plot
    if plot_all_steps
        plotAllSegments(segments);
    end
    
    %% New Feature: MIN, MAX and RoM in each segment

    segment_maximum = [];
    segment_minimum = [];
    segment_ROM = [];     
    
    for i = 1:length(segments)
        current_maximum = max(segments{1,i});
        current_minimum = min(segments{1,i});
        current_ROM = current_maximum - current_minimum;
           
        segment_maximum = [segment_maximum, current_maximum];
        segment_minimum = [segment_minimum, current_minimum];
        segment_ROM = [segment_ROM, current_ROM];               
    end
    
    % store all ROM in a row vector
    segment_ROM_transpose = transpose(segment_ROM);     

    % also, make sure, they are all the same length: 200 steps
    all_ROM = [all_ROM, segment_ROM_transpose(1:200)];   
        
    %% Plot 3: MAX and MIN and RoM

    if plot_Max_Min_RoM
        plotMinMaxRoM(segment_maximum, segment_minimum, segment_ROM);
    end

    %% Calculations for Plot 4          
        allSegmentData = [];     
        
        % Loop through the segments and store data in allsegmentData table
        for i = 1:numel(segments) 
            segmentData = segments{1,i}';
            
            % Store the segments in allSegmentData
            allSegmentData = [allSegmentData, segmentData];
        end

        % Calculate the mean and standard deviation across all segments         
        meanData = mean(allSegmentData,2);
        stdData = std(allSegmentData, 0, 2); 
        
        % Store all mean
        all_MEAN = [all_MEAN, meanData]; 

        % Define x-axis values
        x = (1:length(meanData))'; 
        
        % Calculate the upper and lower bounds
        upperBound = meanData + stdData;
        lowerBound = meanData - stdData;
        upperBound_2 = meanData + stdData*2;
        lowerBound_2 = meanData - stdData*2;        
        
    %% Plot 4: Mean plot of step (like in liteareture with std)
    if plot_step_mean_std == true
        plotStepMeanStd(x, meanData, upperBound, lowerBound, upperBound_2, lowerBound_2);
    end

end % big for loop ends 

hold off;

%% Smoothing data

% Apply (small) moving average filter
% do not use moving average
window_size = 5;

smoothed_all_ROM = smoothdata(all_ROM, 'movmean', window_size);

% Block wise mean
groupSize = 5;
dataMatrix = all_ROM;
% Calculate the number of groups
numGroups = floor(size(dataMatrix, 1) / groupSize);

% Initialize a matrix to store the means
groupMeansMatrix = zeros(numGroups, size(dataMatrix, 2));

% Calculate the mean for each group and each column
for col = 1:size(dataMatrix, 2)
    for i = 1:numGroups
        startIndex = (i - 1) * groupSize + 1;
        endIndex = startIndex + groupSize - 1;
        groupMeansMatrix(i, col) = mean(dataMatrix(startIndex:endIndex, col));
    end
end

%smoothed_all_ROM = groupMeansMatrix;


% Use function to smoothe data
% input 1xN vector
% did not work as expected, no exponential form?
% 1 for plot, 0 for no plot

smoothed_all_ROM_1 = fit_progression(smoothed_all_ROM(:,1)',0);
smoothed_all_ROM_2 = fit_progression(smoothed_all_ROM(:,2)',0);
smoothed_all_ROM_3 = fit_progression(smoothed_all_ROM(:,3)',0);
smoothed_all_ROM_4 = fit_progression(smoothed_all_ROM(:,4)',0);

%smoothed_all_ROM = [smoothed_all_ROM_1', smoothed_all_ROM_2', smoothed_all_ROM_3', smoothed_all_ROM_4'];



%% Plot 5: All 4 RoM in right order

% Run-Order 1: loaded01, loaded06, loaded08, unloaded01
% Run-Order 2: unloaded01, loaded01, loaded06, loaded08

if any(strcmp(header, {'VP03','VP04','VP05','VP10','VP12','VP13','VP14','VP17', 'VP07'}))
    %IMPORTANT: visualize as if unloaded01 was 1st each time
    %run_order = 1;
    run_order = 2;
elseif any(strcmp(header, {'VP02','VP06','VP08','VP09','VP11','VP15','VP16'}))
    run_order = 2;
else
    run_order = 0;
end

% How many steps should be considered?
% must be changed when changing smoothing method
stop_step = 200;

disp("The run order is: " + run_order);
disp("The stop step is: " + stop_step);


% Plot
if plot_run_order_RoM == true 

        if run_order == 1          
            figure();
            plot(1:stop_step, smoothed_all_ROM(1:stop_step,1), '-o');
            hold on;
            plot(stop_step+1:2*stop_step, smoothed_all_ROM(1:stop_step,2), '-o');
            plot(2*stop_step+1:3*stop_step, smoothed_all_ROM(1:stop_step,3), '-o');
            plot(3*stop_step+1:4*stop_step, smoothed_all_ROM(1:stop_step,4), '-o');

            xline(stop_step);
            xline(2*stop_step);
            xline(3*stop_step);    
            
            % the legend and order is always the same
            legend('loaded01', 'loaded06', 'loaded07', 'unloaded01');
            ylim([40, 75]);
            
            % Additional plot settings
            title('Knee - sagittal');
            ylabel('Range of Motion (°)');
            xlabel('Steps');
            %legend(Location="northwest");
            hold off;
        
        elseif run_order == 2
            figure();
            plot(1:stop_step, smoothed_all_ROM(1:stop_step,4), '-o');
            hold on;
            plot(stop_step+1:2*stop_step, smoothed_all_ROM(1:stop_step,1), '-o');
            plot(2*stop_step+1:3*stop_step, smoothed_all_ROM(1:stop_step,2), '-o');
            plot(3*stop_step+1:4*stop_step, smoothed_all_ROM(1:stop_step,3), '-o');
            
            xline(stop_step);
            xline(2*stop_step);
            xline(3*stop_step);    
            
            % the legend is changed
            legend('unloaded01', 'loaded01', 'loaded06', 'loaded07');
            ylim([40, 75]);
            % Additional plot settings
            title('Knee - sagittal');
            ylabel('Range of Motion (°)');
            xlabel('Steps');
            %legend(Location="northwest");
            hold off;
        
        elseif run_order == 0
            disp('Problem')
        end
end

%% Plot 6: all 4 MEAN steps
% better to compare difference within steps

if plot_mean_all_steps == true
    figure();
    plot(all_MEAN(:,4));
    hold on;
    plot(all_MEAN(:,1));
    plot(all_MEAN(:,2));
    plot(all_MEAN(:,3));
    hold off;
    
    legend('unloaded01','loaded01', 'loaded06', 'loaded07');
    xlabel('% of step');
    ylabel('Mean of Knee joint angle (Degrees)');
    title('Mean RoM of the 4 different runs');
    %ylim([0,90]);
    %ylim([40, 70]);
end

disp('All Done');


%% Feature Extraction for statistical analysis

% Extract the first column (loaded01) means
mean_loaded01_00_05 = mean(all_ROM(1:5, 1));    
mean_loaded01_45_50 = mean(all_ROM(45:55, 1));        

% Extract the fourth column (unloaded01) means
mean_unloaded01_00_05 = mean(all_ROM(1:5, 4));       
mean_unloaded01_196_200 = mean(all_ROM(196:200, 4)); 

