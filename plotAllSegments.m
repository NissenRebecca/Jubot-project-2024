% plotAllSegments.m

function plotAllSegments(segments)
    % Function to plot all segments in one single plot
    
    % Check if the plotting is requested
    if nargin < 1
        error('Insufficient input arguments. Please provide the cell array of segments.');
    end

    % Plotting
    figure()
    for i = 1:numel(segments)
        plot(segments{i});
        hold on;
        %pause(1);  % Uncomment if you want to plot each segment separately
    end

   
    % Additional plot settings
    yline(0);
    title('Knee - sagittal');
    ylabel('Angle (°)');
    xlabel('Gait Cycle (%)');
    %legend(Location="northwest");
    ylim([-10 80]);
    hold off;
end
