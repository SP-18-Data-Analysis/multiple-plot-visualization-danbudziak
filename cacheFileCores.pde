// This function is required, this is called once, and used to setup your 
// visualization environment
int mode = 0;
int modeCount = 0;
float dataMin;
float dataMax;

int columnCount = 0;
int[] triples;
int tripleMin;
int tripleMax;
FloatTable data;
float plotX1, plotY1;
float plotX2, plotY2;

float labelX, labelY;

// Small tick line
int volumeIntervalMinor = 5;

// Big tick line
int volumeInterval = 1000;

int currentColumn;
int yearInterval = 10;
int cetusColumn = 0;
int cooleyColumn = 1;

int rowCount;

// Tab variables for the menus
float[] tabLeft, tabRight; // Add above setup() 
float tabTop, tabBottom;
float tabPad = 10;
int visualization = 0;
int vizCount = 4;
int yMarks;


void setup() {
    // This is your screen resolution, width, height
    //  upper left starts at 0, bottom right is max width,height
   	size(750,400);
   //Drawing a legend to be displayed
   rect(10,10,100,50);
   
  
    // This calls the class FloatTable - java class 
  	data = new FloatTable("cacheFileCores.tsv");
  	rowCount = data.getRowCount();
  	print("row count " + rowCount + "\n");

  	// Retrieve number of columns in the dataset
  	columnCount = data.getColumnCount();
  	dataMin = 0;
  	dataMax = data.getTableMax();
    yMarks = (int) dataMax / rowCount;
    print("Y marks " + yMarks + "\n");
  	triples = int(data.getRowNames());  
  	tripleMin = 0; // triples[0];
  	tripleMax = triples[triples.length - 1];
  	print("Min " + tripleMin + " max " + tripleMax + " column count " + columnCount + "\n");
    
    // Corners of the plotted time series
  	plotX1 = 120;
  	plotX2 = width - 80;
  	labelX = 50;
  	plotY1 = 60;
  	plotY2 = height - 70;
  	labelY = height - 25;
   
  	// Print out the columns in this dataset 
  	int numColumns = data.getColumnCount();
  	int numRows = data.getRowCount();
    
    rowCount = data.getRowCount();

    for (int row = 0; row < rowCount; row++) {
    	float initialValue = data.getFloat(row, 0);
      	print("value " + initialValue + "\n");
    }    
}

//Require function that outputs the visualization specified in this function
// for every frame. 
void draw() {
    
  	// Filling the screen white (FFFF) -- all ones, black (0000)
  	background(255);
  	drawVisualizationWindow();
 	drawGraphLabels();
 
   // These functions contain the labels along with the tick marks
	drawYTickMarks();
  	drawXTickMarks();
  	drawDataPoints();
}

void drawTitleTabs() { 
  rectMode(CORNERS); 
  noStroke( ); 
  textSize(20); 
  textAlign(LEFT);
  // On first use of this method, allocate space for an array
  // to store the values for the left and right edges of the tabs.
  if (tabLeft == null) {
    tabLeft = new float[columnCount];
    tabRight = new float[columnCount];
  }
  float runningX = plotX1;
  tabTop = plotY1 - textAscent() - 15; 
  tabBottom = plotY1;
  for (int col = 0; col < columnCount; col++) {
    String title = data.getColumnName(col);
    tabLeft[col] = runningX;
    float titleWidth = textWidth(title);
    tabRight[col] = tabLeft[col] + tabPad + titleWidth + tabPad;
    // If the current tab, set its background white; otherwise use pale gray.
    fill(col == currentColumn ? 255 : 224);
    rect(tabLeft[col], tabTop, tabRight[col], tabBottom);
    // If the current tab, use black for the text; otherwise use dark gray.
    fill(col == currentColumn ? 0 : 64);
    text(title, runningX + tabPad, plotY1 - 10);
    runningX = tabRight[col];
  }
}


void mousePressed() {
  
  // This is modulating from 1 to 3
  //  currentColumn = columnCount % 3;
  //  columnCount += 1;

  
   if (mouseY > tabTop && mouseY < tabBottom) {
    for (int col = 0; col < columnCount; col++) {
      if (mouseX > tabLeft[col] && mouseX < tabRight[col]) {
        setColumn(col);
      }
    }
  }
  
  
}
void keyPressed() {
  if ( key == 't') {
      // Show bar graph
      visualization = visualization + 1;
	  if (visualization == vizCount) visualization = 0;
   }
  
}

void setColumn(int col) {

	/*
       if (col != currentColumn) {
         currentColumn = col;
          for (int row = 0; row < rowCount; row++) {
            interpolators[row].target(data.getFloat(row, col));
          }
       }
  
   */  
     
}

void drawVolumeData(int col) {

  beginShape( );
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row, col)) {
      //float value = interpolators[row].value;
      float value = data.getFloat(row, col);
      float x = map(triples[row], tripleMin, tripleMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      vertex(x, y);
    }
  }
  // Draw the lower-right and lower-left corners.
  vertex(plotX2, plotY2);
  vertex(plotX1, plotY2);
  endShape(CLOSE);  
}

