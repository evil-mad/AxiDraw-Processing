// Return the [x,y] of the motor position in pixels
int[] getMotorPixelPos() {
  int[] out = {

    int (float (MotorX) / MotorStepsPerPixel) + MousePaperLeft, 
    int (float (MotorY) / MotorStepsPerPixel) + MousePaperTop + yBrushRestPositionPixels

  };
  return out;
}


// Get float distance between two non-encoded (x,y) positions. 
float getDistance(int x1, int y1, int x2, int y2)
{
  int xdiff = abs(x2 - x1);
  int ydiff = abs(y2 - y1);
  return sqrt(pow(xdiff, 2) + pow(ydiff, 2));
}

void scanSerial() 
{  

  // Serial port search string:  
  int PortCount = 0;
  String portName;
  String str1, str2;
  int j;


  int OpenPortList[]; 
  OpenPortList = new int[0]; 


  SerialOnline = false;
  boolean serialErr = false;


  try {
    PortCount = Serial.list().length;
  } 
  catch (Exception e) {
    e.printStackTrace(); 
    serialErr = true;
  }


  if (serialErr == false)
  {

    println("\nI found "+PortCount+" serial ports, which are:");
    println(Serial.list());


    String  os=System.getProperty("os.name").toLowerCase();
    boolean isMacOs = os.startsWith("mac os x");
    boolean isWin = os.startsWith("win");




    if (isMacOs) 
    {
      str1 = "/dev/tty.usbmodem";       // Can change to be the name of the port you want, e.g., COM5.
      // The default value is "/dev/cu.usbmodem"; which works on Macs.

      str1 = str1.substring(0, 14);

      j = 0;
      while (j < PortCount) {
        str2 = Serial.list()[j].substring(0, 14);
        if (str1.equals(str2) == true) 
          OpenPortList =  append(OpenPortList, j);

        j++;
      }
    } else if  (isWin) 
    {    
      // All available ports will be listed.

      j = 0;
      while (j < PortCount) {
        OpenPortList =  append(OpenPortList, j);
        j++;
      }
    } else {
      // Assume linux

      str1 = "/dev/ttyACM"; 
      str1 = str1.substring(0, 11);

      j = 0;
      while (j < PortCount) {
        str2 = Serial.list()[j].substring(0, 11);
        if (str1.equals(str2) == true)
          OpenPortList =  append(OpenPortList, j);
        j++;
      }
    }




    boolean portErr;

    j = 0;
    while (j < OpenPortList.length) {

      portErr = false;
      portName = Serial.list()[OpenPortList[j]];

      try
      {    
        myPort = new Serial(this, portName, 38400);
      }
      catch (Exception e)
      {
        SerialOnline = false;
        portErr = true;
        println("Serial port "+portName+" could not be activated.");
      }

      if (portErr == false)
      {
        myPort.buffer(1);
        myPort.clear(); 
        println("Serial port "+portName+" found and activated.");

        String inBuffer = "";

        myPort.write("v\r");  //Request version number
        delay(50);  // Delay for EBB to respond!

        while (myPort.available () > 0) {
          inBuffer = myPort.readString();   
          if (inBuffer != null) {
            println("Version Number: "+inBuffer);
          }
        }

        str1 = "EBB";
        if (inBuffer.length() > 2)
        {
          str2 = inBuffer.substring(0, 3); 
          if (str1.equals(str2) == true)
          {
            // EBB Identified! 
            SerialOnline = true;    // confirm that this port is good
            j = OpenPortList.length; // break out of loop

            println("Serial port "+portName+" confirmed to have EBB.");
          } else
          {
            myPort.clear(); 
            myPort.stop();
            println("Serial port "+portName+": No EBB detected.");
          }
        }
      }
      j++;
    }
  }
}




// Only need to redraw if hovering or changing state
void redrawButtons() {


  offScreen.beginDraw();
  offScreen.background(0, 0);

  DrawButtons(offScreen);

  offScreen.endDraw();

  imgButtons = offScreen.get(0, 0, offScreen.width, offScreen.height);
}


// Only need to redraw if hovering or change select on specific items
void redrawHighlight() {
  offScreen.beginDraw();
  offScreen.background(0, 0);

  offScreen.endDraw();
  imgHighlight = offScreen.get(0, 0, offScreen.width, offScreen.height);

  // TODO: Remove this section?
}


// Draw the locator crosshair to the offscreen buffer and fill imgLocator with it
// Only need to redraw this when it changes color
void redrawLocator() {
  offScreen.beginDraw();
  offScreen.background(0, 0);

  offScreen.stroke(0, 0, 0, 128); 
  offScreen.strokeWeight(2);  
  int x0 = 10;
  int y0 = 10; 

  if (BrushDown)
    offScreen.fill(PenColor);
  else
    offScreen.noFill();

  offScreen.ellipse(x0, y0, 10, 10);

  offScreen.line(x0 + 5, y0, x0 + 10, y0);
  offScreen.line(x0 - 5, y0, x0 - 10, y0);
  offScreen.line(x0, y0 + 5, x0, y0 + 10);
  offScreen.line(x0, y0 - 5, x0, y0 - 10);
  offScreen.endDraw();

  imgLocator = offScreen.get(0, 0, 25, 25);
}




void zero()
{
  // Mark current location as (0,0) in motor coordinates.  
  // Manually move the motor carriage to the left-rear (upper left) corner before executing this command.

  MotorX = 0;
  MotorY = 0;

  moveStatus = -1;
  MoveDestX = -1;
  MoveDestY = -1;

  // Calculate and animate position location cursor
  int[] pos = getMotorPixelPos();
  float sec = .25;

  Ani.to(this, sec, "MotorLocatorX", pos[0]);
  Ani.to(this, sec, "MotorLocatorY", pos[1]);


  //  if (debugMode) println("Motor X: " + MotorX + "  Motor Y: " + MotorY);
}

void clearall()
{  // ***** CLEAR ALL *****

  ToDoList = new PVector[0];

  ToDoList = (PVector[]) append(ToDoList, new PVector(-30, 0)); //Command 30 (Raise pen)
  ToDoList = (PVector[]) append(ToDoList, new PVector(-35, 0)); //Command 35 (Go home)


  indexDone = -1;    // Index in to-do list of last action performed
  indexDrawn = -1;   // Index in to-do list of last to-do element drawn to screen

  drawToDoList();

  Paused = false; 
  pause();
}

void quitApp()
{  // ***** QUIT *****

  if (SerialOnline)
  { 
    myPort.clear(); 
    myPort.stop();
  }

  exit();
}