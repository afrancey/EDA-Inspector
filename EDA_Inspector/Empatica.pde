//import org.gicentre.utils.stat.*;
import java.io.FileReader;
import java.util.Arrays;
import java.util.Date;
import java.text.SimpleDateFormat;

class Empatica extends Device{
  
  Empatica(PApplet parent, String top_path, String fn, String c){
    super(parent, top_path, fn, c, "EDA");
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
