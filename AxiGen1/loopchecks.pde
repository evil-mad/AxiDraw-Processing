/**
 * Loop check functions (not for drawing)
 */


// Manage checking if the brush needs servicing, and moving to the next path
void checkServiceBrush() {

  if (serviceBrush() == false)

    if (millis() > NextMoveTime)
    {

      boolean actionItem = false;
      int intTemp = -1;
      float inputTemp = -1.0;
      PVector toDoItem;

      if ((ToDoList.length > (indexDone + 1))   && (Paused == false))
      {
        actionItem = true;
        toDoItem = ToDoList[1 + indexDone];
        inputTemp = toDoItem.x;
        indexDone++;
      }

      if (actionItem)
      {  // Perform next action from ToDoList::

        if (inputTemp >= 0)
        { // Move the carriage to draw a path segment!

          toDoItem = ToDoList[indexDone];  
          float x2 = toDoItem.x;
          float y2 = toDoItem.y;

          int x1 = round( (x2 - float(MousePaperLeft)) * MotorStepsPerPixel);
          int y1 = round( (y2 - float(MousePaperTop)) * MotorStepsPerPixel); 

          MoveToXY(x1, y1);
          //println("Moving to: " + str(x2) + ", " + str(y2));

          if (lastPosition.x == -1) {
            lastPosition = toDoItem; 
            //println("Starting point: Init.");
          }

          lastPosition = toDoItem;

          /*
           IF next item in ToDoList is ALSO a move, then calculate the next move and queue it to the EBB at this time.
           Save the duration of THAT move as "SubsequentWaitTime."
           
           When the first (pre-existing) move completes, we will check to see if SubsequentWaitTime is defined (i.e., >= 0).
           If SubsequentWaitTime is defined, then (1) we add that value to the NextMoveTime:
           
           NextMoveTime = millis() + SubsequentWaitTime; 
           SubsequentWaitTime = -1;
           
           We also (2) queue up that segment to be drawn.
           
           We also (3) queue up the next move, if there is one that could be queued. 
           
           */
        } else
        {
          intTemp = round(-1 * inputTemp);

          if ((intTemp > 9) && (intTemp < 20)) 
          {  // Change paint color  
            intTemp -= 10;
          } else if (intTemp == 30) 
          {
            raiseBrush();
          } else if (intTemp == 31) 
          {  
            lowerBrush();
          } else if (intTemp == 35) 
          {  
            MoveToXY(0, 0);
          }
        }
      }
    }
}

// Manage checking mouse position for highlights
void checkHighlights() {
  boolean doHighlightRedraw = false;

  // Manage highlighting of text buttons
  if ((mouseY >= MousePaperBottom)  || (mouseY < MousePaperTop)  )
  {
    if ((mouseY <= height)  && (mouseX >=  (MousePaperLeft - 50)))
    { 
      redrawButtons();
    }
  }


  if (doHighlightRedraw) {
    //redrawHighlight();
  }
}