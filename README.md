Basic usage

    $ xcselect 
    Please Select an Xcode install ?
    
       [1]    Xcode 4.1 (4B110) /Developer 
       [2]    Xcode 4.2 (4D5163b) /Xcode42 [current]
    
    Selection: 


Use -a to switch to the next xcode  

    xcselect -a
    
Use show -s to print info about the current xcode  

    xcselect -s

To open the current xcode (but will open first .xcproject in working dir if exists)  

    xcselect -o


I use this in my bash profile to open an xcode project 
    alias ox="xcselect -o"
