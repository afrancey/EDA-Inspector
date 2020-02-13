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

Tools tools = new Tools();

float EDA_threshold = 0.5;

boolean draw_ruler = true;
boolean draw_out_of_bounds = false;

//String analysis_type = "EEG";
String analysis_type = "EDA";

// holds Muses and Empaticas
ArrayList<Device> device_list = new ArrayList<Device>();

ArrayList<PVector> screen_boundaries = new ArrayList<PVector>();
ArrayList<Integer> current_sample_boundaries = new ArrayList<Integer>();
ArrayList<String> names_boundaries = new ArrayList<String>();

String top_data_folder = "";

String stage = "folder selection";

ArrayList<ArrayList<String>> not_device = new ArrayList<ArrayList<String>>(); // not_device.get(i) = {filename, reason};
ArrayList<String> device_names = new ArrayList<String>(); // not_device.get(i) = {filename, reason};
ArrayList<String> rejected_device = new ArrayList<String>(); // rejected_device.get(i) = filename;

int filecount = 0;

String datafile_timestamp = "null";

boolean files_created = false;
boolean files_listed = false;

int num_sections = 30;
int num_subintervals = 3;

void listfiles(){
  //run through folder and find files
 
  File folder = new File(top_data_folder);
  File[] listOfFiles = folder.listFiles();
  
  get_config_parameters();
  
  for(int i = 0; i < listOfFiles.length; i++) {
    String filename = listOfFiles[i].getName();
    Device device;
    if (analysis_type.equals("EEG")){
      device = new Muse(this, top_data_folder, filename, "null");
    } else {
      // actually, filename is the name of the folder containing the set of Empatica files here
      device = new Empatica(this, top_data_folder, filename, "null");
    }
    
    ArrayList<String> checkDevice_result = device.checkDevice();
    if (checkDevice_result.get(1).equals("device found")){
      device.setup_device();
      if (device.data_max < EDA_threshold & analysis_type.equals("EDA")){
        rejected_device.add(checkDevice_result.get(0));
      } else {
        device_list.add(device);
        device_names.add(checkDevice_result.get(0));
        print("Device added: " + checkDevice_result.get(0));
      }
    } else {
      not_device.add(checkDevice_result);
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
    stage = "folder selected";
    listfiles();
    
  }
}

void setup() {
  //size(700,700);
  fullScreen();
  textFont(createFont("Arial",10),10);
  
  selectFolder("Select folder to process", "folderSelected"); 
  
  datafile_timestamp = Long.toString(System.currentTimeMillis());
  
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
     if (filecount < device_list.size()){
       device_list.get(filecount).draw_data();
     }
     draw_mouseline();
  } else if (stage.equals("finished")){
    //print("finished");
    background(0);
    if (files_created == false){
      files_created = true;
      try{
        finished();
      } catch(IOException e) {
        println(e);
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
    for (int en = 0; en < device_names.size(); en++){
      text(device_names.get(en), 50, height/10 + 40 + en*40);
    }
  
    text("Errors: ", width/4, height/10);
    for (int ne = 0; ne < not_device.size(); ne++){
      text(not_device.get(ne).get(0), width/4, height/10 + 40 + ne*40);
    }
    
    text("Does not reach " + Float.toString(EDA_threshold) + " uS threshold (REJECTED): ", width/2, height/10);
    for (int re = 0; re < rejected_device.size(); re++){
      text(rejected_device.get(re), width/2, height/10 + 40 + re*40);
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
        Device current_device = device_list.get(filecount);
        if (current_device.current_subgraph_index < current_device.num_subgraphs){
          
          // first turn screen boundaries into SCL sample boundaries determined by timings of currently shown subgraph
          ArrayList<Integer> sample_boundaries = new ArrayList<Integer>();
          for (int i = 0; i < screen_boundaries.size(); i++){
            PVector data_value = current_device.current_graph.lineChart.getScreenToData(screen_boundaries.get(i));
            float time_boundary = data_value.x;
            int sample_boundary = (int)(time_boundary*current_device.fs);
            sample_boundaries.add(sample_boundary);
          }
          
          // if this is the first subgraph, start new current_sample_boundaries array
          if (current_device.current_subgraph_index == 0){
            names_boundaries.add(current_device.fname);
            current_sample_boundaries = sample_boundaries;
          } else {
            // otherwise, append these boundaries to current_sample_boundaries
            current_sample_boundaries.addAll(sample_boundaries);
          }
          
          // we don't need these anymore, wipe for next graph
          screen_boundaries.clear();
          
          // increment index if not on last subgraph,
          // increment filecount if this is the last subgraph
          
          if (current_device.current_subgraph_index == current_device.max_subgraph_index){
            
            // save sample boundaries to device
            current_device.sample_boundaries.add(current_sample_boundaries);
            
            if (current_device.current_channel_index == current_device.num_channels - 1){
              // last channel on last subgraph, we are done
              filecount++;
              if (filecount >= device_list.size()){
                stage = "finished";
              }
            } else {
              //last subgraph but not last channel
              current_device.current_channel_index++;
              current_device.current_subgraph_index = 0;
            }
            
          } else {
            current_device.current_subgraph_index++;
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
    boolean removing = undo_boundary(x);
    if (removing == false){
      add_boundary(x,y);
    }
  }
  
}

boolean undo_boundary(int x){
  // check each boundary and see if it is between
  
  int remove_last = 0;
  int remove_first = 0;
  boolean need_to_remove = false;
  
  for (int i = 0; i < screen_boundaries.size(); i = i + 2){
    
    if (i+1 < screen_boundaries.size()){
      float bleft = min(screen_boundaries.get(i).x, screen_boundaries.get(i+1).x);
      float bright = max(screen_boundaries.get(i).x, screen_boundaries.get(i+1).x);
      
      if (x >= bleft && x <= bright){
        remove_last = i;
        remove_first = i+1;
        need_to_remove = true;
      }  
    } // else we are missing a boundary side
  }
  
  if (need_to_remove){
    screen_boundaries.remove(remove_first);
    screen_boundaries.remove(remove_last);
  }
  
  return(need_to_remove);
}

void add_boundary(int x, int y){
  PVector point;
  String snap_result = checkSnapBoundaryToAxis(x,y);
  if (snap_result == "left"){
    //boundary snaps to left axis
    float min_time = device_list.get(filecount).current_graph.lineChart.getMinX();
    float max_eda = device_list.get(filecount).current_graph.lineChart.getMaxY();

    PVector left_screenbound = device_list.get(filecount).current_graph.lineChart.getDataToScreen(new PVector(min_time,max_eda));
    point = left_screenbound;
  } else if (snap_result == "right"){
    float max_eda = device_list.get(filecount).current_graph.lineChart.getMaxY();
    float max_time = device_list.get(filecount).current_graph.lineChart.getMaxX();
    PVector right_screenbound = device_list.get(filecount).current_graph.lineChart.getDataToScreen(new PVector(max_time,max_eda));
    point = right_screenbound;
  } else {
    point = new PVector(x, y);
  }
  PVector datapoint = device_list.get(filecount).current_graph.lineChart.getScreenToData(point);
  if (datapoint != null){
    screen_boundaries.add(point);
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
  int num_samples_in_buffer = 4;
  float num_seconds_in_buffer = num_samples_in_buffer/device_list.get(filecount).fs;
  float min_time = device_list.get(filecount).current_graph.lineChart.getMinX();
  float max_eda = device_list.get(filecount).current_graph.lineChart.getMaxY();
  float max_time = device_list.get(filecount).current_graph.lineChart.getMaxX();
  
  float left_screenbound = device_list.get(filecount).current_graph.lineChart.getDataToScreen(new PVector(min_time+num_seconds_in_buffer,max_eda)).x;
  float right_screenbound = device_list.get(filecount).current_graph.lineChart.getDataToScreen(new PVector(max_time-num_seconds_in_buffer,max_eda)).x;
  
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
  if (filecount < device_list.size()){
    PVector datapoint = device_list.get(filecount).current_graph.lineChart.getScreenToData(new PVector(mouseX, mouseY));
    if (datapoint != null){
      fill(0,0,0);
      stroke(0,0,0);
      strokeWeight(1);
      text("time: " + Float.toString(datapoint.x), mouseX + 20, height - height/3 + 100);
      text("SCL: " + Float.toString(datapoint.y), mouseX + 20, height - height/3 + 130);
      
      if (draw_ruler){
      PVector mouse_endpoint = device_list.get(filecount).current_graph.lineChart.getDataToScreen(new PVector(datapoint.x + 2, datapoint.y + 0.1));
        line(mouseX + 10, mouseY, mouseX + 10, mouse_endpoint.y); // vertical 0.1uS bar
        line(mouseX + 10, mouseY, mouse_endpoint.x+10, mouseY); // horizontal 2s bar
        line(mouseX + 10, mouse_endpoint.y, mouse_endpoint.x+10, mouseY); // hypoteneuse
      }
      
      if (draw_out_of_bounds){
        
        // draw top boundary (at 100)
        float max_x = device_list.get(filecount).current_graph.lineChart.getMaxX();
        float min_x = device_list.get(filecount).current_graph.lineChart.getMinX();
        PVector bottom_left = device_list.get(filecount).current_graph.lineChart.getDataToScreen(new PVector(min_x, 100));
        PVector top_right = device_list.get(filecount).current_graph.lineChart.getDataToScreen(new PVector(max_x, 110));
        fill(100,100,100,40);
        rectMode(CORNERS);
        rect(bottom_left.x,bottom_left.y, top_right.x, top_right.y);
        
        // draw bottom boundary (at -100)
        PVector bottom_bottom_left = device_list.get(filecount).current_graph.lineChart.getDataToScreen(new PVector(min_x, -110));
        PVector bottom_top_right = device_list.get(filecount).current_graph.lineChart.getDataToScreen(new PVector(max_x, -100));
        fill(100,100,100,40);
        rectMode(CORNERS);
        rect(bottom_bottom_left.x,bottom_bottom_left.y, bottom_top_right.x, bottom_top_right.y);
      
      }
      

      
        // draw line on mouse
      line(mouseX, 50, mouseX, height - height/3); // vertical
      //line(50, mouseY, width - 50, mouseY); // horizontal
      showSnapBoundaryToAxis();
    }
  }
  
  // draw rects on small graph
  //device_list
  fill(0,0,0,40);
  stroke(0,0,0);
  strokeWeight(1);
  Device current_device = device_list.get(filecount);
  int num_data_points = current_device.timepoints.size();
  float max_eda = current_device.data_max;
  float min_eda = current_device.data_min;
  float max_time = num_data_points/current_device.fs;
  float starttime = current_device.current_subgraph_index*max_time/current_device.num_subgraphs;
  float endtime = (current_device.current_subgraph_index+1)*max_time/current_device.num_subgraphs;
  PVector top_left_corner = current_device.current_small_graph.lineChart.getDataToScreen(new PVector(starttime, max_eda));
  PVector bottom_right_corner = current_device.current_small_graph.lineChart.getDataToScreen(new PVector(endtime, min_eda));
  rectMode(CORNERS);
  rect(top_left_corner.x, top_left_corner.y, bottom_right_corner.x, bottom_right_corner.y);


}

void finished() throws IOException{
  
  // save means for each participant
  
  set_zscore_params_and_condition();
  
  if (analysis_type.contains("EDA")){
  
    String means_output = "subject,time,group,standmean\n";
    String boundaries_output = "";
    String slopes_output = "subject,time,group,standslope\n";
      
    for (int p = 0; p < device_list.size(); p++){
      Device current_device = device_list.get(p);
      
      // filename/condition
      means_output+= split(current_device.display_name,  " ")[0] + "," + current_device.condition + "," + current_device.group + ",";
      boundaries_output+=current_device.display_name + ",";
      slopes_output+= split(current_device.display_name,  " ")[0] + "," + current_device.condition + "," + current_device.group + ",";
      
      // get info from device
      float[] weighted_means = current_device.get_mean_for_each_interval();
      ArrayList<Integer> subject_bounds = current_device.sample_boundaries.get(0);
      float[] slopes = current_device.get_slope_for_each_interval();
      
      // generate output string
      for (int m = 0; m < weighted_means.length; m++){
        means_output+= Float.toString(weighted_means[m]) + ",";
      }
      means_output+="\n";
      
      for (int b = 0; b < subject_bounds.size(); b++){
        boundaries_output+= Integer.toString(subject_bounds.get(b)) + " ";
      }
      boundaries_output+="\n";
      
      
      for (int m = 0; m < slopes.length; m++){
        slopes_output+= Float.toString(slopes[m]) + ",";
      }
      slopes_output+="\n";
      
    }
    
    // write data file
    String dpath = dataPath("");
    dpath = dpath.replace("\\","/");
    
    PrintWriter mwriter = new PrintWriter(dpath + "/means_" + datafile_timestamp + ".csv", "UTF-8");
    mwriter.print(means_output);
    mwriter.close();
    
    PrintWriter bwriter = new PrintWriter(dpath + "/bounds_" + datafile_timestamp + ".csv", "UTF-8");
    bwriter.print(boundaries_output);
    bwriter.close();
    
    PrintWriter swriter = new PrintWriter(dpath + "/slopes_" + datafile_timestamp + ".csv", "UTF-8");
    swriter.print(slopes_output);
    swriter.close();
  } else if (analysis_type.contains("EEG")){
    String boundaries_output = "";
      
    for (int p = 0; p < device_list.size(); p++){
      Device current_device = device_list.get(p);
      // filename/condition
      boundaries_output+=current_device.display_name + ",";
      
      // get info from device
      ArrayList<ArrayList<Integer>> subject_bounds = current_device.sample_boundaries;
      
      for (int ch = 0; ch < subject_bounds.size(); ch++){
        ArrayList<Integer> channel_bounds = subject_bounds.get(ch);
        for (int b = 0; b < channel_bounds.size(); b++){
          boundaries_output+= Integer.toString(channel_bounds.get(b)) + " ";
        }
        boundaries_output+=",";
      }
      boundaries_output+="\n";
      
    }
    
    // write data file
    String dpath = dataPath("");
    dpath = dpath.replace("\\","/");
    PrintWriter bwriter = new PrintWriter(dpath + "/bounds_" + datafile_timestamp + ".csv", "UTF-8");
    bwriter.print(boundaries_output);
    bwriter.close();
  }
}

void get_config_parameters(){
}

void set_zscore_params_and_condition(){
  // read config file, merge pre and post signals, find mean and ssd, apply it to Device member
  ArrayList<ArrayList<String>> pre_post_list = tools.match_pre_and_post("C:/Users/alzfr/Documents/thesis stats/THESIS2018/expt2/PARTICIPANTS.csv");
  for (int pair = 0; pair < pre_post_list.size(); pair++){
    
    // get filenames
    String number = pre_post_list.get(pair).get(0);
    String pre_name = pre_post_list.get(pair).get(1);
    String post_name = pre_post_list.get(pair).get(2);
    String grp = pre_post_list.get(pair).get(3);
    
    Device pre_dev = new Device();
    Device post_dev = new Device();
    
    boolean pre_found = false;
    boolean post_found = false;
    
    // find devices matching pre and post filenames
    for (int dev = 0; dev < device_list.size(); dev++){
      Device cur_dev = device_list.get(dev);
      if (cur_dev.fname.equals(pre_name)){
        pre_dev = cur_dev;
        pre_dev.condition = "pre";
        pre_dev.display_name = number;
        pre_dev.group = grp;
        print("pre found");
        pre_found = true;
      }
      if (cur_dev.fname.equals(post_name)){
        post_dev = cur_dev;
        post_dev.condition = "post";
        post_dev.display_name = number;
        post_dev.group = grp;
        print("post found");
        post_found = true;
      }
    }
    
    if (analysis_type.equals("EDA") & pre_found & post_found){
    
      // found devices, combine data
      ArrayList<ArrayList<Float>> data_list = new ArrayList<ArrayList<Float>>();
      data_list.add(pre_dev.channel_data.get(0));
      data_list.add(post_dev.channel_data.get(0));
      
      ArrayList<ArrayList<Integer>> bound_list = new ArrayList<ArrayList<Integer>>();
      bound_list.add(pre_dev.sample_boundaries.get(0));
      bound_list.add(post_dev.sample_boundaries.get(0));
      
      ArrayList<Float> combined_mean_ssd = tools.get_zscore_params_using_multiple_signals_with_bounds(data_list, bound_list);
      
      pre_dev.mean_to_use = combined_mean_ssd.get(0);
      pre_dev.ssd_to_use = combined_mean_ssd.get(1);
      post_dev.mean_to_use = combined_mean_ssd.get(0);
      post_dev.ssd_to_use = combined_mean_ssd.get(1);
    }
    
    
  }
  
}
