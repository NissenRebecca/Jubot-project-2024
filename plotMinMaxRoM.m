% plotMinMaxRoM.m

function plotMinMaxRoM(segment_maximum, segment_minimum, segment_ROM)
    % Function to plot MAX, MIN, and RoM
    
    % Check if the plotting is requested
    if nargin < 3
        error('Insufficient input arguments. Please provide all three vectors.');
    end

    % Plotting
    figure()
    plot(segment_maximum, '-', 'Color', 'r');
    hold on;
    plot(segment_minimum, '-', 'Color', 'b');
    plot(segment_ROM, '-', 'Color', 'g');

    % Labels and title
    xlabel('Steps');
    ylabel('Knee Angle in Degree');
    title('Extracted features from the segmented steps');
    legend('MAX', 'MIN', 'RoM');
end
