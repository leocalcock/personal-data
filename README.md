# personal-data
At the moment this is just a collection of scripts for collecting and organizing personal data for analysis. 


## Codebook:

### Habitica 
The habiticaFuncs.R contains various functions collecting data from your habitica account. Use `setup()` to create the connection between your
account and the system (e.g. `setup(apiUser,apiKey)`). You can set all of your data tracking in habitica by editing the "notes" section of any
given task. Add on the last line of some task's notes a "#variablename" and after doing this for all tasks you wish to track data for, run `setTasks()`. Every day, the scripts will download and organize your data in a neat spreadsheet with columns corresponding to the variablenames given (next thing to set up)