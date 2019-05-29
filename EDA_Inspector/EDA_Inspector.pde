// DO NOT overlap boundaries

// todo
// - 90% of signal above threshold
// - change screen to black (easier on eyes);


import org.gicentre.utils.stat.*;
import org.gicentre.utils.colour.*;
import java.util.Arrays;

import java.io.FileWriter;
import java.io.PrintWriter;
import java.io.IOException;

import java.lang.System;

//CustomGraph cg;
Empatica e1;
ArrayList<Empatica> emily_empatica_list=new ArrayList<Empatica>();
ArrayList<Empatica> adam_empatica_list=new ArrayList<Empatica>();

ArrayList<PVector> screen_boundaries = new ArrayList<PVector>();
ArrayList<ArrayList<Integer>> sample_boundaries_each_subject = new ArrayList<ArrayList<Integer>>();
ArrayList<String> names_boundaries = new ArrayList<String>();

String top_data_folder = "";

String stage = "folder selection";

ArrayList<ArrayList<String>> not_empatica = new ArrayList<ArrayList<String>>(); // not_empatica.get(i) = {filename, reason};
ArrayList<String> empatica_names = new ArrayList<String>(); // not_empatica.get(i) = {filename, reason};
ArrayList<String> rejected_empatica = new ArrayList<String>(); // rejected_empatica.get(i) = filename;

//ArrayList<String[]> not_empatica = new ArrayList<String[]>(); // not_empatica.get(i) = {"

int filecount = 0;
//String type = "adam";
String type = "emily";

String datafile_timestamp = "null";

float EDA_threshold = 0.5;

boolean files_created = false;
boolean files_listed = false;

int num_sections = 30;
int num_subintervals = 3;

void listfiles(){
  
  // find empatica files
  // each item in top_data_folder needs to be a subfolder containing 6 empatica .csvs
  
  File folder = new File(top_data_folder);
  File[] listOfFiles = folder.listFiles();
  
  get_config_parameters();
  
  for(int i = 0; i < listOfFiles.length; i++) {
    String filename = listOfFiles[i].getName();
    if (listOfFiles[i].isFile()) {
      println("File " + listOfFiles[i].getName());
      not_empatica.add(new ArrayList<String>(Arrays.asList(filename, "not a folder")));
    } else if (listOfFiles[i].isDirectory()) {
      File subfolder = new File(top_data_folder + "/" + filename);
      File[] subfiles = subfolder.listFiles();
      
      if (subfiles.length != 8){
        not_empatica.add(new ArrayList<String>(Arrays.asList(filename, "wrong number")));
      } else {
        // check to see if it has correct files
        // "ACC.csv", "BVP.csv", "EDA.csv", "HR.csv", "IBI.csv", "info.txt", "tags.csv", "TEMP.csv"
        String empatica_filenames[] = {"ACC.csv", "BVP.csv", "EDA.csv", "HR.csv", "IBI.csv", "info.txt", "tags.csv", "TEMP.csv"};
        String filenames_in_empatica_folder[] = new String[8];
        for (int sf = 0; sf < subfiles.length;sf++){
          filenames_in_empatica_folder[sf] = subfiles[sf].getName();
        }
        
        if (Arrays.equals(empatica_filenames,filenames_in_empatica_folder)){
          // has right files in folder
          String condition = split(filename, " ")[1];
          Empatica new_emily_empatica = new Empatica(this, 100,100, top_data_folder, filename, condition, "emily");
          
          if (new_emily_empatica.max_EDA > EDA_threshold){
            emily_empatica_list.add(new_emily_empatica);
            empatica_names.add(filename);
          } else {
            // rejected for too low EDA
            rejected_empatica.add(filename);
          }
        } else {
          // does not have correct files in folder
          not_empatica.add(new ArrayList<String>(Arrays.asList(filename, "wrong files")));
        }
      }
            
    }
  }
  files_listed = true;
}

void folderSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    top_data_folder = selection.getAbsolutePath();
    top_data_folder = top_data_folder.replace("\\","/");
    println(top_data_folder);
    stage = "folder selected";
    listfiles();
  }
}

