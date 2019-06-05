//import org.gicentre.utils.stat.*;
import java.io.FileReader;
import java.util.Arrays;
import java.util.Date;
import java.text.SimpleDateFormat;

class Muse{
  
  int EDA_data_length = 15*60*4; // length (in samples) of data; 15mins * 60secs * 4Hz
  int EDA_starting_index = 0; // index (in original csv) to start from
  
  ArrayList<ArrayList<Float>> channel_data = new ArrayList<ArrayList<Float>>();// = new float[];
  ArrayList<Float> EEG_time = new ArrayList<Float>();
  CustomGraph EEG;
  
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
  
  String fname;
  String empatica_file_time;
  Double double_time;
  
  String study_type;
  
  float max_EDA = 0.0;
  float min_EDA = 999.000;
  
  int[] SCL_indices = new int[2];
  
  int time_lag_empatica = -10800; // empatica files are 3 hours ahead
  
  float[] interval = new float[2];
  int[] interval_index = new int[2];
  
  String time_of_day = "";
  
  Muse(PApplet parent, int x, int y, String top_path, String fn, String c, String s_t){
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
    read_data();
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
        //int diff = string_date_to_seconds(timestring) - string_date_to_seconds(time_of_day);
        
        //EDA_starting_index = 4*diff;
        found_me = true;
      }
    }
    
    if (found_me == false){
      success = false;
    }
  }
  
  void read_data(){
    // read EEG data
    ArrayList<String> lines = read_data_file(folder_path + "/" + "EDA.csv");
    if (lines.size() > 100){
      //get_config_from_file();
      ArrayList<ArrayList<Float>> data_temp = new ArrayList<ArrayList<Float>>();
      ArrayList<Float> time_temp = new ArrayList<Float>();
      
      int sample_count = 0;
      // +1 to account for header
      for (int l = EDA_starting_index + 1; l < EDA_starting_index + EDA_data_length + 1;l++){
        
        String[] line = split(lines.get(l), " "); // line looks like "index[int] tp9[float] tp10[float] fp1[float] fp2[float]
        for (int ch = 1; ch <= 4; ch++){
          //add data for each channel
          data_temp.get(ch-1).add(Float.parseFloat(line[ch]));
        }
        // add time
        time_temp.add(sample_count/fs_EDA);
        
        /*
        //check max
        if (current_datapoint_EDA > max_EDA){
          max_EDA = current_datapoint_EDA;
        }
        
        // check min
        if (current_datapoint_EDA < min_EDA){
          min_EDA = current_datapoint_EDA;
        }
        */
        
        sample_count++;
      }
      
      // round down # data to nearest multiple of num_subgraphs
      int num_data_points_to_use = num_subgraphs*floor(data_temp.get(0).size()/num_subgraphs);
      EEG_time = new ArrayList<Float>(time_temp.subList(0, num_data_points_to_use));
      channel_data = new ArrayList<ArrayList<Float>>();
      for (int ch = 0; ch <=3; ch++){
        channel_data.add(new ArrayList<Float>((data_temp.get(ch).subList(0, num_data_points_to_use))));
      }
      
      // get baseline values
      sample_count = 0;
      
      /*
      for (int l = 2; l < 1202;l++){
        SCL_baseline_d.add(Float.parseFloat(lines.get(l)));
        SCL_baseline_t.add(sample_count/fs_EDA);
        sample_count++;
      }
      */
    }
    
    print("data size ");
    println(EEG_time.size());
                               
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
    // for emily
    if (study_type.equals("emily")){
      EEG = new CustomGraph(mainscreen,x_pos,y_pos, "SCL - " + fname, 0/fs_EDA, EEG_time.size()/fs_EDA);
      EEG.setup_graph(EEG_time, channel_data.get(0));
      
      /*
      small_EDA = new CustomGraph(mainscreen,x_pos,y_pos, "small", 0/fs_EDA, SCL_time.size()/fs_EDA);
      small_EDA.setup_graph(SCL_time, SCL_data);
      */
      
      make_subgraphs(EEG_time, channel_data.get(0));
    } 
    
  }
  
  void draw_data(){
    
    current_graph = subgraphs_EDA.get(current_subgraph_index);
    current_graph.draw_graph();
    small_EDA.draw_graph();
  }
  
}
