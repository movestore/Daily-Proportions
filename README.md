# Daily Proportions

MoveApps

Github repository: *github.com/movestore/Daily-Proportions*

## Description
Filters your data according to a selected attribute and value and returns the daily number and cumulative duration of locations fulfilling this property.

## Documentation
This App first marks all locations that fulfill a user defined property (e.g. ground speed > 10 m/s). Then it extracts the number of locations per day and track that this property is fulfilled. Sample sizes per day are added.

In addition, the cumulative daily duration is calcualted, where each track segment's duration is attributed to the start locations. The last location of each day is attributed with the time until the first location of the next day, if there are such data, else NA.

For each calender date average proportion and duration is calcualted, where n.pts indicates that number of tracks providing data for this date.

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

### Null or error handling:
**Parameter `variab`:** If there is no individual variable with the name given here, an error will be returned.

**Parameter `rel`:** If none of the relation options are selected, an error will be returned. It has to be carefully considered that the selected relation fits with the data type of the selected variable. Only numeric and timestamps variables can relate by '==', '>' or '<'.

**Parameter `valu`:** If there is no value entered, an error will be returned. The data type of the entered value has to fit with the selected variable.

**Parameter `time`:** If the selected variable is a timestamp and it was not indicated here, the variable will be treated as a string of text and possibly not handled correctly, leading to errors. Similarly if your variable is not a timestamp and it is indicated here. Default is 'false'.

**Data:** The full data set is returned.