void setup() {
  //size(700,700);
  fullScreen();
  textFont(createFont("Arial",10),10);
  selectFolder("Select folder to process", "folderSelected");
  
  //listfiles();
  //print("esize");
  //println(emily_empatica_list.size());
  //emily_empatica_list = new ArrayList<Empatica>(emily_empatica_list.subList(22,24)); // hack to reduce list size for inspection
  
  /*
  try{
    output_zeroes_and_area();
  } catch(IOException e) {
    println("exception");
  }
  */
  
  println(dataPath(""));
  
  datafile_timestamp = Long.toString(System.currentTimeMillis());
  println(datafile_timestamp);
  
  
 
  
}

void draw(){
  
  if (stage.equals("folder selection")){
    // do nothing ; neat animation
    if (frameCount%300 < 150){
      background(50 + frameCount%150);
    } else {
      background(200 - frameCount%150);
    }
  } else if (stage.equals("folder selected")){
    // show results on screen
    background(0);
    displayFolderSelectionResults();
  } else if (stage.equals("inspection")){
     background(255);
     if (filecount < emily_empatica_list.size()){
       emily_empatica_list.get(filecount).draw_data();
     }
     draw_mouseline();
  } else if (stage.equals("finished")){
    //print("finished");
    background(0);
    if (files_created == false){
      files_created = true;
      try{
        emily_finished();
      } catch(IOException e) {
        println("exception");
      }
    } else {
      stroke(255);
      fill(255);
      text("Inspection complete! Files saved into the data folder.", width/2, height/2);
      text("Press ESC to close.", width/2, height/2+50);
    }
  }

}

void displayFolderSelectionResults(){
  
  textSize(30);
  
  text("Participants: ", 50, height/10);
  for (int en = 0; en < empatica_names.size(); en++){
    text(empatica_names.get(en), 50, height/10 + 40 + en*40);
  }

  text("Errors: ", width/4, height/10);
  for (int ne = 0; ne < not_empatica.size(); ne++){
    text(not_empatica.get(ne).get(0), width/4, height/10 + 40 + ne*40);
  }
  
  text("Does not reach " + Float.toString(EDA_threshold) + " uS threshold (REJECTED): ", width/2, height/10);
  for (int re = 0; re < rejected_empatica.size(); re++){
    text(rejected_empatica.get(re), width/2, height/10 + 40 + re*40);
  }
  
  if (files_listed){
    textSize(40);
    text("Click anywhere to continue.", 50 , 50);
  }
  
  
}

