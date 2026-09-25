function Brexit_PlotIRF(mixedesign_irfboot, mixedsign_irfPointestimate, n, H, labels)
% BREXIT_PLOTIRF Generates the final Impulse Response Functions with Confidence Bands.
%
% INPUTS:
%   mixedesign_irfboot         : Bootstrap raw data [Vars x Shock x Horizon x Boots]
%   mixedsign_irfPointestimate : Median/Point estimate [Vars x Horizon]
%   n                          : Number of variables
%   H                          : Time horizon
%   labels                     : Variable names (string array)

    figure('Name', 'Brexit Shock - Final Report', 'NumberTitle', 'off', 'Color', 'w');

    % Define percentiles for 68% confidence interval
    pct_bands = [16 84]; 

    for i = 1:n
        subplot(3, 2, i); 
        hold on; 
        
        % 1. Extract Raw Bootstrap Data for Variable 'i'
        % Dimensions are usually [n x 1 x H x Boots]. 
        % We squeeze it to get [H x Boots]
        raw_data_boot = squeeze(mixedesign_irfboot(i, 1, :, :)); 
        
        % 2. Calculate Percentiles (The Red Bands)
        % Calculate 16th and 84th percentile across the 1000 boots (dimension 2)
        bands = prctile(raw_data_boot, pct_bands, 2); 
        
        % 3. Plot the Bands (Red Dashed)
        plot(1:H, bands(:, 1), 'r--', 'LineWidth', 1.2); % Lower Band
        plot(1:H, bands(:, 2), 'r--', 'LineWidth', 1.2); % Upper Band
        
        % 4. Plot the Median/Point Estimate (Black Solid)
        plot(1:H, mixedsign_irfPointestimate(i, :), 'k-', 'LineWidth', 2.5);
        
        % 5. Zero Line (Reference)
        line([1 H], [0 0], 'Color', [0.4 0.4 0.4], 'LineStyle', '-', 'LineWidth', 1);
        
        % Formatting
        title(labels(i), 'FontSize', 12, 'FontWeight', 'bold');
        xlim([1 H]);
        grid on;
        box on;
        set(gca, 'FontSize', 10);
    end

    sgtitle('Impact of Brexit Depreciation Shock on UK Economy', 'FontSize', 16, 'FontWeight', 'bold');

end