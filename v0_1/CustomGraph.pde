//import org.gicentre.utils.stat.*;

class CustomGraph {
  int width_;
  int height_;
  int x_pos;
  int y_pos;
  float fs;
  float T;
  String data_type;
  String title;
  XYChart lineChart;
  
  float maxX;
  float minX;
  
  float[] colours;
  
  float left_spacing;
  
  boolean empty_chart = true;
  
  ColourTable ctable = new ColourTable();
  
  CustomGraph(PApplet parent, int x, int y, String t, float miX, float maX){
    lineChart = new XYChart(parent);
    x_pos = x;
    y_pos = y;
    title = t;
    
    maxX = maX;
    minX = miX;
    
    ctable.addContinuousColourRule(0.0/3, 0,0,0);
    ctable.addContinuousColourRule(1.0/3, 255,0,0);
    ctable.addContinuousColourRule(2.0/3, 0,255, 0);
    ctable.addContinuousColourRule(1.0, 0,0,255);
  }
  
  void setup_graph(ArrayList<Float> t, ArrayList<Float> d){
    // Both x and y data set here.
    
    // turn arraylists into float[]
    float[] time = new float[t.size()];
    float[] data = new float[t.size()];
    for (int i = 0; i < t.size();i++){
      time[i] = t.get(i);
      data[i] = d.get(i);
    }
    lineChart.setData(time, data);
    
    if (data.length>0){
      empty_chart = false;
    }
     
    // Axis formatting and labels.
    lineChart.showXAxis(true); 
    lineChart.showYAxis(true); 
    //lineChart.setMinY(0);
    lineChart.setMinX(minX);
    lineChart.setMaxX(maxX);
    
    if (title.contains("X")){
      lineChart.setYAxisLabel("acceleration");
    }
    if (title.contains("BVP")){
      lineChart.setYAxisLabel("BVP");
    } else {
      lineChart.setYAxisLabel("XAcc");
    }
    
    lineChart.setXAxisLabel("seconds");
    
    //lineChart.setYFormat("$###,###");  // Monetary value in $US
    //lineChart.setXFormat("0000");      // Year
     
    // Symbol colours
    lineChart.setPointColour(color(180,50,50,100));
    lineChart.setPointSize(5);
    lineChart.setLineWidth(2);
    left_spacing = lineChart.getLeftSpacing();
  }
  
  void setup_graph(float[] t, float[] colour_data){
    // for markers
   
    
    float[] time = new float[t.length];
    float[] data = new float[t.length];
    for (int p = 0 ; p < t.length ; p++){
      time[p] = t[p];
      data[p] = 0;
    }
    
    //println(time);
    //println(t);
    
    lineChart.setData(time, data);
    

    // Axis formatting and labels.
    lineChart.showXAxis(true); 
    lineChart.showYAxis(true); 
    lineChart.setMinY(0);
    lineChart.setMinX(minX);
    lineChart.setMaxX(maxX);
       
    lineChart.setYFormat("0000");  // Monetary value in $US
    //lineChart.setXFormat("0000");      // Year
     
    // Symbol colours
    lineChart.setPointColour(colour_data, ctable);
    lineChart.setPointSize(10);
    lineChart.setLineWidth(0);
    
    left_spacing = lineChart.getLeftSpacing();
  }
  
  void draw_graph(){
    textSize(30);
    if (empty_chart == false){
      lineChart.draw(x_pos - lineChart.getLeftSpacing(),y_pos+20,1700+lineChart.getLeftSpacing(),500);
      //lineChart.draw(x_pos - lineChart.getLeftSpacing(),y_pos+10,600+lineChart.getLeftSpacing(),400);
      //lineChart.draw(100,0,900,400);
      
      //lineChart.draw(0,0,1600,600);
    } else {
      text(title, x_pos+500,y_pos+700);
      text("empty chart", x_pos+500,y_pos+725);
    }

     
    // Draw a title over the top of the chart.
    fill(120);
    text(title, x_pos+500,y_pos+700);
    //PVector mousepos = new PVector(100,50);
    //println(lineChart.getScreenToData(mousepos));
  }
}
  