void keyPressed() {
  
  if (stage.equals("folder selected") && files_listed){
    stage = "inspection";
  } else if (stage.equals("inspection")){
    if (key == CODED) {
      if (keyCode == RIGHT) {
        println("rightpress");
        Empatica current_empatica = emily_empatica_list.get(filecount);
        if (current_empatica.current_subgraph_index < current_empatica.num_subgraphs){
          
          // first turn screen boundaries into SCL sample boundaries determined by timings of currently shown subgraph
          ArrayList<Integer> sample_boundaries = new ArrayList<Integer>();
          for (int i = 0; i < screen_boundaries.size(); i++){
            PVector data_value = current_empatica.current_graph.lineChart.getScreenToData(screen_boundaries.get(i));
            float time_boundary = data_value.x;
            int sample_boundary = (int)(time_boundary*4.0);
            sample_boundaries.add(sample_boundary);
          }
          
          // if this is the first subgraph, add it to global arrays
          if (current_empatica.current_subgraph_index == 0){
            names_boundaries.add(current_empatica.fname);
            sample_boundaries_each_subject.add(sample_boundaries);
          } else {
            // otherwise, add it to the most recently added array in global array
            sample_boundaries_each_subject.get(sample_boundaries_each_subject.size() - 1).addAll(sample_boundaries);
          }
          
          // we don't need these anymore, wipe for next graph
          screen_boundaries.clear();
          
          // increment index if not on last subgraph,
          // increment filecount if this is the last subgraph
          
          if (current_empatica.current_subgraph_index == current_empatica.max_subgraph_index){
            filecount++;
            if (filecount >= emily_empatica_list.size()){
              stage = "finished";
            }
          } else {
            current_empatica.current_subgraph_index++;
          }
        }
      }
    } 
  }
}
void mouseClicked(){
  if (stage.equals("folder selected") && files_listed){
    stage = "inspection";
  } else if (stage.equals("inspection")){
    println("mouseclicked");
    int x = mouseX;
    int y = mouseY;
    PVector point;
    String snap_result = checkSnapBoundaryToAxis(x,y);
    if (snap_result == "left"){
      //boundary snaps to left axis
      float min_time = emily_empatica_list.get(filecount).current_graph.lineChart.getMinX();
      float max_eda = emily_empatica_list.get(filecount).current_graph.lineChart.getMaxY();
  
      PVector left_screenbound = emily_empatica_list.get(filecount).current_graph.lineChart.getDataToScreen(new PVector(min_time,max_eda));
      point = left_screenbound;
    } else if (snap_result == "right"){
      float max_eda = emily_empatica_list.get(filecount).current_graph.lineChart.getMaxY();
      float max_time = emily_empatica_list.get(filecount).current_graph.lineChart.getMaxX();
      PVector right_screenbound = emily_empatica_list.get(filecount).current_graph.lineChart.getDataToScreen(new PVector(max_time,max_eda));
      point = right_screenbound;
    } else {
      point = new PVector(x, y);
    }
    PVector datapoint = emily_empatica_list.get(filecount).current_graph.lineChart.getScreenToData(point);
    if (datapoint != null){
      screen_boundaries.add(point);
    }
  }
  
}

void showSnapBoundaryToAxis(){
  
  String result = checkSnapBoundaryToAxis(mouseX,mouseY);
  
  if (result == "left"){
    stroke(0,255,0);
  } 
  if (result == "right"){
    stroke(255,0,0);
  }
  
  if (result != "none"){
    strokeWeight(10);
    line(mouseX, 50, mouseX, height - height/3); // vertical
  }
}

String checkSnapBoundaryToAxis(int x, int y){
  int num_seconds_in_buffer = 1;
  float min_time = emily_empatica_list.get(filecount).current_graph.lineChart.getMinX();
  float max_eda = emily_empatica_list.get(filecount).current_graph.lineChart.getMaxY();
  float max_time = emily_empatica_list.get(filecount).current_graph.lineChart.getMaxX();
  
  float left_screenbound = emily_empatica_list.get(filecount).current_graph.lineChart.getDataToScreen(new PVector(min_time+num_seconds_in_buffer,max_eda)).x;
  float right_screenbound = emily_empatica_list.get(filecount).current_graph.lineChart.getDataToScreen(new PVector(max_time-num_seconds_in_buffer,max_eda)).x;
  
  if (x <= left_screenbound){
    return("left");
  }
  
  if (x >= right_screenbound){
    return("right");
  }
  
  // else
  return("none");
  
}

