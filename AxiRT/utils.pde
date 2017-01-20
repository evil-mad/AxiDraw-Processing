

int xyEncodeInt2() {

  // Perform XY limit checks on user input, and then encode position of mouse into a single int.
  // Constrain inputs to be within range of paper size, but all numbers are w.r.t. absolute window origin.
  // This is essentially only called when the mouse position changes.

  int xpos = mouseX;
  int ypos = mouseY;

  if (xpos < MousePaperLeft)
    xpos = MousePaperLeft;
  if (xpos > MousePaperRight)
    xpos = MousePaperRight;

  if (ypos < MousePaperTop)
    ypos = MousePaperTop;
  if (ypos > MousePaperBottom )
    ypos = MousePaperBottom;

  return (xpos * 10000) + ypos ;
}


int[] xyDecodeInt2(int encodedInt) {

  // Decode position coordinate from a single int.

  int x = floor(encodedInt / 10000);
  int y = encodedInt - 10000 * x;
  int[] out = {
    x, y
  };
  return out;
}


// Return the [x,y] of the motor position in pixels
int[] getMotorPixelPos() {
  int[] out = {

    int (float (MotorX) / MotorStepsPerPixel) + MousePaperLeft, 
    int (float (MotorY) / MotorStepsPerPixel) + MousePaperTop + yBrushRestPositionPixels

  };
  return out;
}

// Get float distance between two int encoded coordinates
float getDistance(int coord1Int, int coord2Int)
{
  int[] c1 = xyDecodeInt2(coord1Int);
  int[] c2 = xyDecodeInt2(coord2Int);

  int xdiff = abs(c1[0] - c2[0]);
  int ydiff = abs(c1[1] - c2[1]);

  return sqrt(pow(xdiff, 2) + pow(ydiff, 2));
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
  int PortNumber = -1;
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