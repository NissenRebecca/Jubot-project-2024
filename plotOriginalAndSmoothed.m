% plotOriginalAndSmoothed.m

function plotOriginalAndSmoothed(dataStruct, arrayIndex, IC_and_FF)
    % Function to plot original and smoothed knee angle data
    
    % Check if the plotting is requested
    if nargin < 3
        error('Insufficient input arguments. Please provide dataStruct, arrayIndex, and IC_and_FF.');
    end

    % Plotting
    figure()
    plot(dataStruct.newDataStruct(arrayIndex).tableData.knee_angle_r, 'b-', 'LineWidth', 1);
    hold on;
    xline(IC_and_FF, 'r--');
    
    % Additional plot settings
    legend('Original Data', 'IC');    
    title('Knee - sagittal');
    ylabel('Angle (°)');
    xlabel('Frames');
    %legend(Location="northwest");
    ylim([-10 80]);
    
    hold off;
end
