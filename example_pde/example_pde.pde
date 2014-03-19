PFont f;                          

int numpoints; //number of points
int width = 600;
int height = 600;
int padding = 100;
int clicks = 5;
int currmin = 0; //tracks index of nearest target
int secondmin = 0; //tracks index of second-nearest target
int currTarget = 0; //tracks index of target to click in test mode
int numHits = 0;
int numMisses = 0;
int runningTotalTime = 0;
int numClicks = 0;

int rows;
int cols;

//floats and float arrays to handle position, movement, timing
float x, y;              //old cursor position
float cursorX, cursorY;  //cursor position
float[] pointsX, pointsY;
float[] diameter;
float[] containDistances;
float[] intersectDistances;
float[] distances;
float cursorDiameter;
float startTime=0;
float timeElapsed=0;

int trialIndex = 0;
int[] trialIndices = {0,1,2,3,4,5,6,7,8,9};

int[] movementTimes = new int[clicks-1];


//booleans to track program mode and bubble behavior
boolean morphed; //tracks if the bubble needs to be morphed
boolean regularCursor; //turns off the bubble cursor entirely
boolean testMode; // activates the target-timing test
boolean infoOn=true; //displays useful information, deactivate with "i"
boolean collisionsFound; //used only in initializing points to prevent overlap


void keyPressed() {
}
/*
String[] getStats() {
  String[] ret =  {padding,rows,cols,diameter[0],regularCursor?"regular":"bubble",join(movementTimes,","),numMisses};
  return ret;
}*/

void startTest(){
  startTime = millis();
  int oldTarget = currTarget;
  while (currTarget == oldTarget){
    currTarget = floor(random(0,numpoints));  
  }
}


void mousePressed(){
  numClicks++;

 if (testMode)
 {
   if (currmin==currTarget)
   {
     timeElapsed = millis()-startTime;
     runningTotalTime += timeElapsed;
     if (numHits>0)
       movementTimes[numHits-1] = (int)timeElapsed;
     numHits++;
     startTest();
   }
   else
   {
      numMisses++;
   }
 }
}

void initializePoints(float x,float y,float d) { // x cols, y rows, diameter d
  int posx, posy;
  int distx = (width - 2*padding)/((int)x-1);
  int disty = (height - 2*padding)/((int)y-1);

  numpoints = (int)x * (int)y;
  pointsX = new float[numpoints];
  pointsY = new float[numpoints];
  diameter = new float[numpoints];
  rows = (int)y;
  cols = (int)x;
  containDistances = new float[numpoints];
  intersectDistances = new float[numpoints];
  distances = new float[numpoints];


  posx = padding;
  for (int i=0; i<x; i++) {
    posy = padding;
    for (int j=0; j<y; j++) {
      pointsX[i*(int)x+j]= posx;
      pointsY[i*(int)x+j]= posy;
      diameter[i*(int)x+j]= d;
      posy += disty;
    }
    posx += distx;
  }
}

void selectTrial() {
  // for all trials the information will not be displayed to the user
  infoOn = false;
  testMode = true;

  if(trialIndex > 9){
    //alert("Thank you for participating. Click [OK] to continue.");
    //window.location = window.location;
  } else {
    trials(trialIndices[trialIndex]);
    trialIndex++;
    numClicks = 0;
    numHits = 0;
    numMisses = 0;
  }
}

void trials (int temp) {
switch(temp){  
  
// Trial one is cursor off
case 0:
  regularCursor = false;
  padding = 100;
  initializePoints(5,5,20);
  break;

// Trial two is cursor on
case 1:
  regularCursor = false;
  padding = 100;
  initializePoints(5,5,20);
  break;

// Trial three is cursor off large distance
case 2:
  regularCursor = false;
  padding = 50;
  initializePoints(5,5,20);
  break;

// Trial four is cursor off small distance
case 3:
  regularCursor = false;
  padding = 200;
  initializePoints(5,5,20);
  break;

// Trial five is cursor on large distance
case 4:
  regularCursor = false;
  padding = 50;
  initializePoints(5,5,20);
  break;

// Trial six is cursor on small distance
case 5: 
  regularCursor = false;
  padding = 200;
  initializePoints(5,5,20);
  break;

// Trial seven is cursor off small diameter
case 6:
  regularCursor = false;
  padding = 100;
  initializePoints(5,5,15);
  break;

// Trial eight is cursor off large diameter
case 7:
  regularCursor = false;
  padding = 100;
  initializePoints(5,5,30);
  break;

// Trial nine is cursor on small diameter
case 8:
  regularCursor = false;
  padding = 100;
  initializePoints(5,5,15);
  break;

// Trial ten is cursor on large diameter
case 9:
  regularCursor = false;
  padding = 100;
  initializePoints(5,5,30);
  break;

default:
  println("Nono matched in SWITCH");
  break;
}
}

void setup() 
{

  size(600, 600); 
  smooth();
  noStroke();

  //f = loadFont("HelveticaBold");
  //textFont(f,13);

  //trialIndices = shuffle(trialIndices);

  selectTrial();
}

//+ Jonas Raoni Soares Silva
//@ http://jsfromhell.com/array/shuffle [v1.0]
/*
int[] shuffle (int[] o){ //v1.0
  for(int j, x, i = o.length; i; j = parseInt(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
  return o;
};*/


void draw() 
{ 
  if(numHits == clicks){
    // submit the data for this trial
    //submit();
    selectTrial();  
  }

  background( 51 );
  cursorX = mouseX;  
  
  //here we follow the strategy on processing.org's tutorial for tracking mouse movement
  float dx = cursorX - x; //change in xposition
  if(abs(dx) > 1) { 
    x += dx;               
  }
  
  cursorY = mouseY;
  float dy = cursorY - y; //change in yposition
  if(abs(dy) > 1) {
    y += dy;
  }
  
  
  morphed=false; //true iff we need a morphed cursor bubble
  currmin=0; 
  secondmin=0;

  //compute distances to center, outermost and innermost
  //sides of all neighbors
  for (int i=0; i<pointsX.length; i++)
  {
    distances[i] = dist(x,y,pointsX[i],pointsY[i]); //distance to centers
    containDistances[i] = distances[i] + diameter[i]; //distance to contain
    intersectDistances[i] = distances[i]-(diameter[i]/2); //distance to intersect
    
    //find the nearest neighbor
    if ((intersectDistances[i]< intersectDistances[currmin]))
    {

      currmin=i;
    }
  }
  
    cursorDiameter = 2*distances[currmin] + diameter[currmin];
    
  //find the second-nearest neighbor, if needed
  for (int i=0;i<pointsX.length;i++){
    
    //check if we intersect the ith point, and if so, if the ith point is smaller
    if (!regularCursor && (i!= currmin) && (cursorDiameter/2 > intersectDistances[i])){
      morphed=true;
      secondmin = i;
      cursorDiameter = 2*intersectDistances[i];
    }
  }

  fill(255,200,200);
  
  if (morphed && !regularCursor)
  {
    ellipse(pointsX[currmin], pointsY[currmin], diameter[currmin]+10, diameter[currmin]+10 );
    
 }
  if (!regularCursor){
    ellipse(x, y, cursorDiameter, cursorDiameter);
  }
  
  //draw targets
  fill(234,211,237);
  for (int i=0;i<pointsX.length;i++){  
    if (testMode && (i ==currTarget))
    {
      // target color
      fill(0,255,102);
      ellipse(pointsX[i],pointsY[i],diameter[i],diameter[i]);
      fill(234,211,237);
    }
    else{
      ellipse(pointsX[i],pointsY[i],diameter[i],diameter[i]);
    }

  }
}







