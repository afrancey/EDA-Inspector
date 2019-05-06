//import org.gicentre.utils.stat.*;
import java.io.FileReader;
import java.util.Arrays;

class Empatica{
  
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
  int max_subgraph_index = 3;
  
  CustomGraph current_graph;
    
  String folder_path;
  String[] filenames;
  
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
  
  int[] SCL_indices = new int[2];
  int[] ACC_indices = new int[2];
  int[] BVP_indices = new int[2];
  
  int time_lag_empatica = -10800; // empatica files are 3 hours ahead
  
  float[] interval = new float[2];
  int[] interval_index = new int[2];
  
  Markers markers;
  CustomGraph marker_graph;
  
  ArrayList<ROI> rois = new ArrayList<ROI>();
  
  Empatica(PApplet parent, int x, int y, String top_path, String fn, String c, String s_t){
    //filenames = fns;
    x_pos = x;
    y_pos = y;
    condition = c;
    study_type = s_t;
    fname = fn;
    folder_path = top_path + "/" + fn;
    empatica_file_time = fn.substring(0,1);
    if (study_type != "emily"){
      empatica_file_time = fn.substring(0,10);
    }
    mainscreen = parent;
    get_pid();
    get_markers();
    if (study_type.equals("emily")){
      read_data();
    } else {
      read_data_adam();
    }
    get_interval("stim wave nothing");
    if (study_type.equals("adam")){
      generate_ROI_adam();
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
  
  void read_data(){
    // read EDA data
    ArrayList<String> lines = read_data_file(folder_path + "/" + "EDA.csv");
    if (lines.size() > 100){
      starttime_EDA = Float.parseFloat(lines.get(0));
      fs_EDA = Float.parseFloat(lines.get(1));
      
      int sample_count = 0;
      for (int l = lines.size() - 3000; l < lines.size() - 600;l++){
        
        float current_datapoint_EDA = Float.parseFloat(lines.get(l));
        // add data
        SCL_data.add(current_datapoint_EDA);
        SCL_time.add(sample_count/fs_EDA);
        
        //check max
        if (current_datapoint_EDA > max_EDA){
          max_EDA = current_datapoint_EDA;
        }
        
        sample_count++;
      }
      sample_count = 0;
      for (int l = 2; l < 1202;l++){
        SCL_baseline_d.add(Float.parseFloat(lines.get(l)));
        SCL_baseline_t.add(sample_count/fs_EDA);
        sample_count++;
      }
    }
    
    print("data size ");
    println(SCL_data.size());
    
    //zscore_EDA();
    
    lines = read_data_file(folder_path + "/" + "TEMP.csv");
    if (lines.size() > 100){
      starttime_TEMP = Float.parseFloat(lines.get(0));
      fs_TEMP = Float.parseFloat(lines.get(1));
      
      int sample_count = 0;
      for (int l = lines.size() - 3600; l < lines.size();l++){
        temp_data.add(Float.parseFloat(lines.get(l)));
        temp_time.add(sample_count/fs_TEMP);
        sample_count++;
      }
    }
    
    lines = read_data_file(folder_path + "/" + "BVP.csv");
    if (lines.size() > 100){
      starttime_BVP = Float.parseFloat(lines.get(0));
      fs_BVP = Float.parseFloat(lines.get(1));
      
      int sample_count = 0;
      for (int l = lines.size() - 57600; l < lines.size();l++){
        BVP_data.add(Float.parseFloat(lines.get(l)));
        BVP_time.add(sample_count/fs_TEMP);
        sample_count++;
      }
    }
    
    lines = read_data_file(folder_path + "/" + "ACC.csv");
    if (lines.size() > 100){
      starttime_ACC = Float.parseFloat(split(lines.get(0),",")[0]);
      fs_ACC = Float.parseFloat(split(lines.get(1),",")[0]);
      
      int sample_count = 0;
      for (int l = lines.size() - 28800; l < lines.size();l++){
        //println(lines.get(l));
        acc_x_data.add(Float.parseFloat(split(lines.get(l),",")[0]));
        acc_y_data.add(Float.parseFloat(split(lines.get(l),",")[1]));
        acc_z_data.add(Float.parseFloat(split(lines.get(l),",")[2]));
        acc_time.add(sample_count/fs_ACC);
        sample_count++;
      }
    }
                                 
  }
  
  void make_subgraphs(int num_subgraphs, ArrayList<Float> t, ArrayList<Float> d){
    // breaks signal into num_subgraphs separate graphs
    
    int num_data_points_to_use = num_subgraphs*floor(t.size()/num_subgraphs); // round down # data to nearest multiple of num_subgraphs
    
    ArrayList<Float> time = new ArrayList<Float>(t.subList(0, num_data_points_to_use));
    ArrayList<Float> data = new ArrayList<Float>(d.subList(0, num_data_points_to_use));
    
    
    for (int s = 0; s < num_subgraphs;s++){
      int start = s*num_data_points_to_use/num_subgraphs;
      int end = (s+1)*num_data_points_to_use/num_subgraphs;
      
      CustomGraph sg = new CustomGraph(mainscreen,0,0, "SCL_" + Integer.toString(s) + " - " + fname, start/fs_EDA, end/fs_EDA);
      sg.setup_graph(new ArrayList<Float>(time.subList(start, end)), new ArrayList<Float>(data.subList(start, end)));
      subgraphs_EDA.add(sg);
    }
    
    
  }
  void read_data_adam(){
    // read EDA data
    ArrayList<String> lines = read_data_file(folder_path + "/" + "EDA.csv");
    if (lines.size() > 100){
      starttime_EDA = Float.parseFloat(lines.get(0));
      fs_EDA = Float.parseFloat(lines.get(1));
      
      int sample_count = 0;
      for (int l = 2; l < lines.size();l++){
      //for (int l = 0; l < 240;l++){
        SCL_data.add(Float.parseFloat(lines.get(l)));
        SCL_time.add(sample_count/fs_EDA);
        sample_count++;
      }
    }
    
    lines = read_data_file(folder_path + "/" + "TEMP.csv");
    if (lines.size() > 100){
      starttime_TEMP = Float.parseFloat(lines.get(0));
      fs_TEMP = Float.parseFloat(lines.get(1));
      
      int sample_count = 0;
      for (int l = 2; l < lines.size();l++){
        temp_data.add(Float.parseFloat(lines.get(l)));
        temp_time.add(sample_count/fs_TEMP);
        sample_count++;
      }
    }
    
    lines = read_data_file(folder_path + "/" + "BVP.csv");
    if (lines.size() > 100){
      starttime_BVP = Float.parseFloat(lines.get(0));
      fs_BVP = Float.parseFloat(lines.get(1));
      
      int sample_count = 0;
      for (int l = 2; l < lines.size();l++){
        BVP_data.add(Float.parseFloat(lines.get(l)));
        BVP_time.add(sample_count/fs_BVP);
        sample_count++;
      }
    }
    
    lines = read_data_file(folder_path + "/" + "ACC.csv");
    if (lines.size() > 100){
      starttime_ACC = Float.parseFloat(split(lines.get(0),",")[0]);
      fs_ACC = Float.parseFloat(split(lines.get(1),",")[0]);
      
      int sample_count = 0;
      for (int l = 2; l < lines.size();l++){
        //println(lines.get(l));
        acc_x_data.add(Float.parseFloat(split(lines.get(l),",")[0]));
        acc_y_data.add(Float.parseFloat(split(lines.get(l),",")[1]));
        acc_z_data.add(Float.parseFloat(split(lines.get(l),",")[2]));
        acc_time.add(sample_count/fs_ACC);
        sample_count++;
      }
    }
                                 
  }
  
  void get_pid(){
    int[] valid_empatica_participants = {5,6,7,8,9,10,12,13,14,17,18,19, 20, 21, 22, 23, 24, 25, 26};
    for (int i = 0; i < valid_empatica_participants.length; i++){
      if (fname.contains("__" + Integer.toString(valid_empatica_participants[i]))){
        pid_adam = Integer.toString(valid_empatica_participants[i]);  
        println(pid_adam);
      }
    }
  }
  
  void setup_graphs(){
    //zscore_EDA();
    
     // for adam

    
    
    // for emily
    if (study_type.equals("emily")){
      SCL = new CustomGraph(mainscreen,x_pos,y_pos, "SCL - " + fname, interval[0]/fs_EDA, interval[1]/fs_EDA);
      SCL.setup_graph(SCL_time, SCL_data);
      
      small_EDA = new CustomGraph(mainscreen,x_pos,y_pos, "small", interval[0]/fs_EDA, interval[1]/fs_EDA);
      small_EDA.setup_graph(SCL_time, SCL_data);
      
      make_subgraphs(4, SCL_time, SCL_data);
      
      //acc_x = new CustomGraph(mainscreen,x_pos,y_pos + 400, "X - " + fname, interval[0]/fs_EDA, interval[1]/fs_EDA);
      //acc_x.setup_graph(acc_time, acc_x_data);
    }
    
    
    if (study_type.equals("adam")){
      ArrayList<Float> SCL_time_chop = new ArrayList<Float>(SCL_time.subList((int)(interval[0]*fs_EDA),min((int)(interval[1]*fs_EDA), SCL_time.size())));
      ArrayList<Float> SCL_data_chop = new ArrayList<Float>(SCL_data.subList((int)(interval[0]*fs_EDA),min((int)(interval[1]*fs_EDA), SCL_data.size())));
      SCL = new CustomGraph(mainscreen,x_pos,y_pos, "SCL - " + fname, interval[0], interval[1]);
      SCL.setup_graph(SCL_time_chop, SCL_data_chop);
    
      ArrayList<Float> SCL_wave_t = new ArrayList<Float>(SCL_time.subList((int)(markers.timestamps[7]*fs_EDA),min((int)(markers.timestamps[14]*fs_EDA), SCL_time.size())));
      ArrayList<Float> SCL_wave_d = new ArrayList<Float>(SCL_data.subList((int)(markers.timestamps[7]*fs_EDA),min((int)(markers.timestamps[14]*fs_EDA), SCL_data.size())));
      SCL_wave = new CustomGraph(mainscreen,x_pos,y_pos+325, "SCL wave - " + fname, markers.timestamps[7], markers.timestamps[14]);
      SCL_wave.setup_graph(SCL_wave_t, SCL_wave_d);
      
      ArrayList<Float> SCL_walk_t = new ArrayList<Float>(SCL_time.subList((int)(markers.timestamps[21]*fs_EDA),min((int)(markers.timestamps[28]*fs_EDA), SCL_time.size())));
      ArrayList<Float> SCL_walk_d = new ArrayList<Float>(SCL_data.subList((int)(markers.timestamps[21]*fs_EDA),min((int)(markers.timestamps[28]*fs_EDA), SCL_data.size())));
      SCL_walk = new CustomGraph(mainscreen,x_pos,y_pos+650, "SCL walk - " + fname, markers.timestamps[21], markers.timestamps[28]);
      SCL_walk.setup_graph(SCL_walk_t, SCL_walk_d);
      
      marker_graph = new CustomGraph(mainscreen,x_pos,y_pos, "                                                  ++ MARKERS - " + fname, interval[0], interval[1]);
      marker_graph.setup_graph(Arrays.copyOfRange(markers.timestamps, interval_index[0],interval_index[1]+1), Arrays.copyOfRange(markers.marker_colours_float, interval_index[0], interval_index[1]+1));
    }
    
    
    /*
    ArrayList<Float> temp_time_chop = new ArrayList<Float>(temp_time.subList((int)(interval[0]*fs_TEMP),min((int)(interval[1]*fs_TEMP), temp_time.size())));
    ArrayList<Float> temp_data_chop = new ArrayList<Float>(temp_data.subList((int)(interval[0]*fs_TEMP),min((int)(interval[1]*fs_TEMP), temp_data.size())));
    temp = new CustomGraph(mainscreen,x_pos,y_pos, "TEMP - " + fname, interval[0], interval[1]);
    temp.setup_graph(temp_time_chop, temp_data_chop);
    
    ArrayList<Float> BVP_time_chop = new ArrayList<Float>(BVP_time.subList((int)(interval[0]*fs_BVP),min((int)(interval[1]*fs_BVP), BVP_time.size())));
    ArrayList<Float> BVP_data_chop = new ArrayList<Float>(BVP_data.subList((int)(interval[0]*fs_BVP),min((int)(interval[1]*fs_BVP), BVP_data.size())));
    BVP = new CustomGraph(mainscreen,x_pos,y_pos + 500, "BVP - " + fname, interval[0], interval[1]);
    BVP.setup_graph(BVP_time_chop, BVP_data_chop);
    //BVP.setup_graph(BVP_time, BVP_data);
    
    */
    
    /*
    ArrayList<Float> acc_time_chop = new ArrayList<Float>(acc_time.subList((int)(interval[0]*fs_ACC),min((int)(interval[1]*fs_ACC), acc_time.size())));
    ArrayList<Float> acc_x_data_chop = new ArrayList<Float>(acc_x_data.subList((int)(interval[0]*fs_ACC),min((int)(interval[1]*fs_ACC), acc_x_data.size())));
    ArrayList<Float> acc_y_data_chop = new ArrayList<Float>(acc_y_data.subList((int)(interval[0]*fs_ACC),min((int)(interval[1]*fs_ACC), acc_y_data.size())));
    ArrayList<Float> acc_z_data_chop = new ArrayList<Float>(acc_z_data.subList((int)(interval[0]*fs_ACC),min((int)(interval[1]*fs_ACC), acc_z_data.size())));
    acc_x = new CustomGraph(mainscreen,x_pos,y_pos, "X - " + fname, interval[0], interval[1]);
    acc_y = new CustomGraph(mainscreen,x_pos + 1000,y_pos+300, "y - " + fname, interval[0], interval[1]);
    acc_z = new CustomGraph(mainscreen,x_pos + 1000,y_pos+600, "z - " + fname, interval[0], interval[1]);
    
    acc_x.setup_graph(acc_time_chop, acc_x_data_chop);
    acc_y.setup_graph(acc_time_chop, acc_y_data_chop);
    acc_z.setup_graph(acc_time_chop, acc_z_data_chop);
    */
    

    
    
  }
  
  void draw_data(){
    
    current_graph = subgraphs_EDA.get(current_subgraph_index);
    //current_graph = SCL;
    current_graph.draw_graph();
    
    //SCL.draw_graph();
    //subgraphs_EDA.get(0).draw_graph();
    small_EDA.draw_graph();
    //SCL_walk.draw_graph();
    //SCL_wave.draw_graph();
    //temp.draw_graph();
    //BVP.draw_graph();
    
    
    //acc_x.draw_graph();
    //acc_y.draw_graph();
    //acc_z.draw_graph();
    
    if (study_type.equals("adam")){
      marker_graph.draw_graph();
    }
    
    /*
    for (int roi = 0; roi < 1;roi++){
      rois.get(roi).draw_data();
    }
    */
    
    
    
  }
  
  void get_markers(){
    //println("getting marker");
    File folder = new File("C:/Users/alzfr/Desktop/expt 3 data/stimuli");
    File[] listOfFiles = folder.listFiles();
    
    for(int i = 0; i < listOfFiles.length; i++) {
      if (listOfFiles[i].isFile()) {
        //println("File " + listOfFiles[i].getName());
        if (listOfFiles[i].getName().contains("_" + pid_adam)){
          markers = new Markers("C:/Users/alzfr/Desktop/expt 3 data/stimuli/" + listOfFiles[i].getName(), Double.parseDouble(empatica_file_time) + (double)time_lag_empatica);
        }
      }
    }
  }
  
  void get_interval(String section){
    if (study_type.equals("adam")){
      // intervals in time!!!
      if (section.equals("baseline stand")){
        interval_index[0] = 0;
        interval_index[1] = 7;
      } else if (section.equals("baseline wave nothing")){
        interval_index[0] = 7;
        interval_index[1] = 14;
      } else if (section.equals("baseline wave LAS")){
        interval_index[0] = 14;
        interval_index[1] = 21;
      }else if (section.equals("baseline walk")){
        interval_index[0] = 21;
        interval_index[1] = 28;
      }else if (section.equals("stim stand")){
        interval_index[0] = 28;
        interval_index[1] = 56;
      }else if (section.equals("stim wave nothing")){
        interval_index[0] = 56;
        interval_index[1] = 84;
      }else if (section.equals("stim wave LAS")){
        interval_index[0] = 84;
        interval_index[1] = 112;
      }else if (section.equals("stim walk")){
        interval_index[0] = 112;
        interval_index[1] = 139;
      } else {
        interval_index[0] = 28;
        interval_index[1] = 56;
        //interval_index[0] = 0;
        //interval_index[1] = markers.timestamps.length-1;
      }
      interval[0] = markers.timestamps[interval_index[0]];
      interval[1] = markers.timestamps[interval_index[1]];
    } else if (study_type.equals("emily")){
      // intervals is element index!!!!
      interval[0] = 0;
      interval[1] = 2400; // 10 minutes
      //interval[0] = 730*4;
      //interval[1] = 800*4; // 15 minutes
    } else {
    }
  }
  
  void zscore_EDA(){
    
    // create array of baseline standing values
    ArrayList<Float> baseline = new ArrayList<Float>(SCL_data.subList((int)(markers.timestamps[0]*fs_EDA),(int)(markers.timestamps[6]*fs_EDA)));
    
    // calculate mean
    float sum = 0;
    for (int i = 0; i < baseline.size();i++){
      sum+=baseline.get(i);
    }
    float mean = sum/baseline.size();
    
    //calculate sample SD
    float sum_of_squares = 0;
    for (int i = 0; i < baseline.size();i++){
      sum_of_squares+=pow(baseline.get(i) - mean,2);
    }
    
    float ssd = pow(sum_of_squares/(baseline.size()-1),0.5);
    
    for (int i = 0; i < SCL_data.size(); i++){
      float val = (SCL_data.get(i) - mean)/ssd;
      SCL_data.set(i, val);
    }
  }
  

  
  
  void generate_ROI_adam(){
    // for first 28, wait two seconds after timestamp, then ROI 5 seconds
    String stim_type = "none";
    for (int s = 0; s < 28; s++){
      ArrayList<Float> time_array = new ArrayList<Float>(SCL_time.subList((int)((markers.timestamps[s]+2)*fs_EDA), (int)((markers.timestamps[s] + 8)*fs_EDA)));
      ArrayList<Float> data_array = new ArrayList<Float>(SCL_data.subList((int)((markers.timestamps[s]+2)*fs_EDA), (int)((markers.timestamps[s] + 8)*fs_EDA))); 
      rois.add(new ROI(mainscreen, fs_EDA, time_array, data_array));
    }
    for (int s = 28; s < 140; s = s+2){
      
      int colour = markers.marker_colours[s+1];
      print("colour ");
      println(colour);
      if (colour == 2){
        stim_type = "low";
        println("low");
      } else {
        stim_type = "high";
      }
      
      ArrayList<Float> time_array = new ArrayList<Float>(SCL_time.subList((int)((markers.timestamps[s]+2)*fs_EDA), (int)((markers.timestamps[s] + 8)*fs_EDA)));
      ArrayList<Float> data_array = new ArrayList<Float>(SCL_data.subList((int)((markers.timestamps[s]+2)*fs_EDA), (int)((markers.timestamps[s] + 8)*fs_EDA)));
      ROI roi = new ROI(mainscreen, fs_EDA, time_array, data_array);
      roi.set_stim_type(stim_type);
      print("rois stim type ");
      println(roi.stim_type);
      rois.add(roi);
    }

  }
}
  