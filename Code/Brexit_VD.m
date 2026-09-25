function vd_results = Brexit_VD(cirf, shock_irf, n, labels, horizons)
% BREXIT_VD Calculates and plots the Variance Decomposition for the Brexit Project.
%
% INPUTS:
%   cirf       : Total Impulse Responses (from CholeskyBoot) [n x n x H]
%   shock_irf  : The identified Brexit Shock IRF [n x H]
%   n          : Number of variables
%   labels     : Names of the variables (string array)
%   horizons   : Vector of time horizons to analyze (e.g., [12 24 48])
%
% OUTPUT:
%   vd_results : Matrix containing the % variance explained [n x length(horizons)]

    % Initialize results matrix
    vd_results = zeros(n, length(horizons));

    %% 1. CALCULATION LOOP
    for i = 1:n 
        for k = 1:length(horizons)
            h_idx = horizons(k);
            
            % A. Total Variance (Sum of squares of ALL shocks from Cholesky)
           
            total_var_h = sum(sum(cirf(i, :, 1:h_idx).^2));
            
            % B. Brexit Variance (Sum of squares of OUR identified shock)
            brexit_var_h = sum(shock_irf(i, 1:h_idx).^2);
            
            % C. Ratio (%)
            if total_var_h > 0
                vd_results(i, k) = (brexit_var_h / total_var_h) * 100;
            else
                vd_results(i, k) = 0;
            end
        end
    end

    %% 2. PLOTTING (Bar Chart)
    figure('Name', 'Brexit Variance Decomposition', 'NumberTitle', 'off', 'Color', 'w');
    
    % Create Bar Chart
    bar(vd_results);
    
    % Formatting
    xlabel('Variables', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('% Variance Explained by Brexit Shock', 'FontSize', 12, 'FontWeight', 'bold');
    title('Variance Decomposition Analysis', 'FontSize', 14, 'FontWeight', 'bold');
    
    % X-Axis Labels
    set(gca, 'XTickLabel', labels);
    xtickangle(45); 
    
    % Legend based on input horizons
    legend_labels = cell(1, length(horizons));
    for k = 1:length(horizons)
        legend_labels{k} = sprintf('%d Months', horizons(k));
    end
    legend(legend_labels, 'Location', 'northeast', 'FontSize', 10);
    
    grid on;
    ylim([0 100]); % Cap at 100%
    box on;

    %% 3. PRINT TABLE TO COMMAND WINDOW
    fprintf('\n======================================================\n');
    fprintf(' VARIANCE DECOMPOSITION RESULTS (%% Variance Explained)\n');
    fprintf('======================================================\n');
    
    % Create dynamic header
    header_str = sprintf('%-15s', 'Variable');
    for k = 1:length(horizons)
        header_str = [header_str, sprintf(' %-12s', legend_labels{k})];
    end
    fprintf('%s\n', header_str);
    fprintf('------------------------------------------------------\n');
    
    % Print rows
    for i = 1:n
        row_str = sprintf('%-15s', labels(i));
        for k = 1:length(horizons)
            row_str = [row_str, sprintf(' %-12.2f', vd_results(i,k))];
        end
        fprintf('%s\n', row_str);
    end
    fprintf('======================================================\n');

end