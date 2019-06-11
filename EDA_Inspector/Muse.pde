//import org.gicentre.utils.stat.*;
import java.io.FileReader;
import java.util.Arrays;
import java.util.Date;
import java.text.SimpleDateFormat;

class Muse extends Device{
  
  Muse(PApplet parent, int x, int y, String top_path, String fn, String c, String s_t){
    
  }
  
  void checkDevice(){
    // find empatica files
    // each item in top_data_folder needs to be a subfolder containing 6 empatica .csvs
    
    File folder = new File(top_data_folder);
    File[] listOfFiles = folder.listFiles();
    
    //get_config_parameters();
    
    for(int i = 0; i < listOfFiles.length; i++) {
      String filename = listOfFiles[i].getName();
      if (listOfFiles[i].isFile()) {
        println("File " + listOfFiles[i].getName());
        Muse new_muse = new Muse(this, 100,100, top_data_folder, filename, "null", "emily");
        muse_list.add(new_muse);
        muse_names.add(filename);
      } 
    }
              
    files_listed = true;
  }
  
}
