function Brexit_PlotComparison(cirf, mixedsign_irfPointestimate, n, hor)
% BREXIT_PLOTCOMPARISON Compares Standard Cholesky vs Mixed Sign Restrictions.
% We focus on Policy Rate (Var 5) and Unemployment (Var 4) to show why
% Cholesky is insufficient (it assumes zero impact at t=0).
%
% INPUTS:
%   cirf                       : Standard Cholesky IRF [Vars x Shock x Time]
%   mixedsign_irfPointestimate : Our Mixed Sign IRF (Median) [Vars x Time]
%   n                          : Number of variables (Exchange Rate is the last one -> n)
%   hor                        : Time horizon for plotting

    figure('Name', 'Methodological Comparison', 'NumberTitle', 'off', 'Color', 'w');

    % Variables to compare: Policy Rate (Index 5) and Unemployment (Index 4)
    
    vars_to_compare = [5, 4]; 
    titles = ["Policy Rate Response", "Unemployment Response"];
    
    % The Shock Index in Cholesky is the LAST variable (Exchange Rate)
    shock_idx_chol = n; 

    for i = 1:length(vars_to_compare)
        var_idx = vars_to_compare(i);
        
        subplot(1, 2, i); hold on;
        
        % 1. PLOT CHOLESKY (Blue Dashed Line)
        % We extract the response of 'var_idx' to the shock 'shock_idx_chol'
        chol_line = squeeze(cirf(var_idx, shock_idx_chol, 1:hor));
        plot(1:hor, chol_line, 'b--', 'LineWidth', 2);
        
        % 2. PLOT MIXED SIGNS (Black Solid Line - Our Model)
        mixed_line = mixedsign_irfPointestimate(var_idx, :);
        plot(1:hor, mixed_line, 'k-', 'LineWidth', 2.5);
        
        % 3. Zero Line
        line([1 hor], [0 0], 'Color', [0.5 0.5 0.5]);
        
        % Formatting
        title(titles(i), 'FontSize', 12, 'FontWeight', 'bold');
        if i == 1
            legend({'Standard Cholesky', 'Mixed Restrictions (Ours)'}, 'Location', 'best');
        end
        grid on; 
        xlim([1 24]); % Zoom on the first 2 years to see the t=0 difference
        xlabel('Months after Shock');
    end

    sgtitle('Why Cholesky Fails: The Importance of Sign Restrictions', 'FontSize', 14, 'FontWeight', 'bold');

end