void draw_mouseline(){
  
  // draw screen boundary lines
  // draw boundary rectangles
  for (int b = 0; b < screen_boundaries.size(); b++){
    
    // draw boundary lines
    if (b%2 == 0){
      stroke(0,255,0);
    } else {
      stroke(255,0,0);
    }
    line(screen_boundaries.get(b).x, 50, screen_boundaries.get(b).x, height - height/3);
    stroke(0,0,0);
    
    // draw boundary rects
    if (b%2 == 0 && b != screen_boundaries.size() - 1){
      fill(255,0,0,40);
      rectMode(CORNERS);
      rect(screen_boundaries.get(b).x, 50, screen_boundaries.get(b+1).x, height - height/3);
    }
    
    stroke(0,0,0);
  }
  
  // draw ruler
  if (filecount < emily_empatica_list.size()){
    PVector datapoint = emily_empatica_list.get(filecount).current_graph.lineChart.getScreenToData(new PVector(mouseX, mouseY));
    if (datapoint != null){
      fill(0,0,0);
      stroke(0,0,0);
      strokeWeight(1);
      text("time: " + Float.toString(datapoint.x), mouseX + 20, height - height/3 + 100);
      text("SCL: " + Float.toString(datapoint.y), mouseX + 20, height - height/3 + 130);
      PVector mouse_endpoint = emily_empatica_list.get(filecount).current_graph.lineChart.getDataToScreen(new PVector(datapoint.x + 2, datapoint.y + 0.1));
      line(mouseX + 10, mouseY, mouseX + 10, mouse_endpoint.y); // vertical 0.1uS bar
      line(mouseX + 10, mouseY, mouse_endpoint.x+10, mouseY); // horizontal 2s bar
      
      line(mouseX + 10, mouse_endpoint.y, mouse_endpoint.x+10, mouseY); // hypoteneuse
      
        // draw line on mouse
      line(mouseX, 50, mouseX, height - height/3); // vertical
      //line(50, mouseY, width - 50, mouseY); // horizontal
      showSnapBoundaryToAxis();
    }
  }
  
  // draw rects on small graph
  //emily_empatica_list
  fill(0,0,0,40);
  stroke(0,0,0);
  strokeWeight(1);
  Empatica current_empatica = emily_empatica_list.get(filecount);
  int num_data_points = current_empatica.SCL_time.size();
  float max_eda = current_empatica.max_EDA;
  float min_eda = current_empatica.min_EDA;
  float max_time = num_data_points/current_empatica.fs_EDA;
  float starttime = current_empatica.current_subgraph_index*max_time/current_empatica.num_subgraphs;
  float endtime = (current_empatica.current_subgraph_index+1)*max_time/current_empatica.num_subgraphs;
  PVector top_left_corner = current_empatica.small_EDA.lineChart.getDataToScreen(new PVector(starttime, max_eda));
  PVector bottom_right_corner = current_empatica.small_EDA.lineChart.getDataToScreen(new PVector(endtime, min_eda));
  rectMode(CORNERS);
  rect(top_left_corner.x, top_left_corner.y, bottom_right_corner.x, bottom_right_corner.y);


}

void output_zeroes_and_area() throws IOException{
  String output = "";
  float[] sum_area = new float[84];
  float[] sum_extrema = new float[84];
  String[] averages_names = {"bstand", "bwave", "bwalk", "sstand", "swave", "swalk"};
  for (int i = 0; i < 84; i++){
    sum_area[i] = 0.0;
    sum_extrema[i] = 0.0;
  }
  for (int e = 0; e < adam_empatica_list.size(); e++){
    output+=adam_empatica_list.get(e).pid_adam + ",";
    print("len rois");
    println(adam_empatica_list.get(e).rois.size());
    
    for (int r = 0; r < adam_empatica_list.get(e).rois.size(); r++){
      float area = adam_empatica_list.get(e).rois.get(r).area;
      int num_peaks = adam_empatica_list.get(e).rois.get(r).num_peaks;
      String stim_type = adam_empatica_list.get(e).rois.get(r).stim_type;
      sum_area[r]+= area;
      sum_extrema[r]+=num_peaks;
      if (stim_type.equals("none") == false){
        print("write stim type ");
        println(stim_type);
      }
      output+= "[" + stim_type + " " + Integer.toString(num_peaks) + " " + Float.toString(area) + "],";  
    }
    output+= "\n";
  }
  print(output);
  PrintWriter writer = new PrintWriter("C:/Users/alzfr/Desktop/expt 3 data/stats.csv", "UTF-8");
  writer.print(output);
  writer.close();
  
  float[] block_average_area = {0.0,0.0,0.0,0.0,0.0,0.0};
  float[] block_average_extrema = {0.0,0.0,0.0,0.0,0.0,0.0};
  
  for (int beep = 0; beep < 7; beep++){
    block_average_area[0] += sum_area[beep];
    block_average_extrema[0] += sum_extrema[beep];
  }
  for (int beep = 7; beep < 14; beep++){
    block_average_area[1] += sum_area[beep];
    block_average_extrema[1] += sum_extrema[beep];
  }
  for (int beep = 21; beep < 28; beep++){
    block_average_area[2] += sum_area[beep];
    block_average_extrema[2] += sum_extrema[beep];
  }
  for (int beep = 28; beep < 42; beep++){
    block_average_area[3] += sum_area[beep];
    block_average_extrema[3] += sum_extrema[beep];
  }
  for (int beep = 42; beep < 56; beep++){
    block_average_area[4] += sum_area[beep];
    block_average_extrema[4] += sum_extrema[beep];
  }
  for (int beep = 70; beep < 84; beep++){
    block_average_area[5] += sum_area[beep];
    block_average_extrema[5] += sum_extrema[beep];
  }
  
  block_average_area[0] = block_average_area[0]/(adam_empatica_list.size()*7);
  block_average_area[1] = block_average_area[1]/(adam_empatica_list.size()*7);
  block_average_area[2] = block_average_area[2]/(adam_empatica_list.size()*7);
  block_average_area[3] = block_average_area[3]/(adam_empatica_list.size()*14);
  block_average_area[4] = block_average_area[4]/(adam_empatica_list.size()*14);
  block_average_area[5] = block_average_area[5]/(adam_empatica_list.size()*14);
  
  block_average_extrema[0] = block_average_extrema[0]/(adam_empatica_list.size()*7);
  block_average_extrema[1] = block_average_extrema[1]/(adam_empatica_list.size()*7);
  block_average_extrema[2] = block_average_extrema[2]/(adam_empatica_list.size()*7);
  block_average_extrema[3] = block_average_extrema[3]/(adam_empatica_list.size()*14);
  block_average_extrema[4] = block_average_extrema[4]/(adam_empatica_list.size()*14);
  block_average_extrema[5] = block_average_extrema[5]/(adam_empatica_list.size()*14);
  
  
  print("avg area ");
  println(block_average_area);
  print("avg extrema ");
  println(block_average_extrema);
  
  //for (int i = 
 // println(adam_empatica_list.get(0).rois);
  
}

