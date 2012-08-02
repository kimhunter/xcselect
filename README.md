Basic usage

    $ xcselect 
    Please Select an Xcode ?
    
       [1]    Xcode 4.1 (4B110) /Developer 
       [2]    Xcode 4.2 (4D5163b) /Xcode42 
       [3]    Xcode 4.4 (4F250) [current]
    
    Selection: 


Use -a to switch to the next xcode  

    xcselect -a
    
Use show -s to print info about the current xcode  

    xcselect -s

To open the current xcode (but will open first .xcproject in working dir if exists)  

    xcselect -o


I use this in my bash profile to open an xcode project 
    alias ox="xcselect -o"


xcsim command
-------------

xcsim command is a helper for opening particular directories in apps in the simulator support folder.  It has support for opening newsstand issues. Most of its commands are based on app that was last built.

for help 

    $ xcsim -h

Show a list of apps, make a selection to open in finder 

    $ xcsim -a

Show all newsstand issues for last built app, and select to open in finder

    $ xcsim -n

Open documents folder for last built app

    $ xcsim -d
    

Add -p before any of these and xcsim will print the path. 

If there will be only 1 item to select from the menu will not be displayed and that item will be implicitly selected.
