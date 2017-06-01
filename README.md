# personal-data
At the moment this is just a collection of scripts for collecting and organizing personal data for analysis. 


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