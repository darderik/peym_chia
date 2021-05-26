
# PEYM
Plot Even Your Mom

<br></br>
<br></br>
## What it does
This simple powershell program will allow you to have a logic behind the plotting process. 
As of current state, when ran, peym will list all your volumes on the system, and after having removed the ones which are blacklisted, will begin plotting to these hdds. The whole process can be resumed as follows:
![plotting offset](https://i.imgur.com/pZz6V72.png)

The various options, such as how many concurrent plotters you wish to have, are easily accessible through the config.json file

## Config

        "mainConfig": {
        "temporaryFolder": "G:\\ChiaTmp",
        "temporarySecondaryFolder": "",
        "plotDisksWhiteList": [],
        "plotDisksBlacklist": [
        "C:"
        ],
        "plotSize": 110,
        "tempPlotSize": 230,
        "chiaArgs": "plots create -k 32 -t {0} -d {1}\\ChiaPlots -2 {2}",
        "chiaAdd": "plots add -d '{0}\\ChiaPlots'",
        "maxConcurrentPlots": 3,
        "timeOut": 300,
        "chiaBlockChainFolder": "C:\\Users\\Dardo\\AppData\\Local\\chia-blockchain"
       }
As you can see, the config is pretty straightforward.

 - The things to keep in mind are the plotDisksWhiteList array, which   
   specifies the disks which will be used as final hard drives. If      
   plotDisksWhiteList is defined, plotDisksBlacklist will be ignored.

     
     
 - plotSize and tempPlotSize are used in case you'd want to    switch
   the type of plot file. Default values are set accordingly to k32 plot size
- chiaArgs: Useful if you want to change che arguments when starting a plot
- chiaAdd: Command issued in order to add a new plot folder
- timeout: timeout between checks (output Update,etc)
- chiaBlockChainFolder: Edit this according to your blockchain location

Here's how the output appears
![output](https://i.imgur.com/pZz6V72.png)



> Written with [StackEdit](https://stackedit.io/).