float[] get_section_averages(int pnum){
  Empatica emp = emily_empatica_list.get(pnum);
  ArrayList<Float> baseline_score_params = mean_ssd(emp.SCL_data);
  ArrayList<Integer> sample_bounds = sample_boundaries_each_subject.get(pnum);
  ArrayList<Float> data = emp.SCL_data;
  ArrayList<Float> z_data = zscore_list(data, baseline_score_params.get(0),baseline_score_params.get(1));

  ArrayList<Integer> indicator_list = new ArrayList<Integer>();
  for (int d = 0; d < z_data.size(); d++){
    boolean rejected = false;
    for (int bs = 0; bs < sample_bounds.size(); bs = bs+2){
      int start = sample_bounds.get(bs);
      int end = sample_bounds.get(bs+1);
      if (d >= start && d <=end){
        rejected = true;
      }
    }
    if (rejected){
      indicator_list.add(0);
    } else {
      indicator_list.add(1);
    }
  }
  
  // now have z-scored list and indicator list
  // get means
 // int num_sections = 30; //num_sections now read from config.txt
  int section_length = z_data.size()/num_sections;
  float[] mean = new float[num_sections];
  for (int m = 0; m < num_sections; m++){
    int start = m*section_length;
    int end = (m+1)*section_length;
    ArrayList<Float> chop_z = new ArrayList<Float>(z_data.subList(start,end));
    ArrayList<Integer> chop_ind = new ArrayList<Integer>(indicator_list.subList(start,end));
    mean[m] = get_section_mean(chop_z, chop_ind);
  }
  
  return(mean);
  
}

float get_section_mean(ArrayList<Float> data, ArrayList<Integer> indicator){
  // break data into 3 sections, determines weighted section mean
  int subsection_length = data.size()/3;
  float[] sums = {0.0,0.0,0.0};
  float[] num_indicators = {0.0,0.0,0.0};
  for (int m = 0; m < 3; m++){
    for (int s = m*subsection_length; s < (m+1)*subsection_length;s++){
      if (indicator.get(s) == 1){
        // good data
        sums[m] += data.get(s);
        num_indicators[m] += 1;
      }
    }
  }
  
  float weighted_mean = 0.0;
  for (int m = 0; m < 3; m++){
    float weight = num_indicators[m]/(num_indicators[0]+num_indicators[1]+num_indicators[2]);
    float unweighted_mean = 0.0;
    if (num_indicators[m] != 0){
      unweighted_mean = sums[m]/num_indicators[m];
    } // else the whole section is artifact, and has weight of zero
    weighted_mean += weight*unweighted_mean;
  }
  
  return(weighted_mean);
}

