class Device{

  Tools tools = new Tools();
  
  int data_length = 0; // length (in samples) of data; 60secs * 220 Hz
  int starting_index = 0; // index (in original csv) to start from
  
  ArrayList<ArrayList<Float>> channel_data = new ArrayList<ArrayList<Float>>();
  ArrayList<Float> timepoints = new ArrayList<Float>();
  
  // subgraphs break each channel into contiguous intervals
  // subgraphs.get(ch).get(i) is the i-th subgraph of the ch-th channel
  ArrayList<ArrayList<CustomGraph>> subgraphs = new ArrayList<ArrayList<CustomGraph>>();
  int current_subgraph_index = 0;
  int num_subgraphs = 4;
  int max_subgraph_index = num_subgraphs - 1;
  
  CustomGraph current_graph;
  CustomGraph small_graph;
    
  String folder_path;
  String[] filenames;
  
  String config_path;
  
  PApplet mainscreen;
  
  String condition;
  String pid;
  
  int x_pos = 0;
  int y_pos = 0;
  
  float fs;//Hz
  float starttime;
  boolean success = true;
  
  String fname;
  String file_time;
  Double double_time;
  
  String study_type;
  
  int time_lag_empatica = -10800; // empatica files are 3 hours ahead
  
  String time_of_day = "";
  int num_channels;
  
  float data_max = -10000;
  float data_min = 10000;
  
  ArrayList<Integer> sample_boundaries = new ArrayList<Integer>();
  
  Device(PApplet parent, String top_path, String fn, String c, String s_t){
    //filenames = fns;
    if (s_t.equals("EEG")){
      num_channels = 4;
    } else {
      num_channels = 1;
    }
    condition = c;
    study_type = s_t;
    fname = fn;
    folder_path = top_path + "/" + fn;
    config_path = top_path + "/config.csv";
    file_time = fn.substring(0,1);
    mainscreen = parent;
    
    if (study_type.equals("EEG")){
      fs = 220;
    } else {
      fs = 4;
    }
    //fills channel_data and timepoints;
    read_data();
        
    println("read data");
    
  }
  
  void setup_device(){
    
    small_graph = new CustomGraph(mainscreen,x_pos,y_pos, "small", 0/fs, timepoints.size()/fs);
    
    println("created graph");
    println(timepoints);
    println(channel_data.get(0));
    small_graph.setup_graph(timepoints, channel_data.get(0));
    make_subgraphs(); 
  }
  
  // override these functions in child class
  ArrayList<String> checkDevice(){return(new ArrayList<String>(Arrays.asList("did you override checkDevice()?", "ERROR")));}
  float[] get_mean_for_each_interval(){return(new float[0]);}
  float[] get_slope_for_each_interval(){return(new float[0]);}
 
  
  void get_config_from_file(){
    // expect config file to be in top_data_folder
    ArrayList<String> lines = tools.read_data_file(config_path);
    
    boolean success = true;
    if (lines.get(1).contains("total time")){
      // expect first line to be "total time,<integer>"
      data_length = (int)fs*Integer.parseInt(split(lines.get(1),",")[1]);
      println("EDA_data_length: " + Integer.toString(data_length));
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
        Date startString = new Date((long)starttime*1000L);
        println(fname + ", " + startString);
        String pattern = "HH:mm:ss";
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat(pattern);
        String time_of_day = simpleDateFormat.format(startString);
        int diff = tools.string_date_to_seconds(timestring) - tools.string_date_to_seconds(time_of_day);
        
        starting_index = (int)fs*diff;
        found_me = true;
      }
    }
    
