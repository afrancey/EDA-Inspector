class ROI{
  ArrayList<Float> timestamps = new ArrayList<Float>();
  ArrayList<Float> data = new ArrayList<Float>();
  ArrayList<Float> diff_t = new ArrayList<Float>();
  ArrayList<Float> diff_d = new ArrayList<Float>();
  float h_EDA;
  float area;
  int num_peaks;
  String stim_type = "none";
  ArrayList<CustomGraph> graphs = new ArrayList<CustomGraph>();
  PApplet mainscreen;
  ROI(PApplet parent, float[] t, float[] d, int fs_EDA){
    mainscreen = parent;
    h_EDA = 1.0/((float)fs_EDA);
    
    for (int i = 0; i < t.length; i++){
      timestamps.add(t[i]);
      data.add(d[i]);
    }
    
    get_centered_difference();
    
    //
    graphs.add(new CustomGraph(mainscreen, 0, 0, "raw", t[0], t[t.length -1]));
    graphs.add(new CustomGraph(mainscreen, 0, 400, "first derivative", t[0], t[t.length -1]));
    
    graphs.get(0).setup_graph(timestamps, data);
    graphs.get(1).setup_graph(diff_t, diff_d);  
    area = get_area();
    num_peaks = number_of_extrema();
  }
  
  ROI(PApplet parent, float fs_EDA, ArrayList<Float> t, ArrayList<Float> d){
    mainscreen = parent;
    h_EDA = 1.0/((float)fs_EDA);
    
    for (int i = 0; i < t.size(); i++){
      timestamps.add(t.get(i));
      data.add(d.get(i));
    }
    
    get_centered_difference();
    
    //
    graphs.add(new CustomGraph(mainscreen, 100, 0, "raw", t.get(0), t.get(t.size() -1)));
    graphs.add(new CustomGraph(mainscreen, 100, 400, "first derivative", t.get(0), t.get(t.size() -1)));
    
    graphs.get(0).setup_graph(timestamps, data);
    graphs.get(1).setup_graph(diff_t, diff_d);
    area = get_area();
    num_peaks = number_of_extrema();
  }
  void get_centered_difference(){
    for (int t = 1; t < (timestamps.size() - 2) + 1; t++){
      diff_t.add(timestamps.get(t));
      diff_d.add(0.5*(data.get(t+1) - data.get(t-1))/h_EDA);
    }
  }
  
  int number_of_extrema(){
    String current_sign;
    int num_sign_switches = 0;
    if (diff_d.get(0) >= 0.0){
      // initialize current_sign
      current_sign = "+";
    } else {
      current_sign = "-";
    }
    
    for (int d = 0; d < diff_d.size(); d++){
      if (current_sign.equals("+")){
        if (diff_d.get(d) < 0.0){
          current_sign.equals("-");
          num_sign_switches++;
        }
      } else {
        if (diff_d.get(d) > 0.0){
          current_sign.equals("+");
          num_sign_switches++;
        }        
      }
      // if diff_d.get(d) == 0.0, leave sign be (inflection points not counted!)
    }
    return(num_sign_switches);
  }
  
  float get_area(){
    // first demean data, then take absolute value
    ArrayList<Float> demeaned = new ArrayList<Float>();
    float mean = 0.0;
    for (int d = 0; d < data.size(); d++){
      mean+=data.get(d);
    }
    mean = mean/data.size();
    
    for (int d = 0; d < data.size(); d++){
      demeaned.add(abs(data.get(d) - mean));
    }
    
    // trapezoidal rule area
    float sum = 0.0;
    for (int dm = 1; dm < demeaned.size() - 1; dm++){
      sum+=demeaned.get(dm);
    }
    
    float factor = 2*sum + demeaned.get(0) + demeaned.get(demeaned.size() - 1);
    float result = 0.5*h_EDA*factor;
    return(result);
    
    
  }
  
  void draw_data(){
    for (int i = 0; i < graphs.size(); i++){
      graphs.get(i).draw_graph();
    }
  }
  
  void set_stim_type(String st){
    stim_type = st;
    print("set stim type"); 
    println(stim_type);
    
  }
}