ArrayList<Float> mean_ssd(ArrayList<Float> data){
  
  ArrayList<Float> result = new ArrayList<Float>();
  // calculate mean
  float sum = 0;
  for (int i = 0; i < data.size();i++){
    sum+=data.get(i);
  }
  float mean = sum/data.size();
  result.add(mean);
  
  //calculate sample SD
  float sum_of_squares = 0;
  for (int i = 0; i < data.size();i++){
    sum_of_squares+=pow(data.get(i) - mean,2);
  }
  
  float ssd = pow(sum_of_squares/(data.size()-1),0.5);
  result.add(ssd);
  
  return(result);
 
}

ArrayList<Float> zscore_list(ArrayList<Float> data, float mean, float ssd){
  
  // create array of baseline standing values
  ArrayList<Float> zscored = new ArrayList<Float>();
  
  for (int i = 0; i < data.size(); i++){
    float val = (data.get(i) - mean)/ssd;
    zscored.add(i, val);
  }
  
  return(zscored);
}

void emily_finished() throws IOException{
  // save means for each participant
  String means_output = "";
  for (int p = 0; p < emily_empatica_list.size(); p++){
    means_output+= split(emily_empatica_list.get(p).fname,  " ")[0] + "," + emily_empatica_list.get(p).condition + ",";
    float[] weighted_means = get_section_averages(p);
    for (int m = 0; m < weighted_means.length; m++){
      means_output+= Float.toString(weighted_means[m]) + ",";
    }
    means_output+="\n";
  }
  
  String boundaries_output = "";
  for (int p = 0; p < emily_empatica_list.size(); p++){
    boundaries_output+=emily_empatica_list.get(p).fname + ",";
    ArrayList<Integer> subject_bounds = sample_boundaries_each_subject.get(p);
    for (int b = 0; b < subject_bounds.size(); b++){
      boundaries_output+= Integer.toString(subject_bounds.get(b)) + " ";
    }
    boundaries_output+="\n";
  }
  
  String dpath = dataPath("");
  dpath = dpath.replace("\\","/");
  
  PrintWriter mwriter = new PrintWriter(dpath + "/means_" + datafile_timestamp + ".csv", "UTF-8");
  mwriter.print(means_output);
  mwriter.close();
  
  PrintWriter bwriter = new PrintWriter(dpath + "/bounds_" + datafile_timestamp + ".csv", "UTF-8");
  bwriter.print(boundaries_output);
  bwriter.close();
}

void get_config_parameters(){
  ArrayList<String> lines = read_data_file(top_data_folder + "/config.txt");
  boolean success = true;
    if (lines.get(1).contains("number of intervals")){
      // expect first line to be "total time,<integer>"
      num_sections = Integer.parseInt(split(lines.get(0),",")[1]);
    } else {
      success = false;
    }
    if (lines.get(2).contains("subintervals per interval")){
      // expect first line to be "total time,<integer>"
      num_subintervals = Integer.parseInt(split(lines.get(0),",")[1]);
    } else {
      success = false;
    }
}

ArrayList<String> read_data_file(String name){
      // read EDA data
  ArrayList<String> lines = new ArrayList<String>();
  try {
      //println(folder_path);
      BufferedReader br = new BufferedReader(new FileReader(name));
      StringBuilder sb = new StringBuilder();
      String line = br.readLine();
  
      while (line != null) {
          sb.append(line);
          lines.add(line);
          sb.append(System.lineSeparator());
          line = br.readLine();
      }
      String everything = sb.toString();
      br.close();
  } catch(IOException ie) {
    //println("ERROR");
  } finally {
    //println("FILEREAD");
      //br.close();
  }
  return(lines);
  //print(lines);
  
}
  
