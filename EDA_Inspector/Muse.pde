//import org.gicentre.utils.stat.*;
import java.io.FileReader;
import java.util.Arrays;
import java.util.Date;
import java.text.SimpleDateFormat;

class Muse extends Device{
  
  Muse(PApplet parent, String top_path, String fn, String c){
    super(parent, top_path, fn, c, "EEG");
  }
  
  ArrayList<String> checkDevice(){
    // find Muse files
    // just make sure it is file
    
    File eegfile = new File(top_data_folder + "/" + fname);
    
    if (eegfile.isFile()) {
      println("File " + eegfile.getName());
      String header = tools.read_header(top_data_folder + "/" + fname);
      print("header: ");
      println(header);
      if (header.contains("index")){
        return(new ArrayList<String>(Arrays.asList(fname, "device found")));
      } else {
        return(new ArrayList<String>(Arrays.asList(fname, "not a device")));
      }
      
    } else {
      return(new ArrayList<String>(Arrays.asList(fname, "not a file")));
    }
  }
  
}
