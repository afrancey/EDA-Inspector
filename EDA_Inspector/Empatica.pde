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
  String empatica_file_time;
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
    empatica_file_time = fn.substring(0,1);
    if (study_type != "emily"){
      empatica_file_time = fn.substring(0,10);
    }
    mainscreen = parent;
    if (study_type.equals("emily")){
      read_data();
    }
    setup_graphs();
    
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
  
  void get_config_from_file(){
    // expect config file to be in top_data_folder
    ArrayList<String> lines = read_data_file(config_path);
    
    boolean success = true;
    if (lines.get(1).contains("total time")){
      // expect first line to be "total time,<integer>"
      EDA_data_length = (int)fs_EDA*Integer.parseInt(split(lines.get(1),",")[1]);
      println("EDA_data_length: " + Integer.toString(EDA_data_length));
    } else {
      success = false;
    }
    
    // intervals and subintervals handled in EDA_inspector
    
    boolean found_me = false;
    for (int p = 3; p < lines.size(); p++){
      String pnum = split(lines.get(p), ",")[0];
      String cond = split(lines.get(p), ",")[1];
      String timestring = split(lines.get(p),",")[2];
      if (fname.equals(pnum + " " + cond)){
        // starting index should be difference between config start time and file recording start time
        Date startString = new Date((long)starttime_EDA*1000L);
        println(fname + ", " + startString);
        String pattern = "HH:mm:ss";
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat(pattern);
        String time_of_day = simpleDateFormat.format(startString);
        int diff = string_date_to_seconds(timestring) - string_date_to_seconds(time_of_day);
        
        EDA_starting_index = 4*diff;
        found_me = true;
      }
    }
    
    if (found_me == false){
      success = false;
    }
  }
  
  void read_data(){
    // read EDA data
    ArrayList<String> lines = read_data_file(folder_path + "/" + "EDA.csv");
    if (lines.size() > 100){
      starttime_EDA = Float.parseFloat(lines.get(0));
      fs_EDA = Float.parseFloat(lines.get(1));
      get_config_from_file();
      ArrayList<Float> SCL_data_temp = new ArrayList<Float>();
      ArrayList<Float> SCL_time_temp = new ArrayList<Float>();
      
      int sample_count = 0;
      // +2 to account for first two info lines
      for (int l = EDA_starting_index + 2; l < EDA_starting_index + EDA_data_length + 2;l++){
        
        float current_datapoint_EDA = Float.parseFloat(lines.get(l));
        // add data
        SCL_data_temp.add(current_datapoint_EDA);
        SCL_time_temp.add(sample_count/fs_EDA);
        
        //check max
        if (current_datapoint_EDA > max_EDA){
          max_EDA = current_datapoint_EDA;
        }
        
        // check min
        if (current_datapoint_EDA < min_EDA){
          min_EDA = current_datapoint_EDA;
        }
        
        sample_count++;
      }
      
      // round down # data to nearest multiple of num_subgraphs
      int num_data_points_to_use = num_subgraphs*floor(SCL_data_temp.size()/num_subgraphs);
      SCL_time = new ArrayList<Float>(SCL_time_temp.subList(0, num_data_points_to_use));
      SCL_data = new ArrayList<Float>(SCL_data_temp.subList(0, num_data_points_to_use));
      
      // get baseline values
      sample_count = 0;
      for (int l = 2; l < 1202;l++){
        SCL_baseline_d.add(Float.parseFloat(lines.get(l)));
        SCL_baseline_t.add(sample_count/fs_EDA);
        sample_count++;
      }
    }
    
    print("data size ");
    println(SCL_data.size());
             
  }
  
  void make_subgraphs(ArrayList<Float> t, ArrayList<Float> d){
    // breaks signal into num_subgraphs separate graphs
    
    for (int s = 0; s < num_subgraphs;s++){
      int start = s*t.size()/num_subgraphs;
      int end = (s+1)*t.size()/num_subgraphs;
      
      CustomGraph sg = new CustomGraph(mainscreen,0,0, "SCL_" + Integer.toString(s) + " - " + fname, start/fs_EDA, end/fs_EDA);
      sg.setup_graph(new ArrayList<Float>(t.subList(start, end)), new ArrayList<Float>(d.subList(start, end)));
      subgraphs_EDA.add(sg);
    }
    
    
  }
  
  void setup_graphs(){
    
     // for adam

    
    
    // for emily
    if (study_type.equals("emily")){
      SCL = new CustomGraph(mainscreen,x_pos,y_pos, "SCL - " + fname, 0/fs_EDA, SCL_time.size()/fs_EDA);
      SCL.setup_graph(SCL_time, SCL_data);
      
      small_EDA = new CustomGraph(mainscreen,x_pos,y_pos, "small", 0/fs_EDA, SCL_time.size()/fs_EDA);
      small_EDA.setup_graph(SCL_time, SCL_data);
      
      make_subgraphs(SCL_time, SCL_data);
    }
  }
  
  void draw_data(){
    
    current_graph = subgraphs_EDA.get(current_subgraph_index);
    //current_graph = SCL;
    current_graph.draw_graph();
    small_EDA.draw_graph();
    
    if (study_type.equals("adam")){
      marker_graph.draw_graph();
    }
     
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
