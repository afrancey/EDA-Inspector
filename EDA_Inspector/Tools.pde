class Tools{
  
  Tools(){
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
  
  String read_header(String name){
    String line = "null";
    try {
        BufferedReader br = new BufferedReader(new FileReader(name));
        line = br.readLine();
        br.close();
        if (line != null){
          return(line);
        }
    } catch(IOException ie) {
    } finally {
    }
    return(line);
  }
  
  int string_date_to_seconds(String t){
    // takes string formatted as "HH:mm:ss" and returns
    // number of seconds since "00:00:00"
    
    int hour = Integer.parseInt(split(t,":")[0]);    
    int min = Integer.parseInt(split(t,":")[1]);
    int sec = Integer.parseInt(split(t,":")[2]);
    
    return(hour*60*60 + min*60 + sec); 
    
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
  
  ArrayList<Integer> sample_boundaries_to_indicator_list(ArrayList<Integer> sample_bounds, int size){
    // generate indicator list
    // indicator_list.get(i) = 1 if data.get(i) is not artifact (outside of sample bounds)
    ArrayList<Integer> indicator_list = new ArrayList<Integer>();
    for (int d = 0; d < size; d++){
      boolean rejected = false;
      for (int bs = 0; bs < sample_bounds.size(); bs = bs+2){
        int start = min(sample_bounds.get(bs), sample_bounds.get(bs+1));
        int end = max(sample_bounds.get(bs), sample_bounds.get(bs+1));
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
    return(indicator_list);
  }
}
