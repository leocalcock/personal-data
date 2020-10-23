# personal-data

At the moment this is just a collection of scripts for collecting and organizing personal data for analysis. 

Current Data Stack (10/22/2020):
* RescueTime
* Fitbit
* Google forms/sheets
* Todoist

#### October 22nd 2020 update: Shifting to data tracking in 2020 

Seems like a useful bunch of code but going to shift to a stack of data collection, compilation/cleaning, and analysis including but not limited to sources such as: RescueTime, ATracker Pro, FitBit, Todoist, google sheets, youtube, and others. With this, first step is going to reorganize code a bit into the following sections: data collection, data cleaning, data analysis, personal code, setup, and reviews. Data collection will collect stricly *raw data* and be divided among folders for each source. Data cleaning will be a collection of scripts for, well, data cleaning - this should be done across data-sets and could include generation/setting of a codebook. Data analysis is scripts for analyzing data through summary statistics, visualizations, and others. Personal code is a .gitignore section for one's personal scripts. Setup is a piece of code for setting up some metadata for collection/purpose: apikeys, descriptions of what data collecting/why, etc. Reviews are stuff like Rmd/templates for going over data. 

Restated in reordered list form:
* Setup: script for filling out apikeys/metadata for info setup as well data folder etc. 
  * Should create a JSON with all this information as well as last time setup and/or an update was run. 
  * In future should allow for updating information. 
  * Should create data folder.
  * Have individual setup commands per data collection source. 
* Data Collection: Functions to collect raw data 
  * Broken down by source folder (e.g. "habitica")
  * Should include pullall and pullall(date range) for getting data
  * Should avoid reinventing the wheel too much - reference/use other code
* Data Cleaning: scripts to clean up data and compile from sources - can be rather personalized. 
* Data Analysis: Visualization/Analysis scripts
* Personal Code: .gitignore folder 
* Data Folder: .gitignore with raw data, metadata, clean data. Supermetadata: log file for data collection.
* Reviews: Templates for review/analysis. 

All of this is quite new/aspirational and none is set up. Perhaps the first thing to do is setup and second thing to do is code to pull raw data. 


## Code Doc:

### Habitica 
R code which supports collecting data from one's [habitica](https://habitica.com/) account. Habitica's basic raw data
collection is very hard to use for any analyses. The code here allows you to create csvs with data on frequency that
a task is done each day. There are three core functions to use this data collection tool: `setup()`, `setTasks()`, and 
`collectData()`. You must run all these functions from the data collection folder. 

`setup()` is used to create the folders and layout for data to be collected and stores your User ID and API token to 
establish connections to your account (which can be found [here](https://habitica.com/#/options/settings/api)). You
run the function as `setup(UserID,APIToken)`. Note that this does store your api token on your computer. No functions will
work before running `setup()`. 

`setTasks()` is used to setup metadata for which tasks you want to track and collect data for. It is setup so that you can
set which variables to track in your habitica account. For a daily or habit you would like to collect data for,
add a line "#variablename" on the last line of notes of the task. After you have done this for all tasks you want to track, run `setTasks()` (with no arguments) and it will be primed to collect data for the tasks you have marked under the variablename you have marked.  You
can even give two separate tasks the same variable name and it will track them together. E.G. add "#walk" to the end of notes for daily "Go to school" and for habit "Visit the park" and then in your csv under variable "walks" it will tally
for both "Go to school" and "Visit the park". Important detail: you can't use the variable name "t". You can rerun `setTasks()` at any time and it will reset variables to track based on your habitica account.

`collectData()` collects your data (hurdur?). It creates a csv with the past week's data. E.G. run `collectData(YYYY-MM-DD)` to create your .csv for that week. 

#### habiticaFuncs.r codedoc
`setup(user,pw,path)` pass UserID, APIToken, and path to the data folder (folder which you want to set up habitica data).
default is path = "../data".

`readUserPw()` takes no arguments and returns a tuple with your UserID and APIToken. (assumes ../data path)

`getTask(taskId,user,pw)` Given a taskId, uses a get request to get the task's data and returns json text if the request
is successful and `NULL` if the request fails. Used in `cData()` and furthermore `collectData()`.

`getTasks(user, pw)` Given UserID and APIToken, does a GET request to get task data and returns .json text for tasks. (returns NULL if failed request) `setTasks()` uses this. 

`setTasks(uspw,overwrite,path)` uspw is a tuple of UserID and APIToken, overwrite currently doesn't do anything, and path
is the path to the habitica folder in your data folder. It resets/makes taskIDs.json in the habitica folder which encodes
json pairs of (variablename,idList) consisting of a variable name and a list of habitica task ids which correspond to that
variablename. 

`collectData(weekOf,tz,pathPre,write)` weekOf is the starting day of the week (inclusive) for collecting the data (YYYY-MM-DD), tz is the timezone for the date, pathPre is a path to the data folder within the habitica folder. write specifies
whether to write the data (the function returns a data table).

`cData(t1,days,path,uspw)` Mainly a helper function to `collectData()`. t1 is a POSIXct for the starting day and days is
the number of days to track for a csv. path is the path to where to write the data file and uspw is the UserID-APIToken tuple.

