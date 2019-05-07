# EDA-Inspector

This tool is intended to be used for visual inspection and manual artifact removal of SCL data files obtained from an Empatica wristband.

## Downloading
To download the Processing code, click "clone or download .zip" and then "Download zip". Unzip the files.
![downloading](https://github.com/afrancey/EDA-Inspector/blob/master/images/downloading.PNG)

## Data Naming and Folder Structure
* Each participant's Empatica data is stored in one folder. This folder should have all of EDA.csv, BVP.csv, etc.
* The name of a participant's folder is the participant number, then a space, then the condition (eg. "22 Dense").
* One folder contains all of the participant folders.

Your data should be structured according to this image:

![folders](https://github.com/afrancey/EDA-Inspector/blob/master/images/folders.png)

## Usage
### Picking your data folder
Run EDA_Inspector.pde with Processing 3. The first screen you will see is a dialog box asking you to pick a folder. Choose the folder containing your participant folder, and click "Open".
![choosing](https://github.com/afrancey/EDA-Inspector/blob/master/images/choosing.png)
After picking the folder the program will automatically look through the folder for Empatica files and display the results.

### Inspecting your Data


