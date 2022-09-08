# Daily Proportions

MoveApps

Github repository: *github.com/movestore/Daily-Proportions*

## Description
Filters your data according to a selected attribute and value and returns the daily number and cumulative duration of locations fulfilling this property. Can be adapted for local time zone.

## Documentation
This App first marks all locations that fulfill a user defined property (e.g. ground speed > 10 m/s). Then it extracts the number of locations per day and track that this property is fulfilled. Sample sizes per day are added.

In addition, the cumulative daily duration is calcualted, where each track segment's duration is attributed to the start locations. The last location of each day is attributed with the time until the first location of the next day, if there are such data, else NA.

For each calender date average proportion and duration is calcualted, where n.pts indicates that number of tracks providing data for this date. Two final rows indicate the overall mean and standard deviations of proportion and duration with n.pts indicating the number of individual days where percentages were calculated.

For proper definition of your days, please provide the hours that your time zone deviates from UTC. Daily values will then be adapted accordingly between local midnights. Example: For UTC+2 insert 2.

It is necessary to include the Time Lag Between Locations App before this App in the workflow.

### Input data
moveStack in Movebank format

### Output data
moveStack in Movebank format

### Artefacts
`Daily_Proportions.csv`: table of daily sample sizes, numbers and cumulative durations of locations that fulfill the required property.

`Daily_Proportions.pdf`: timelines of numbers and cumulative duraitons of locations that fulfill the required property by individual and averages as last plot.

### Parameters 
`variab`: Name of the required data attribute. Take care that this parameter also exists in the Track Attributes of the input data set.

`rel`: By this parameter the relation in the required property has to be selected. The possible values differ by parameter data type, only numeric and timestamps variables can relate by '==', '>' or '<'.

`valu`: Value of the relation that the data set has to fullfill. In case of `rel` = 'is one of the following' commas have to be used to separate the possible values. In case of a timestamp parameter please use the timestamp format with year, month, day, hour, minute and second as in the example: '2021-06-23 09:34:00"

`time`: Please tick this parameter if your selected variable is a timestamp type, so that the App can properly work with it.

`midnight_adapt`: hours that your time zone deviates from UTC. Examples: for UTC+2 insert 2, for UTC-6 insert -6.

`last_loctime`: Select this option if your data were collected with a regular daily gap (e.g. no locations at night). This leads the App to calculate cumulative durations of the adapted `timelag2` that is weighting the last location before the gap with the median data resolution instead of the long gap time interval. Depending on your required data property and how the animal(s) behave during the gap (e.g. night) either one or the other might be sensible. Note that (in addition to the Time Lag Between Locations App) you need to add the Adapt Time Lag for Regular Gaps App to your workflow before, if you want to use this feature.

### Null or error handling:
**Parameter `variab`:** If there is no individual variable with the name given here, an error will be returned.

**Parameter `rel`:** If none of the relation options are selected, an error will be returned. It has to be carefully considered that the selected relation fits with the data type of the selected variable. Only numeric and timestamps variables can relate by '==', '>' or '<'.

**Parameter `valu`:** If there is no value entered, an error will be returned. The data type of the entered value has to fit with the selected variable.

**Parameter `time`:** If the selected variable is a timestamp and it was not indicated here, the variable will be treated as a string of text and possibly not handled correctly, leading to errors. Similarly if your variable is not a timestamp and it is indicated here. Default is 'false'.

**Parameter `midnight_adapt`:** Values must be between -12 and 12. If other numbers are entered, the dates are shifted further than appropriate and results become difficult to interpret.

**Data:** The full data set is returned.