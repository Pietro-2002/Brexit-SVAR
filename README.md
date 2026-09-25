# The Impact of the Brexit Depreciation Shock on the UK Labour Market: A Structural VAR Analysis

Course project, Monetary Economics — University of Turin, January 2026.
Author: Pietro Doria

## Question
After the June 2016 referendum, Sterling depreciated sharply. Did the shock act mainly as a **labour supply shock** (less EU migration, tighter labour market, lower unemployment) or as a **demand/uncertainty shock** (frozen investment and hiring, higher unemployment)?

## Data
UK monthly data, January 2000 – March 2024 (T ≈ 290). Six endogenous variables, in this order:

| # | Variable | Transformation |
|---|---|---|
| 1 | Brent oil price | log-difference |
| 2 | Industrial production | log-difference |
| 3 | CPI inflation | annual log-difference |
| 4 | Unemployment rate | level |
| 5 | Bank of England Official Bank Rate | level |
| 6 | Real effective exchange rate (REER) | level |

Lag order p = 4, selected by the Akaike Information Criterion.

## Method
1. **Reduced-form VAR** estimated equation by equation with OLS.
2. **Identification** through rotation matrices: B = PQ, with P the Cholesky factor of the residual covariance and Q a random orthonormal matrix. A draw is kept only if the impact responses satisfy:

   | Variable | Impact restriction | Rationale |
   |---|---|---|
   | Oil price | 0 | UK shocks do not move global oil prices |
   | Industrial production | 0 | Real rigidity |
   | Inflation | 0 | Nominal rigidity |
   | Unemployment | 0 | Labour market frictions |
   | Policy rate | < 0 | Same-month monetary easing |
   | Exchange rate | < 0 | The depreciation shock itself |

   Draws continue until 1,000 valid models are found.
3. **Inference**: recursive residual bootstrap (200 replications), 68% bands from the 16th and 84th percentiles.
4. **Forecast error variance decomposition**.
5. **Benchmark** against recursive Cholesky identification, which forces the same-month policy-rate response to zero.

## Main result
Unemployment shows a statistically significant, hump-shaped **increase** peaking 12–18 months after the shock, supporting the uncertainty/demand channel over the labour supply channel, despite the accommodative response of the Bank of England. The Cholesky benchmark misrepresents this response because it rules out the simultaneous reaction of the exchange rate and monetary policy.

## Repository structure
```
brexit-svar/
├── README.md
├── report/        Full paper (PDF)
├── code/          MATLAB scripts
└── data/          Input series
```

## How to run
Open MATLAB in the `code/` folder and run the main script. Figures are saved to `output/`.
