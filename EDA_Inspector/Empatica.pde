//import org.gicentre.utils.stat.*;
import java.io.FileReader;
import java.util.Arrays;
import java.util.Date;
import java.text.SimpleDateFormat;

class Empatica{
  
  int EDA_data_length = 15*60*4; // length (in samples) of data; 15mins * 60secs * 4Hz
  int EDA_starting_index = 0; // index (in original csv) to start from
  
  ArrayList<Float> SCL_data = new ArrayList<Float>();// = new float[];
  ArrayList<Float> SCL_time = new ArrayList<Float>();
  CustomGraph SCL;
  
  CustomGraph SCL_wave;
  
  CustomGraph SCL_walk;
  
  ArrayList<Float> SCL_baseline_t = new ArrayList<Float>();
  ArrayList<Float> SCL_baseline_d = new ArrayList<Float>();
  
  ArrayList<Float> temp_data = new ArrayList<Float>();// = new float[];
  ArrayList<Float> temp_time = new ArrayList<Float>();
  CustomGraph temp;
  
  ArrayList<Float> BVP_data = new ArrayList<Float>();// = new float[];
  ArrayList<Float> BVP_time = new ArrayList<Float>();
  CustomGraph BVP;  
  
  ArrayList<Float> acc_x_data = new ArrayList<Float>();
  ArrayList<Float> acc_y_data = new ArrayList<Float>();
  ArrayList<Float> acc_z_data = new ArrayList<Float>();
  ArrayList<Float> acc_time = new ArrayList<Float>();
  CustomGraph acc_x;
  CustomGraph acc_y;
  CustomGraph acc_z;
  
  CustomGraph small_EDA;
  
  ArrayList<CustomGraph> subgraphs_EDA = new ArrayList<CustomGraph>();
  int current_subgraph_index = 0;
  int num_subgraphs = 4;
  int max_subgraph_index = num_subgraphs - 1;
  
  CustomGraph current_graph;
    
  String folder_path;
  String[] filenames;
  
  String config_path;
  
  PApplet mainscreen;
  
  String condition;
  String pid;
  String pid_adam;
  
  int x_pos;
  int y_pos;
  
  float fs_EDA;//Hz
  float starttime_EDA;
  boolean success_EDA = true;
  
  float fs_TEMP;
  float starttime_TEMP;
  boolean success_TEMP;
  
  float fs_ACC;
  float starttime_ACC;

  float fs_BVP;
  float starttime_BVP;
  
  String fname;
  Double double_time;
  
  String study_type;
  
  float max_EDA = 0.0;
  float min_EDA = 999.000;
  
  int[] SCL_indices = new int[2];
  int[] ACC_indices = new int[2];
  int[] BVP_indices = new int[2];
  
  int time_lag_empatica = -10800; // empatica files are 3 hours ahead
  
  float[] interval = new float[2];
  int[] interval_index = new int[2];
  
  Markers markers;
  CustomGraph marker_graph;
  
  ArrayList<ROI> rois = new ArrayList<ROI>();
  
  String time_of_day = "";
  
  Empatica(PApplet parent, int x, int y, String top_path, String fn, String c, String s_t){
    //filenames = fns;
    x_pos = x;
    y_pos = y;
    condition = c;
    study_type = s_t;
    fname = fn;
    folder_path = top_path + "/" + fn;
    config_path = top_path + "/config.csv";
    mainscreen = parent;
  }
  
  int get_difference_in_seconds_between_two_times(String t1, String t2){
  // string format of t1 and t2: "HH:MM:SS PP"
  // ie "10:42:24 AM"
  // it is assumed that t1 <= t2
  return(string_date_to_seconds(t2) - string_date_to_seconds(t1));
  }

  int string_date_to_seconds(String t){
    // takes string formatted as "HH:mm:ss" and returns
    // number of seconds since "00:00:00"
    
    int hour = Integer.parseInt(split(t,":")[0]);    
    int min = Integer.parseInt(split(t,":")[1]);
    int sec = Integer.parseInt(split(t,":")[2]);
    
    return(hour*60*60 + min*60 + sec); 
    
  }
  
}
