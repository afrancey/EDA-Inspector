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
The visual inspection screen looks like this:
![inspection](https://github.com/afrancey/EDA-Inspector/blob/master/images/inspection.png)
Components:
1. Vertical line that follows your mouse. Boundaries will be placed at the location of this line when you click the mouse. You cannot place a boundary if this line is not shown (eg. when going outside of the graph).
2. Data coordinates. The time and SCL shown correspond to the graph location of the **tip of the mouse**.
3. Measurement triangle. The hypotenuse of this triangle represents a 0.1 uS drop over two seconds. Any portions of the signal that are steeper than this slope, without a preceding rise, are deemed artifacts.
4. Previously placed boundary.
5. Location of the current inspection interval with respect to the entire signal.


