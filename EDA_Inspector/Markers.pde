class Markers{
  String name;
  float[] timestamps;
  double[] raw_timestamps;
  String[] sounds;
  
  float first_beep_time;
  double empatica_start_time = new Double(0);
  int[] low_arousal = {262,172,809,812,708,171,602,377,700,
705,
720,
810,
270,
374,
728,
150,
206,
701,
723,
370,
112,
151,
375,
726,
725,
170,
376,
382};
  int[] marker_colours = {0,0,0,0,0,0,0,
                        1,1,1,1,1,1,1,
                        2,2,2,2,2,2,2,
                        3,3,3,3,3,3,3,
                        0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,
                        0,0,0,0,0,0,0,
                        1,1,1,1,1,1,1,
                        1,1,1,1,1,1,1,
                        1,1,1,1,1,1,1,
                        1,1,1,1,1,1,1,
                        2,2,2,2,2,2,2,
                        2,2,2,2,2,2,2,
                        2,2,2,2,2,2,2,
                        2,2,2,2,2,2,2,
                        3,3,3,3,3,3,3,
                        3,3,3,3,3,3,3,
                        3,3,3,3,3,3,3,
                        3,3,3,3,3,3,3};
  
  
  float[] marker_colours_float;
  int max_marker_colour_type = 3;
  //ColourTable ctable = ColourTable.getPresetColourTable(ColourTable.SPECTRAL,0,1);
  
  Markers(String n){
    name = n;
    get_data();
  }
  
  Markers(String n, double e_s_t){
    name = n;
    empatica_start_time = e_s_t;
    get_data();
  }
  
  void get_data(){
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
    
    raw_timestamps = new double[lines.size()];
    timestamps = new float[lines.size()];
    sounds = new String[lines.size()];
    marker_colours_float = new float[lines.size()];
    for (int i = 0; i < lines.size();i++){
      raw_timestamps[i] = Double.parseDouble(split(lines.get(i), ",")[0]);
      double first_double = raw_timestamps[0];
      timestamps[i] = (float)(raw_timestamps[i] - empatica_start_time);
      sounds[i] = split(lines.get(i), ",")[3];
      
      if (sounds[i].equals("beep") == false){
        
        int colour_index = 1;
        for (int la = 0; la < low_arousal.length; la++){     
          if (Integer.parseInt(sounds[i]) == low_arousal[la]){
            colour_index = 2;
          }
        }
        marker_colours[i] = colour_index;
      }
      marker_colours_float[i] = (float)marker_colours[i]/max_marker_colour_type;
    }
    
    //return(lines);
    first_beep_time = timestamps[0];
  }
}