    if (found_me == false){
      success = false;
    }
  }
  
  void read_data(){
    // read EEG data
    println("inside read data");
    ArrayList<String> lines = tools.read_data_file(folder_path + "/" + "EDA.csv");
    println("read the file");
    if (lines.size() > 100){
      if (study_type.equals("EDA")){   
        starttime = Float.parseFloat(lines.get(0));
      }
      get_config_from_file();
      ArrayList<ArrayList<Float>> data_temp = new ArrayList<ArrayList<Float>>();
      ArrayList<Float> time_temp = new ArrayList<Float>();
      
      int sample_count = 0;
      int header_offset = 0;
      int starting_channel = 0;
      int ending_channel = 0;
      int channel_offset = 0;
      int num_channels = 1;
      
      // EEG:
      // first line is header
      // line looks like "index[int] tp9[float] tp10[float] fp1[float] fp2[float]
      
      // EDA:
      // first line is timestamp
      // second line is sampling rate (Hz)
      // line looks like "datapoint"
      
      if (study_type.equals("EEG")){
        header_offset = 1;
        starting_channel = 1;
        ending_channel = 4;
        channel_offset = 1;
        num_channels = 4;
        
        for (int eeg_ch = 0; eeg_ch < num_channels; eeg_ch++){
          data_temp.add(new ArrayList<Float>());
        }
      } else if (study_type.equals("EDA")){
        header_offset = 2;
        starting_channel = 0;
        ending_channel = 0;
        channel_offset = 0;
        num_channels = 1;
        for (int eda_ch = 0; eda_ch < num_channels; eda_ch++){
          data_temp.add(new ArrayList<Float>());
        }
      }
      for (int l = starting_index + header_offset; l < starting_index + data_length + header_offset;l++){
        
        String[] line = split(lines.get(l), " "); 
       
        for (int ch = starting_channel; ch <= ending_channel; ch++){
          //add data for each channel
          float datapoint = Float.parseFloat(line[ch]);
          data_temp.get(ch-channel_offset).add(datapoint);
          
          // get max and min values
          if (datapoint> data_max){
            data_max = datapoint;
          }
          
          if (datapoint < data_min){
            data_min = datapoint;
          }
        }
        // add time
        time_temp.add(sample_count/fs);
        
        
        sample_count++;
      }
      
      println("finished adding samples");
      println(data_min);
      println(data_max);
      
      // round down # data to nearest multiple of num_subgraphs
      int num_data_points_to_use = num_subgraphs*floor(data_temp.get(0).size()/num_subgraphs);
      timepoints = new ArrayList<Float>(time_temp.subList(0, num_data_points_to_use));
      channel_data = new ArrayList<ArrayList<Float>>();
      for (int ch = 0; ch <num_channels; ch++){
        channel_data.add(new ArrayList<Float>((data_temp.get(ch).subList(0, num_data_points_to_use))));
        println("added channel");
      }
      
      // get baseline values
      sample_count = 0;

    }
    
    print("data size ");
    println(timepoints.size());
                               
  }
  
  void make_subgraphs(){
    // breaks signal into num_subgraphs separate graphs
    
    ArrayList<Float> t = timepoints;
    ArrayList<ArrayList<Float>> d = channel_data;
    
    for (int ch = 0; ch < d.size(); ch++){
      ArrayList<CustomGraph> channel_graphs = new ArrayList<CustomGraph>();
      for (int s = 0; s < num_subgraphs;s++){
        int start = s*t.size()/num_subgraphs;
        int end = (s+1)*t.size()/num_subgraphs;
        
        CustomGraph sg = new CustomGraph(mainscreen,0,0, fname + ", Channel " + Integer.toString(ch) + ", Subgraph " + Integer.toString(s), start/fs, end/fs);
        sg.setup_graph(new ArrayList<Float>(t.subList(start, end)), new ArrayList<Float>(d.get(ch).subList(start, end)));
        channel_graphs.add(sg);
      }
     subgraphs.add(channel_graphs);
    }
  }
  
  void draw_data(){
    current_graph = subgraphs.get(0).get(current_subgraph_index);
    current_graph.draw_graph();
    small_graph.draw_graph();
  } 
}
