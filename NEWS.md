# ParBayesianOptimization 1.3.0

## New features

* continue maintenance under new maintainer, point CI/CRAN metadata at fork ([7dcae4b](https://github.com/novica/ParBayesianOptimization/commit/7dcae4bc1121920536d16d8bc18b1d202addf0e8))


## Bug fixes

* fixed cran checks ([766ba97](https://github.com/novica/ParBayesianOptimization/commit/766ba97efb46708dbfec5aafeca3085ab94b29ee))
* migrate vignettes to Quarto; CI on GH Actions ([9a289c4](https://github.com/novica/ParBayesianOptimization/commit/9a289c444e9075313568ed91bdf9e147b790b3f8))
* removed setorder apllied to local optim df which caused reproducibility-issues ([10495b9](https://github.com/novica/ParBayesianOptimization/commit/10495b9d743b85859af89b94b361a5fdcb4ee516))
* test works ([12bd3cb](https://github.com/novica/ParBayesianOptimization/commit/12bd3cba98424fbcb7d0502bfe2e80f1d613cdf6))
* vignette builds ([d5caef6](https://github.com/novica/ParBayesianOptimization/commit/d5caef66b81e8d4e0a4eed61edacb40e5e6684a2))

## ParBayesianOptimization 1.2.4
### Changes  
Fixed a small bug that allowed duplicates to make their way into the candidate table.

## ParBayesianOptimization 1.2.3
### Changes  
Some suggested packages are now used conditionally in vignettes, reade, tests and examples since they might not be available on all checking machines.


## ParBayesianOptimization 1.2.2
### Changes  
Removed Plotly from dependencies.


## ParBayesianOptimization 1.2.1  
### Changes  
Fixed a bug with initgrid on scoring functions with dimensionality over 4.

## ParBayesianOptimization 1.2.0

### Changes
Improved the way error handling works - any errors encountered in initialization will be returned.

## ParBayesianOptimization 1.1.0
### Changes
Changed Gaussian Process package to DiceKriging. predict method is much faster.
Added errorHandling parameter - bayesOpt() and addIterations() should now return results no matter what, unless errorHandling = 'stop'
Added otherHalting parameter.