void drawDataPoints() {

  fill(#0000FF);   // Color blue
  for ( int row = 0; row < rowCount; row++ ) {
	  float value = data.getFloat(row,cooleyColumn);
    
    float y = mapLog(value);
    float x = map(row,0,rowCount-1,plotX1,plotX2);
    //float y = map(myPoint, 0, rowCount-1, plotY2, plotY1);
    // float y = map(newValue, 0, rowCount-1, plotY2, plotY1);
    ellipse(x, y, 8, 8);

  }

  fill(#FF0000);   // Color red
  for ( int row = 0; row < rowCount; row++ ) {
    float value = data.getFloat(row,cooleyColumn);
    float x = map(triples[row], tripleMin, tripleMax, plotX1, plotX2);
    float y = map(value, dataMin, dataMax, plotY2, plotY1);
    ellipse(x, y, 7, 7);

  }

}

void drawDataLine(int col) {
  beginShape( );
  rowCount = data.getRowCount();
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row, cooleyColumn)) {
      float value = data.getFloat(row, col);
      float x = map(triples[row], tripleMin, tripleMax, plotX1, plotX2); 
      float y = map(value, dataMin, dataMax, plotY2, plotY1); 
      vertex(x, y);
    }
    
    
  }
  endShape( );
}


float barWidth = 1; // Add to the end of setup()
void drawDataBars(int col) {
  /*
  noStroke( );
  rectMode(CORNERS);
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row, col)) {
      // float value = data.getFloat(row, col);
      float value = interpolators[row].value;
     // float value = data.getFloat(row, col);
      float x = map(triples[row], tripleMin, tripleMax, plotX1, plotX2); 
      float y = map(value, dataMin, dataMax, plotY2, plotY1); 
      rect(x-barWidth/2, y, x+barWidth/2, plotY2);
    }
  }*/
  
}

void drawYTickMarks() {
  fill(0);
  textSize(10);

  stroke(1);
  strokeWeight(1);
  int tickStart = 0;
 // float marker = dataMin;
//  for (float v = dataMin; v <= dataMax; v += 500) { 
    for (int i = 0; i < rowCount; i++ ) {
   // if (v % volumeIntervalMinor == 0) { // If a tick mark
   
      float y = map(i, 0, rowCount-1, plotY2, plotY1);
     // if (i % volumeInterval == 0) { // If a major tick mark
        if (i == 0) {
          textAlign(RIGHT); // Align by the bottom
        } else if (i == rowCount - 1) {
          textAlign(RIGHT, TOP); // Align by the top
        } else {
          textAlign(RIGHT, CENTER); // Center vertically
        }
        
        text((int) pow(2,tickStart), plotX1 - 10, y);
        tickStart += 1;
        line(plotX1 - 4, y, plotX1, y); // Draw major tick
    //  } 
      
 //     else {
 //       line(plotX1 - 2, y, plotX1, y); // Draw minor tick
 //     }
//    }
   // marker = marker + v;
  }  
  
}

float mapLog(float value) {
   int startPoint = 8;
   float newVal = 0;
   for (int i = 0; i < rowCount; i ++ ) {
      
      float lowValue =  pow(2,startPoint);
      float topValue =  pow(2,startPoint+1);
      startPoint += 1;
      
      if (value > lowValue && value < topValue) {
         
         newVal = map(log(value), log(lowValue), log(topValue), i,i+1);
        
      }  
   }
   
  float y = map(newVal, 0, rowCount-1, plotY2, plotY1);
  return y;
  
}




void drawXTickMarks() {
  
  fill(0);
  textSize(10);
  textAlign(CENTER, TOP);

  // Use thin, gray lines to draw the grid.
  stroke(1);
  strokeWeight(1);


  for (int row = 0; row < rowCount; row++) {
      //float x = map(triples[row], tripleMin, tripleMax, plotX1, plotX2);
      float x = map(row, 0, rowCount-1, plotX1, plotX2);
      text(triples[row], x, plotY2 + 10);
      
      // Long verticle line over each year interval
      line(x, plotY1, x, plotY2);
  } 
  
}

void drawVisualizationWindow() {
    fill(255);
  rectMode(CORNERS);
  rect(plotX1, plotY1, plotX2, plotY2);  
}

void drawGraphLabels() {
  fill(0);
  textSize(15);
  textAlign(CENTER, CENTER);
  float x1 = labelX;
  float y1 = (plotY1+plotY2)/2;

  text("Career Games Played", (plotX1+plotX2)/2, labelY);  
 
   pushMatrix();
  translate(x1,y1);
  rotate(-HALF_PI);
  translate(-x1,-y1);
  
  text("Career Goals Scored", labelX, (plotY1+plotY2)/2);
  popMatrix();
}