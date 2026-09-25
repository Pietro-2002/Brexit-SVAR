%% BREXIT PROJECT - MAIN SCRIPT
% This script analyzes the impact of the Brexit Vote (Exchange Rate Shock)
% on the UK Labor Market using Sign and Zero Restrictions.

clear all
clc
close all

%% 1. DATA LOADING AND TRANSFORMATION
% Load the Excel file containing UK macro data (2000 - 2024)
filename = fullfile('..', 'data', 'UK_Brexit_Data.xlsx');
raw_data = xlsread(filename);

% Determine start column automatically (in case Excel reads dates as col 1)
if size(raw_data, 2) == 7
    start_col = 2; % Dates are in Col 1, Data starts at Col 2
else
    start_col = 1; % No dates read, Data starts at Col 1
end

% Extract Variables

Oil_raw   = raw_data(:, start_col);     
GDP_raw   = raw_data(:, start_col+1);   
CPI_raw   = raw_data(:, start_col+2);   
Unemp_raw = raw_data(:, start_col+3);   
Rate_raw  = raw_data(:, start_col+4);   
Exch_raw  = raw_data(:, start_col+5);   

% Transformations
% 1. Log-Differences (Growth Rates * 100) for trending variables
% We assume Oil, GDP, and CPI are non-stationary and need differencing.
diff_vars = diff(log([Oil_raw, GDP_raw, CPI_raw])) * 100;

% 2. Levels for rates (Unemployment, Interest Rate, Exchange Rate)
% We remove the first observation to match the length of differenced variables (T-1).
level_vars = [Unemp_raw(2:end), Rate_raw(2:end), Exch_raw(2:end)];

% 3. Construct the final endogenous vector y
% Order: [Oil_Growth, IP_Growth, Inflation, Unemployment, Policy_Rate, Exchange_Rate]
y = [diff_vars, level_vars];



%% 2. MODEL SPECIFICATION
p_max = 12;      % Maximum lags to test
hor = 48;        % Impulse Response Horizon (48 months = 4 years)
T = size(y,1);   % Number of observations
n = size(y,2);   % Number of variables (6)
H = hor;         % Horizon for plotting
c = 1;           % Include constant in VAR
MaxBoot = 200;   % Number of Bootstrap replications for confidence bands
cumulative_index = []; % No cumulative variables needed for identification logic

% LABELS for Plots
labels = ["Oil Growth", "UK IP Growth", "Inflation", "Unemployment", "Policy Rate", "Exchange Rate"];
shocklabels = ["Brexit Shock (Depreciation)"]; 


%% 3. LAG SELECTION (AIC CRITERION)
% We estimate the VAR for lags 1 to 12 and select the one minimizing AIC.
aicvalues = zeros(p_max,1);
p_optimal = 1;

fprintf('Calculating Optimal Lag Length...\n');
for p=1:p_max
    [para, res] = VARTopicsOLS(y,p);
    sigma = cov(res);
    % AIC Formula: log|Sigma| + Penalty for parameters
    aicvalues(p) = log(det(sigma)) + 2*(n^2*p+n)/T;
    if aicvalues(p) <= aicvalues(p_optimal)
        p_optimal = p;
    end
end

fprintf('Optimal Lag Length selected by AIC: %d\n', p_optimal);

%% 4. REDUCED FORM ESTIMATION AND BOOTSTRAP
% Estimate the VAR using OLS and generate bootstrapped distributions
fprintf('Running Bootstrap (this may take a moment)...\n');
[cirf, CholBoot, cholu, CovU, u] = CholeskyBoot(y, p_optimal, H, c, MaxBoot, cumulative_index, 1);

%% 5. STRUCTURAL IDENTIFICATION: MIXED RESTRICTIONS
% We identify the "Brexit Shock" as a sudden depreciation of the Pound.
% Methodology: Zero Restrictions (Sluggishness) + Sign Restrictions.

% THE RESTRICTION MATRIX (Column 1 = Brexit Shock)
% +1 = Positive Response
% -1 = Negative Response
%  0 = Zero Response (at impact)


% Economic Logic:
% 1. Oil: Assumed 0 (Exogenous/Fast moving but unaffected by UK specific shock at t=0)
% 2. UK IP: 0 (Real economy is sluggish)
% 3. Inflation: 0 (Prices are sticky)
% 4. Unemployment: 0 (Hiring/Firing takes time)
% 5. Policy Rate: -1 (BoE cuts rates to support economy)
% 6. Exchange Rate: -1 (THE SHOCK: Depreciation of Sterling)

mixed_restriction = [
    0;    % Oil
    0;    % UK IP
    0;    % Inflation
    0;    % Unemployment
    -1;   % Policy Rate (Accommodation)
    -1;   % Exchange Rate (Depreciation)
];

% Number of slow-moving variables (Rows restricted to 0)
slowmov = 4; 

% Confidence Bands Percentiles (68% Bands)
lb = 16; 
ub = 84;

fprintf('Identifying Structural Shocks...\n');
% Run the Mixed Restrictions Algorithm
[mixedsign_irfPointestimate, mixedesign_irfboot] = mixed_restrictions(...
    1000, 1000, MaxBoot, lb, ub, mixed_restriction, slowmov, cirf, CholBoot, labels, shocklabels);


%% 6. FINAL VISUALIZATION (IRF with Bands)
% We plot the impulse responses with 68% confidence bands using our custom function.
% Black Line = Median response
% Red Lines  = Uncertainty bands

Brexit_PlotIRF(mixedesign_irfboot, mixedsign_irfPointestimate, n, hor, labels);


%% 7. VARIANCE DECOMPOSITION
% We calculate how much of the fluctuation in variables (like Unemployment)
% is driven by the Brexit shock over time using our custom function.

horizons_to_check = [12 24 48]; % 1, 2, and 4 years


vd_matrix = Brexit_VD(cirf, mixedsign_irfPointestimate, n, labels, horizons_to_check);


%% 8. METHODOLOGICAL COMPARISON (Robustness Check)
% We visually demonstrate why the standard Cholesky identification fails 
% to capture the simultaneous reaction of the Policy Rate at t=0.

Brexit_PlotComparison(cirf, mixedsign_irfPointestimate, n, hor);