
<!-- README.md is generated from README.Rmd. Please edit that file -->

# r2bids - Convert R data to BIDS format

<!-- badges: start -->
<!-- badges: end -->

<img src="man/figures/logo.png" alt="drawing" width="20%" align="right"/>

This package provides functions for converting and storing behavioral
data represented in R data frames in the convenient [BIDS
format](https://bids.neuroimaging.io/). At present, this package is
suited to convert data from behavioral studies that is represented in a
trial structure (for example one trial per row). An event structure,
which is the common representation in BIDS can be handled with some
workarounds in the current version and more dedicated funtions for event
files might be implemented in future releases.

The BIDS format is becoming increasingly popular in neuroscience as a
means of storing data sets along with structured descriptions of
samples, tasks, and variables.

## Website

Read the detailed documentation including examples here…

<https://xaverfuchs.github.io/r2bids/>

## Installation

You can install the development version of *r2bids* from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
# devtools::install_github("xaverfuchs/r2bids")
```

## Example case

``` r
library(r2bids)
```

### Generate some toy data

``` r
example_data <- data.frame(
  ParticipantID = c(1, 2, 3, 1, 2, 3),
  Sex=c("M", "F", "O", "M", "F", "O"),
  Age=c(21, 32, 27, 21, 32, 27),
  Session = c(1, 1, 1, 2, 2, 2),
  ResponseTime = c(350, 400, 375, 415, 372, 401),
  Accuracy = c(1, 0, 1, 1, 1, 1)
)
```

### Validate the input data

This function does renaming of variables and labels to adhere to BIDS
conventions.

``` r
example_data_checked <- check_input_data(data = example_data, 
                 participant_col = "ParticipantID", 
                 session_col = "Session", 
                 sex_col = "Sex")
#> 
#> Step 1: checking variable labels
#> checking variable Sex
#> renamed variable label: M -> m
#> renamed variable label: F -> f
#> renamed variable label: O -> o
#> 
#> Step 2: checking participant and session identifiers
#> renamed variable: ParticipantID -> participant_id
#> renamed ids to sub-1, sub-2, sub-3 ...
#> renamed variable: Session -> session
#> renamed sessions to ses-1, ses-2 ...
#> renamed variable: Sex -> sex
#> 
#> Step 3: checking if all variable names are snake_case
#> renamed variable: Age -> age
#> renamed variable: ResponseTime -> response_time
#> renamed variable: Accuracy -> accuracy
#> 
#> Step 4: checking correct coding of sex variable
```

### Write BIDS file

``` r
write_task_tsv(data = example_data_checked, bids_dir = "example_bids", 
               data_type = "beh", 
               filename_prefixes = c("sub-", "ses-", "task-"), 
               filename_variables = c("participant_id", "session", "reaction"="task"),
               path_prefixes = c("sub-", "ses-"), 
               path_variables = c("participant_id", "session"), 
               ignore_variables = c("age", "sex"))
#> Variable task does not exist in the data and will be imputed as reaction
#> Main BIDS directory successfully created: example_bids
#> Folder successfully created: example_bids/sub-1/ses-1/beh
#> Task data saved: example_bids/sub-1/ses-1/beh/sub-1_ses-1_task-reaction_beh.tsv
#> Folder successfully created: example_bids/sub-2/ses-1/beh
#> Task data saved: example_bids/sub-2/ses-1/beh/sub-2_ses-1_task-reaction_beh.tsv
#> Folder successfully created: example_bids/sub-3/ses-1/beh
#> Task data saved: example_bids/sub-3/ses-1/beh/sub-3_ses-1_task-reaction_beh.tsv
#> Folder successfully created: example_bids/sub-1/ses-2/beh
#> Task data saved: example_bids/sub-1/ses-2/beh/sub-1_ses-2_task-reaction_beh.tsv
#> Folder successfully created: example_bids/sub-2/ses-2/beh
#> Task data saved: example_bids/sub-2/ses-2/beh/sub-2_ses-2_task-reaction_beh.tsv
#> Folder successfully created: example_bids/sub-3/ses-2/beh
#> Task data saved: example_bids/sub-3/ses-2/beh/sub-3_ses-2_task-reaction_beh.tsv
```

The resulting output looks like that:
<img src="man/figures/folder_stucture.jpeg" alt="folder structure" width="100%" align="left"/>

## More examples

For more detailed examples see the vignettes on the [package
website](https://xaverfuchs.github.io/r2bids/)!
