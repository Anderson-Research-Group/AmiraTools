# AmiraTools

## Purpose and Notes for User
- This repository is intended to house custom Anderson Lab Amira-Avizo scripts, script objects, resource files and etc. 
- The custom tools in this repo have been developed for and tested in Amira versions 5.6.0, 6.0.1, and 6.2.0. 
- The instructions in this README file assume the user is working from a Windows machine. 
The files in this repo will work for different operating systems, but the instructions for how to install for use by Amira will differ. 

## How to Install AmiraTools
### Download the AmiraTools repo from GitHub
1. From the green "<> Code" drop-down menu here on GitHub, select Download ZIP. 
2. Once downloaded, right click on the zip folder and select "Extract all"
3. Copy the extracted AmiraTools into your AMIRA_LOCAL folder (see AMIRA_LOCAL environment variable). 
If you don't already have an AMIRA_LOCAL environment variable established, the recommended file path is C:\Users\ComputerName\Amira\local 
(you will likely have to create Amira/local, it is not set-up by Amira).

###
OR 

1. Follow [SOP_GitHub](https://uofutah.sharepoint.com/:w:/s/Andersonlabgeneral/EXsGK784OCBJt2wU2yTOhe4BKsbqxCDouksPdQlos3E6Vw?e=gQMHkm) 
instructions on how to create a local copy of AmiraTools on your computer. This method is recommended if you are working on AmiraTools development. 

### Establish AMIRA_LOCAL environment variable
The following instructions can be supplemented with this tutorial from Amira-Avizo: [AMIRA_LOCAL Setup Tutorial by Amira-Avizo](https://www.thermofisher.com/software-em-3d-vis/xtra-library/xtras/amira_local-setup-tutorial) 
1. In your windows task bar, search for “Edit system environment variables”
2. A “System Properties” window will open. In the Advanced tab select “Environment Variables…”
3. Under “user variables” click “New” and type the following:
	- Variable name: AMIRA_LOCAL
	- Variable value: provide the path to your AmiraTools repository (for example: C:\Users\ComputerName\Amira\local\AmiraTools). 
	You can establish whatever path you would like, just be sure that you do not alter the folder structure of the AmiraTools repo.

### Check that AMIRA_LOCAL is recognized
1. Open Amira and click on the PROJECT tab
2. In the TCL console (bottom of screen), type the following: 
```shell
echo $AMIRA_LOCAL
```
3. If successful, the AMIRA_LOCAL path that you established will be printed in the TCL console.
