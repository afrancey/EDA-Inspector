//import org.gicentre.utils.stat.*;
import java.io.FileReader;
import java.util.Arrays;
import java.util.Date;
import java.text.SimpleDateFormat;

class Empatica extends Device{
  
  Empatica(PApplet parent, String top_path, String fn, String c){
    super(parent, top_path, fn, c, "EDA");
    //listFiles(folder_path);
  }
  
  
  ArrayList<String> checkDevice(){
    // find empatica files
    // each item in top_data_folder needs to be a subfolder containing 6 empatica .csvs
    
    File folder = new File(folder_path);
    
    //get_config_parameters();
    
    String filename = folder.getName();
    if (folder.isFile()) {
      println("File " + folder.getName());
      return(new ArrayList<String>(Arrays.asList(filename, "not a folder")));
    } else if (folder.isDirectory()) {
      File subfolder = new File(top_data_folder + "/" + filename);
      File[] subfiles = subfolder.listFiles();
      
      if (subfiles.length != 8){
        return(new ArrayList<String>(Arrays.asList(filename, "wrong number")));
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
          if (data_max < EDA_threshold){
            return(new ArrayList<String>(Arrays.asList(filename, "device found")));
          } else {
            // rejected for too low EDA
            return(new ArrayList<String>(Arrays.asList(filename, "threshold error")));
          }
        } else {
          // does not have correct files in folder
          return(new ArrayList<String>(Arrays.asList(filename, "wrong files")));
        }
      }
            
    } else {
      // not a file and not a directory (??)
      return(new ArrayList<String>(Arrays.asList(filename, "ERROR")));
    }
  //files_listed = true;
  }
  
  float[] get_mean_for_each_interval(){
    
    // first z-score data
    ArrayList<Float> baseline_score_params = tools.mean_ssd(channel_data.get(0));
    ArrayList<Float> data = channel_data.get(0);
    ArrayList<Float> z_data = tools.zscore_list(data, baseline_score_params.get(0),baseline_score_params.get(1));
  
    ArrayList<Integer> indicator_list = tools.sample_boundaries_to_indicator_list(sample_boundaries.get(0), z_data.size());
    
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
  
  float[] get_slope_for_each_interval(){
    //gets slope of regression line
    ArrayList<Float> baseline_score_params = tools.mean_ssd(channel_data.get(0));
    ArrayList<Float> data = channel_data.get(0);;
    ArrayList<Float> z_data = tools.zscore_list(data, baseline_score_params.get(0),baseline_score_params.get(1));
    
    ArrayList<Integer> indicator_list = tools.sample_boundaries_to_indicator_list(sample_boundaries.get(0), z_data.size());
    
    // now have z-scored list and indicator list
    // get means
   // int num_sections = 30; //num_sections now read from config.txt
    int section_length = z_data.size()/num_sections;
    float[] slopes = new float[num_sections];
    for (int m = 0; m < num_sections; m++){
      int start = m*section_length;
      int end = (m+1)*section_length;
      ArrayList<Float> chop_z = new ArrayList<Float>(z_data.subList(start,end));
      ArrayList<Integer> chop_ind = new ArrayList<Integer>(indicator_list.subList(start,end));
      slopes[m] = get_slope_with_indicator_list(chop_z, chop_ind);
    }
    
    return(slopes);
    
  }
  
  float get_slope_with_indicator_list(ArrayList<Float> z, ArrayList<Integer> ind){
    // first construct two new lists:
    //  - data with rejected values removed
    //  - corresponding timepoints
    
    ArrayList<Float> new_z = new ArrayList<Float>();
    ArrayList<Float> new_t = new ArrayList<Float>();
    for (int i = 0; i < z.size();i++){
      if (ind.get(i) == 1){
        new_z.add(z.get(i));
        new_t.add(i*0.25);
      }
    }
    
    float mean_z = tools.mean_ssd(new_z).get(0);
    float mean_t = tools.mean_ssd(new_t).get(0);
    // find slope of regression line for this data
    float numerator = 0;
    float denominator = 0;
    for (int i = 0; i < new_z.size(); i++){
      numerator+= (new_t.get(i) - mean_t)*(new_z.get(i) - mean_z);
      denominator+= pow(new_t.get(i) - mean_t,2);
    }
    
    float slope = numerator/denominator;
    return(slope);
    
  }
  
  float get_section_mean(ArrayList<Float> data, ArrayList<Integer> indicator){
    // finds mean of all "good" datapoints
    float sum = 0.0;
    float num_indicators = 0.0;
    for (int s = 0; s < data.size();s++){
      if (indicator.get(s) == 1){
          // good data
          sum += data.get(s);
          num_indicators += 1;
      }
    }
    
    float mean = sum/num_indicators; 
    return(mean);
  }
  
}
