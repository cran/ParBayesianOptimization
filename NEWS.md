# ParBayesianOptimization 1.4.2

## Documentation

* move README badges below title ([#58](https://github.com/novica/ParBayesianOptimization/issues/58)) ([b5e31c0](https://github.com/novica/ParBayesianOptimization/commit/b5e31c00d8ab6c751c10d0ced27b35df589a87d9))

# ParBayesianOptimization 1.4.1

## Bug fixes

* use singular wording in the addIterations() bounds warning ([#50](https://github.com/novica/ParBayesianOptimization/issues/50)) ([382d7f2](https://github.com/novica/ParBayesianOptimization/commit/382d7f235ad796e84cad687f6f2df408a4a169d1))


## Documentation

* add an R CITATION file, ORCID and the CRAN DOI ([#54](https://github.com/novica/ParBayesianOptimization/issues/54)) ([86c0d4e](https://github.com/novica/ParBayesianOptimization/commit/86c0d4e2665f71121ab0fbc7590f761ec4e510b7))

# ParBayesianOptimization 1.4.0

## New features

* list the acq options in the bayesOpt() signature ([#38](https://github.com/novica/ParBayesianOptimization/issues/38)) ([b8baeb2](https://github.com/novica/ParBayesianOptimization/commit/b8baeb2abec403e443b9a7d37a94c9d597b3e178)), closes [#29](https://github.com/novica/ParBayesianOptimization/issues/29)
* replace crayon with cli ([#21](https://github.com/novica/ParBayesianOptimization/issues/21)) ([eb81642](https://github.com/novica/ParBayesianOptimization/commit/eb816424d3c2bc7e46f85cad0e1bba8cade395be))
* replace ggpubr with patchwork, cutting dependencies from 84 to 27 ([#20](https://github.com/novica/ParBayesianOptimization/issues/20)) ([40598a1](https://github.com/novica/ParBayesianOptimization/commit/40598a16603f0e6fa404e0ad2a0f9b9d9bb14d74)), closes [#15](https://github.com/novica/ParBayesianOptimization/issues/15)


## Bug fixes

* accept unique prefixes of km() argument names ([#40](https://github.com/novica/ParBayesianOptimization/issues/40)) ([fdd1f1e](https://github.com/novica/ParBayesianOptimization/commit/fdd1f1e8c23329385efba775e946be4f9ce7e678))
* exclude out-of-bounds rows from the first GP fit in addIterations() ([#39](https://github.com/novica/ParBayesianOptimization/issues/39)) ([c27d0a2](https://github.com/novica/ParBayesianOptimization/commit/c27d0a2d30cc09355e9f14c009ede94fd529fd10))
* leave the user's sinks open in bayesOpt() and addIterations() ([#35](https://github.com/novica/ParBayesianOptimization/issues/35)) ([a7bc272](https://github.com/novica/ParBayesianOptimization/commit/a7bc2727384de8c06109ee3a2339ce178133d194)), closes [#27](https://github.com/novica/ParBayesianOptimization/issues/27)
* let plot() arguments override the layout defaults ([#42](https://github.com/novica/ParBayesianOptimization/issues/42)) ([0340518](https://github.com/novica/ParBayesianOptimization/commit/0340518e9f6de365de2dbf5740cfa7cc6a38afd2))
* reject arguments km() does not accept before FUN runs ([#34](https://github.com/novica/ParBayesianOptimization/issues/34)) ([b182006](https://github.com/novica/ParBayesianOptimization/commit/b1820063c21927bfd317d00cf5b5a749cfa4763e)), closes [#26](https://github.com/novica/ParBayesianOptimization/issues/26)
* replace deprecated aes_string() in plot.bayesOpt() ([7b86814](https://github.com/novica/ParBayesianOptimization/commit/7b868140ac1507651d81355d26a19cf77ad19a7c)), closes [#5](https://github.com/novica/ParBayesianOptimization/issues/5)
* update bayesOpt example for initPoints and xgboost 3.x ([#9](https://github.com/novica/ParBayesianOptimization/issues/9)) ([d5df277](https://github.com/novica/ParBayesianOptimization/commit/d5df27722c120698dca697238f8f58709c7a35d9))
* validate acq exactly and in one place ([#41](https://github.com/novica/ParBayesianOptimization/issues/41)) ([81488ca](https://github.com/novica/ParBayesianOptimization/commit/81488caa800c8a0d308efbf34a7bbd19802e8abc))
* warn instead of stopping to prompt when addIterations() bounds exclude earlier results ([#36](https://github.com/novica/ParBayesianOptimization/issues/36)) ([1b3577a](https://github.com/novica/ParBayesianOptimization/commit/1b3577a5971168c4e51da4c0e7ffdb3a42332952)), closes [#24](https://github.com/novica/ParBayesianOptimization/issues/24)


## Documentation

* add pkgdown favicons ([b02146d](https://github.com/novica/ParBayesianOptimization/commit/b02146d0714370a92bf92d97e04d3d76fc9db814))
* fix missing images on the pkgdown home page ([#13](https://github.com/novica/ParBayesianOptimization/issues/13)) ([25235dc](https://github.com/novica/ParBayesianOptimization/commit/25235dcb4106876763cf66897010697da80f0099))
* move README images to man/figures ([ca15e67](https://github.com/novica/ParBayesianOptimization/commit/ca15e678adc30476f0ffafc859128f4beffcfa33))
* read xgboost 3.x best_iteration in the README example ([#43](https://github.com/novica/ParBayesianOptimization/issues/43)) ([b4cd6ba](https://github.com/novica/ParBayesianOptimization/commit/b4cd6ba00d79ec8c409830f981063bd269f9e1f4))
* read xgboost 3.x best_iteration in vignette and test ([7aa379c](https://github.com/novica/ParBayesianOptimization/commit/7aa379cf0baa9881ba35c6b6f6880dd90e6b572b)), closes [#11](https://github.com/novica/ParBayesianOptimization/issues/11)
* show initGrid = NULL, initPoints = NULL in the bayesOpt() signature ([#37](https://github.com/novica/ParBayesianOptimization/issues/37)) ([a73aeb9](https://github.com/novica/ParBayesianOptimization/commit/a73aeb964d2e419b77c3336afd0d10e4818ab18f)), closes [#28](https://github.com/novica/ParBayesianOptimization/issues/28)
* use Quarto options instead of knitr calls in vignettes ([#23](https://github.com/novica/ParBayesianOptimization/issues/23)) ([0aa6198](https://github.com/novica/ParBayesianOptimization/commit/0aa6198daa3d4d78d6236f8cfcc73dbe5af4bf66)), closes [#18](https://github.com/novica/ParBayesianOptimization/issues/18)

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
