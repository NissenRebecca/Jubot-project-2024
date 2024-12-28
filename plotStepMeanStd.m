% plotStepMeanStdPlot.m

function plotStepMeanStd(x, meanData, upperBound, lowerBound, upperBound_2, lowerBound_2)
    % Function to create the plot for mean and standard deviation
    
    % Check if the plotting is requested
    if nargin < 5
        error('Insufficient input arguments. Please provide x, meanData, upperBound, lowerBound, upperBound_2, and lowerBound_2.');
    end

    % Plotting
    figure();
    hold on;
    plot(x, meanData, 'k-', 'LineWidth', 2);
    % Plot the filled area
    %fill([x, fliplr(x)], [upperBound, fliplr(lowerBound)], [0.9 0.9 0.9], 'EdgeColor', 'none');
    
    plot(x, upperBound, 'k--');
    plot(x, lowerBound, 'k--');
    %plot(x, upperBound_2, 'k:');
    %plot(x, lowerBound_2, 'k:');


    % Additional plot settings
    yline(0);
    title('Knee - sagittal');
    ylabel('Angle (°)');
    xlabel('Gait Cycle (%)');
    %legend(Location="northwest");
    ylim([-10 80]);
    hold off;
end
