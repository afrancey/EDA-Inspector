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
  
  
  ArrayList<String> checkDevice(){'
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
          String condition = split(filename, " ")[1];
      
          if (data_max > EDA_threshold){
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
  
  /*
  
  
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
  
  float[] get_section_slopes(int pnum){
    //gets slope of regression line
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
    
    float mean_z = mean_ssd(new_z).get(0);
    float mean_t = mean_ssd(new_t).get(0);
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
  */
  
}
